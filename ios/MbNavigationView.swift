//
//  MbView.swift
//  mb
//
//  Created by Abhishek yadav on 25/01/23.
//

import Foundation
import UIKit
import React
import MapboxMaps
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections

class MapboxNavigation: UIView, NavigationViewControllerDelegate {
  
  
  weak var _navViewController: NavigationViewController?
  var _embedded: Bool
  var _embedding: Bool
  var _options: NavigationRouteOptions?
  var _navigationMapView: NavigationMapView!
  var _routeResponse: RouteResponse?
  var _wayPoints = [Waypoint]()
  
  //  property that we need to expose to JS
  @objc var onEvent: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onNavigationCancelled: RCTDirectEventBlock?
  @objc var onDestinationArrival: RCTDirectEventBlock?
  @objc var onLocationChange: RCTDirectEventBlock?
  
  @objc var isSimulationEnable: Bool = false;
  @objc var navigationMode: String?
  @objc var language = "en"
  @objc var mute: Bool = false
  
  
  @objc var wayPoints: NSDictionary = [:] {
    didSet { setNeedsLayout() }
  }
  
  @objc var origin: NSArray = [] {
    didSet { setNeedsLayout() }
  }
  
  @objc var destination: NSArray = [] {
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
  
  private func startNavigationWithWayPoints(wayPoints: [Waypoint]) {
    self.onEvent?(["message":"Configuring.. navigation with waypoints"])
    var mode: ProfileIdentifier = .automobileAvoidingTraffic
    if (navigationMode == "cycling")
    {
      mode = .cycling
    }
    else if(navigationMode == "driving")
    {
      mode = .automobile
    }
    else if(navigationMode == "walking")
    {
      mode = .walking
    }
    //    guard origin.count == 2 && destination.count == 2 else { return }
    
    //    let originCoord = CLLocationCoordinate2D(latitude: origin[1] as! CLLocationDegrees, longitude: origin[0] as! CLLocationDegrees)
    //    let destinationCoord =  CLLocationCoordinate2D(latitude: destination[1] as! CLLocationDegrees, longitude: destination[0] as! CLLocationDegrees)
    let originCoord = CLLocationCoordinate2D(latitude:    53.134608, longitude: 8.182679)
    let destinationCoord =  CLLocationCoordinate2D(latitude:    53.134898, longitude:  8.179775)
    let originWaypoint = Waypoint(coordinate:originCoord, coordinateAccuracy: -1)
    let destinationWaypoint = Waypoint(coordinate:destinationCoord, coordinateAccuracy: -1)
    
    // for more route options setting we can configure here
    let options = NavigationRouteOptions(waypoints: wayPoints, profileIdentifier: mode)
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
        NavigationSettings.shared.voiceMuted = strongSelf.mute;
        NavigationSettings.shared.distanceUnit = .mile
        strongSelf.onEvent?(["message":"Creating navigation with response"])
        let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
        let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse, credentials: NavigationSettings.shared.directions.credentials,simulating: simulationMode)
        navigationService.router.reroutesProactively = false
        // TODO:-> In future we can expose customStyles URL to JS
        let dayStyle = CustomDayStyle()
        let nightStyle = CustomNightStyle()
        let navigationOptions = NavigationOptions(styles: [dayStyle, nightStyle], navigationService: navigationService)
        strongSelf.configureNavigationViewController(indexRouteResponse: indexedRouteResponse, navigationOptions: navigationOptions)
        
        
      }
    }
    
  }
  
  private func getViewController() -> UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
  
  
  private func configureNavigationViewController(indexRouteResponse: IndexedRouteResponse,navigationOptions: NavigationOptions ) {
    let vc = NavigationViewController(for: indexRouteResponse,navigationOptions: navigationOptions)
    vc.modalPresentationStyle = .fullScreen
    vc.delegate = self
    vc.navigationMapView?.localizeLabels()
    vc.voiceController.speechSynthesizer.locale = Locale(identifier: self.language)
    // hide bottom status view it does not remove height of default bottom banner
    vc.showsEndOfRouteFeedback = false
    vc.navigationView.bottomBannerContainerView.hide()
    self._navViewController = vc
    let currentController = getViewController()
    guard let parentVc = currentController else {
      return
    }
    onEvent?(["message":"Parent VC already loaded"])
    parentVc.present(vc, animated: true,completion: nil)
  }
  
  
  
  
  
  private func initNavigation()  {
    _wayPoints.removeAll()
    let oWayPoints = wayPoints as NSDictionary
    _embedding = true
    onEvent?(["message":"Creating... waypoints for navigation"])
    var locations = [Location]()
    for item in oWayPoints as NSDictionary
    {
      
      let point = item.value as! NSDictionary
      guard let oName = point["Name"] as? String else {return}
      guard let oLatitude = point["Latitude"] as? Double else {
        onError?(["message":"Latitude should be number"])
        return
      }
      guard let oLongitude = point["Longitude"] as? Double else {
        onError?(["message":"Longitude should be number"])
        return
      }
      let order = point["Order"] as? Int
      let location = Location(name: oName, latitude: oLongitude, longitude: oLatitude, order: order)
      locations.append(location)
    }
    
    for loc in locations {
      let point = Waypoint(coordinate: CLLocationCoordinate2D(latitude: loc.latitude!, longitude: loc.longitude!),name:loc.name)
      _wayPoints.append(point)
    }
    onEvent?(["message":"Waypoint creation Done with \(_wayPoints.count) points"])
    
    //  At least tow waypoint should exist for navigation
    if(_wayPoints.count > 2 && _wayPoints.count <= 25)
    {
      
      _embedding = false
      _embedded = true
      startNavigationWithWayPoints(wayPoints: _wayPoints)
    } else {
      onError?(["message":"Waypoint should be >= 2 and <= 25 but provided with \(_wayPoints.count) points"])
    }
    
  }
  
  // function provided by Mapbox navigation view controller to check is navigation cancel by user
  func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
    if (!canceled) {
      return;
    }
    _navViewController!.delegate = nil
    onNavigationCancelled?(["message": "Driver cancelled the navigation"]);
    navigationViewController.dismiss(animated: true,completion: nil)
  }
  
  // function fire once user reached to its destination
  func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
    onDestinationArrival?([
      "destinationLatitude": waypoint.coordinate.latitude,
      "destinationLongitude": waypoint.coordinate.longitude,
    ]);
    return true;
  }
  
  // function fire every second
  func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
    onLocationChange?(["longitude": location.coordinate.longitude,
                       "latitude": location.coordinate.latitude,
                       "distanceTraveled": progress.distanceTraveled,
                       "durationRemaining": progress.durationRemaining,
                       "fractionTraveled": progress.fractionTraveled,
                       "distanceRemaining": progress.distanceRemaining,
                      ])
    
  }
  
  //  For more details https://docs.mapbox.com/ios/navigation/api/1.4.2/using-map-matching.html
  func navigationViewController(_ navigationViewController: NavigationViewController, shouldRerouteFrom location: CLLocation) -> Bool {
   
    let routeOptions = NavigationRouteOptions(waypoints: [Waypoint(coordinate: location.coordinate), self._options!.waypoints.last!])
        _ = Directions.shared.calculate(routeOptions) { [weak self] (_, result) in
          switch result {
          case .failure(let error):
            self?.onError?(["message":"Error during calculating route again before Re-routing \(error)"])
          case .success(let response):
            guard let routeShape = response.routes?.first?.shape else {
              return
            }
            self?.onEvent?(["message":"Creating.. Match options"])
            let matchOptions = NavigationMatchOptions(coordinates: routeShape.coordinates)
    
            // By default, each waypoint separates two legs, so the user stops at each waypoint.
            // We want the user to navigate from the first coordinate to the last coordinate without any stops in between.
            // You can specify more intermediate waypoints here if you’d like.
            // TODO:-> here we need to some key on which we can define to stopa ath waypoint or not
            // we can use NSDictionary for checkimg value
            for waypoint in matchOptions.waypoints.dropFirst().dropLast() {
              waypoint.separatesLegs = false
            }
    
    
            Directions.shared.calculateRoutes(matching: matchOptions) { [weak self ] (_, result) in
              switch result {
              case .failure(let error):
                self?.onError?(["message":"Error during calculateRoutes \(error.localizedDescription)"])
              case .success(let response):
                guard !(response.routes?.isEmpty ?? true) else {
                  return
                }
                // Convert matchOptions to `RouteOptions`
                let routeOptions = RouteOptions(matchOptions: matchOptions)
                self?._navViewController!.navigationService.router.updateRoute(with: .init(routeResponse: response, routeIndex: 0), routeOptions: routeOptions, completion:nil)
              }
            }
          }
        }
        return true
  }
}










