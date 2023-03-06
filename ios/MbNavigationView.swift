//
//  MbView.swift
//  mb
//
//  Created by Abhishek yadav on 25/01/23.
//

import Foundation
import UIKit
import React
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections

let delimeter = "$"

class MapboxNavigation: UIView, NavigationViewControllerDelegate {
  weak var _navViewController: NavigationViewController?
  var _embedded: Bool
  var _embedding: Bool
  var _options: NavigationRouteOptions?
  var _wayPoints = [Waypoint]()
  var _locationUpdationDelay = 0
  var _pointType = [String:Location]()
  
  //  property that we need to expose to JS
  @objc var onEvent: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onLocationChange: RCTDirectEventBlock?
  @objc var onCancelled: RCTDirectEventBlock?
  @objc var onWaypointArrival: RCTDirectEventBlock?
  @objc var onDestinationArrival: RCTDirectEventBlock?
  @objc var isSimulationEnable: Bool = false;
  @objc var navigationMode: String?
  @objc var language = "en"
  @objc var mute: Bool = false
  @objc var updateLocationDelay: Int = 0;
  
  
  @objc var whiteList: NSArray = [] {
    didSet { setNeedsLayout() }
  }
  
  @objc var wayPoints: NSDictionary = [:] {
    didSet { setNeedsLayout() }
  }
  
  override init(frame: CGRect) {
    self._embedded = false
    self._embedding = false
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if(_navViewController == nil && !_embedded && !_embedding){
      initNavigation()
    } else {
      _navViewController?.view.frame = bounds
    }
  }
  
//  userId
  
  func initNavigation()  {
    _wayPoints.removeAll()
    _pointType.removeAll()
    let oWayPoints = wayPoints as NSDictionary
    _embedding = true
    onEvent?(["message":"Creating... waypoints for navigation"])
    var locations = [Location]()
    var pickupPointId: Int = 0
    var dropoffPointId: Int = 0
    for item in oWayPoints as NSDictionary
    {
      let id = UUID().uuidString;
      let point = item.value as! NSDictionary
      guard let oName = point["Name"] as? String else {return}
      guard let oType = point["Type"] as? String else {return}
      let oKey = point["userId"] as? String
      guard let oLatitude = point["Latitude"] as? Double else {
        onError?(["message":"Latitude should be number"])
        return
      }
      guard let oLongitude = point["Longitude"] as? Double else {
        onError?(["message":"Longitude should be number"])
        return
      }
      let order = point["Order"] as? Int
      let location = Location(name: oName, latitude: oLongitude, longitude: oLatitude, order: order,type: oType,id:id,userId: oKey)
      locations.append(location)
    }
    // sort location
    onEvent?(["message":"Sorting... Location based on Order key"])
    locations.sort(by: {$0.order ?? 0 < $1.order ?? 0})
    onEvent?(["message":"Location sorting is Done"])
    for loc in locations{
      let id = loc.id;
      let latitude = loc.latitude!
      let longitude = loc.longitude!
      let point = createWaypoint(lat: latitude, lng:longitude)
      let parsedLat = point.coordinate.latitude
      if parsedLat != 0 {
        if !whiteList.contains(loc.type){
          point.separatesLegs = false;
        } else {
          // here we make sure than name always be a unique since
          // we are using as key for storing Location class for future use
          var pointName: String = loc.name
          if(loc.type == "pickup"){
            pickupPointId += 1
            pointName = "Pickup point \(pickupPointId)"
          } else if (loc.type == "dropoff"){
            dropoffPointId += 1
            pointName = "Dropoff point \(dropoffPointId)"
          }
          point.name = pointName
          _pointType[pointName] = loc
        }
        _wayPoints.append(point)
      }
      
    }
    onEvent?(["message":"Waypoint creation Done with \(_wayPoints.count) points"])
    if(_wayPoints.count > 2 && _wayPoints.count <= 25)
    {
      _embedding = false
      _embedded = true
      startNavigationWithWayPoints(wayPoints: _wayPoints)
    } else {
      onError?(["message":"Waypoint length should be >= 2 and <= 25 but provided with \(_wayPoints.count) waypoints"])
    }
  }
  
  /**
   * Constrain degrees to range -180..+180 (for longitude); e.g. -181 => 179, 181 => -179.
   */
  func wrapLongitude(degree: Double) -> Double {
    if (-180 <= degree && degree <= 180) {return wrapDouble(degree: degree)}
    let x = degree, a = 180, p = 360;
    let y = (2 * a * Int(x)/p - p/2)
    let z = (y % p) + p
    return wrapDouble(degree: Double(z % p - a));
  }
  
  /**
   * Constrain degrees to range -90..+90 (for latitude); e.g. -91 => -89, 91 => 89.
   */
  func wrapLatitude(degree: Double) -> Double {
    if(-90 <= degree && degree <= 90) {return wrapDouble(degree: degree)}
    let x = degree, a = 90, p = 360;
    let y = (( Int(x) - p/4) % p + p)
    return wrapDouble(degree: Double(4 * a/p * abs(y % p - p/2) - a))
  }
  
  // wrapped long lfoat number to 6digit after decimal to process data easily
  func wrapDouble(degree: Double) -> Double {
    let formattedNumber = String(format: "%.6f", degree)
    guard let value = Double(formattedNumber) else { return 0 }
    return value
  }
  
  func createWaypoint(lat:Double, lng:Double) -> Waypoint{
    return Waypoint(coordinate: CLLocationCoordinate2D(latitude:wrapLatitude(degree: lat), longitude: wrapLongitude(degree: lng)))
  }
  
  func startNavigationWithWayPoints(wayPoints: [Waypoint]) {
    self.onEvent?(["message":"Configuring.. navigation with waypoints"])
    var mode: DirectionsProfileIdentifier = .automobileAvoidingTraffic
    if (navigationMode == "cycling"){
      mode = .cycling
    }else if(navigationMode == "driving"){
      mode = .automobile
    }else if(navigationMode == "walking"){
      mode = .walking
    }
    // for more route options setting we can configure here
    let  options = NavigationRouteOptions(waypoints: wayPoints, profileIdentifier: mode)
    options.locale = Locale(identifier: self.language)
    self._options = options
    
    _ = Directions.shared.calculate(options) {[weak self] (_, result) in
      guard let strongSelf = self else { return }
      switch result {
      case .failure(let error):
        strongSelf.onError?(["message":"Error during getting routes \(error.localizedDescription)"])
      case .success(let response):
        strongSelf.onEvent?(["message":"Ready to start navigation"])
        let simulationMode: SimulationMode = strongSelf.isSimulationEnable ? .always : .never
        let simulationStatus = strongSelf.isSimulationEnable ? "Enable" : "Disable"
        strongSelf.onEvent?(["message":"Simulation is \(simulationStatus)"])
        NavigationSettings.shared.voiceMuted = strongSelf.mute;
        NavigationSettings.shared.distanceUnit = .mile
        guard let route = response.routes?.first else {
          strongSelf.onError?(["message":"No single route found for given waypoint"])
          return
        }
        strongSelf.onEvent?(["message":"Creating navigation with RouteResponse"])
        let navigationService = MapboxNavigationService(route: route, routeIndex: 0, routeOptions: options,simulating: simulationMode)
        let navigationOptions = NavigationOptions(navigationService: navigationService);
        strongSelf.configureNavigationViewController(route: route ,routeOptions: options)
      }
      
    }
  }
  
  func configureNavigationViewController(route: Route,routeOptions:NavigationRouteOptions ){
    let vc = NavigationViewController(for: route, routeIndex: 0, routeOptions: routeOptions)
    vc.modalPresentationStyle = .fullScreen
    vc.voiceController.speechSynthesizer.locale = Locale(identifier: self.language)
    vc.showsEndOfRouteFeedback = false
    vc.showsReportFeedback = false
    vc.hidesBottomBarWhenPushed = true
    vc.delegate = self
    self._navViewController = vc
    let currentController = getViewController()
    guard let parentVc = currentController else {
      onError?(["message":"Unable to get UIViewController to present navigation controller"])
      return
    }
    onEvent?(["message":"Parent VC already loaded"])
    parentVc.present(vc, animated: true,completion: nil)
  }
  
  func getViewController() -> UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
  
  func endNavigation()  {
    if(self._navViewController != nil)
    {
      self._navViewController?.navigationService.endNavigation(feedback: nil)
      self._navViewController?.dismiss(animated: true, completion: {
        self.onEvent?(["message":"Destroying Parent VC"])
        self.onCancelled?(["message":"Navigation is cancelled"])
        self.updateLocationDelay = 0
        self._embedded = false
        self._embedding = false
        self._options = nil
        self._wayPoints.removeAll()
        self._navViewController = nil
      })
    }
  }
  
  // function provided by Mapbox navigation view controller to check is navigation cancel by user
  func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
    onEvent?(["message":"Trying to cancel the navigation"])
    let alert = UIAlertController(title: "Cancel", message: "Are you sure want to cancel the navigation?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "No", style: .cancel))
    alert.addAction(UIAlertAction(title: "Yes", style: .destructive,handler: {_ in
      self.endNavigation();
    }))
    navigationViewController.present(alert, animated: true, completion: nil)
  }
  
  func parsePointDetails(waypoint: Waypoint) -> (String,String,Location?) {
    let name = waypoint.name ?? ""
    let storedPoint = self._pointType[name]
    guard let point = storedPoint else {return (name,"",nil)}
    onEvent?(["message":"Parse location \(point.userId!) \(point.order!)"])
    return (name,point.id,point)
  }
  
  func parseLocation(location: Location) -> NSDictionary{
    return ["name":location.name,"id":location.id,"latitude":location.latitude!,"longitude":location.longitude! ,"type":location.type,"userId":location.userId!]
  }
  
  // function fire once user reached to its destination
  func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
    let isFinalLeg = navigationViewController.navigationService.routeProgress.isFinalLeg
    let point = parsePointDetails(waypoint: waypoint)
    let title = "Arrived at \(point.0)."
    let coord = waypoint.coordinate;
    if isFinalLeg {
      // final destination alert
      let alert = UIAlertController(title: "You arrived at your destination",message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: {_ in
        self.onDestinationArrival?(["message":title,"latitude":coord.latitude,"longitude":coord.longitude])
        self.endNavigation()
      }))
      navigationViewController.present(alert, animated: true, completion: nil)
      return true
    }
    let alert = UIAlertController(title:title, message: "Would you like to continue?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
      // Begin the next leg once the driver confirms
      // waypoint arrival alert
      if !isFinalLeg {
        let data = point.2
        if data != nil {
          self.onWaypointArrival?(["message":title,"latitude":coord.latitude,"longitude":coord.longitude,"details":self.parseLocation(location: data!)])
        }else{
          self.onWaypointArrival?(["message":title,"latitude":coord.latitude,"longitude":coord.longitude])
        }
        navigationViewController.navigationService.router.advanceLegIndex()
        navigationViewController.navigationService.start()
      }
    }))
    navigationViewController.present(alert, animated: true, completion: nil)
    return false
  }
  
  // function fire every second
  func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
    let coord = location.coordinate;
    if updateLocationDelay > 0 {
      _locationUpdationDelay += 1
      if _locationUpdationDelay % updateLocationDelay == 0 {
        onLocationChange?(["longitude": coord.longitude,"latitude": coord.latitude,"message":"Location change"])
      }
    } else {
      onLocationChange?(["longitude": coord.longitude,"latitude": coord.latitude,"message":"Location change"])
    }
    
  }
}


// -----------------------------  UTILS CLASS MODEL -------------------------------------
class Location : Codable{
  let name: String
  let latitude: Double?
  let longitude: Double?
  let order: Int?
  let type: String
  let id: String
  let userId: String?
  
  init(name: String, latitude: Double?, longitude: Double?, order: Int? = nil,type: String,id:String,userId: String?) {
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
    self.order = order
    self.type = type
    self.id = id
    self.userId = userId
  }
}


