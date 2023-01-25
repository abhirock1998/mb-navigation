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






class MapboxNavigation: UIView, NavigationViewControllerDelegate {
  
  
  weak var _navViewController: NavigationViewController?
  var _embedded: Bool
  var _embedding: Bool
  var _wayPoints = [Waypoint]()
  var _options: NavigationRouteOptions?
  var _navigationMapView: NavigationMapView!
  var _routeResponse: RouteResponse?
  //  property that we need to expose to JS
  @objc var onEvent: RCTDirectEventBlock?
  @objc var onError: RCTDirectEventBlock?
  @objc var onNavigationCancelled: RCTDirectEventBlock?
  @objc var onDestinationArrival: RCTDirectEventBlock?
  
  @objc var isSimulationEnable: Bool = false;
  @objc var navigationMode: String?
  @objc var voiceUnits = "imperial"
  @objc var language = "en"
  @objc var mute: Bool = false
  
  
  
  
  
  
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
      makeWaypoints()
    } else {
      _navViewController?.view.frame = bounds
    }
  }
  
  
  
  
  
  private func startNavigationWithWayPoints(wayPoints: [Waypoint]) {
    _embedding = true
    self.onEvent!(["message":"Configuring.. navigation with waypoints"])
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
    
    // TODO:-> do something with this
    let originCoord = CLLocationCoordinate2D(latitude: 37.773, longitude: -122.411)
    let destinationCoord =  CLLocationCoordinate2D(latitude: 37.8, longitude: -122.5)
    let origin = Waypoint(coordinate:originCoord, coordinateAccuracy: -1, name: "Mapbox")
    let destination = Waypoint(coordinate:destinationCoord, coordinateAccuracy: -1, name: "White House")
    
    let options = NavigationRouteOptions(waypoints: wayPoints, profileIdentifier: mode)
    options.distanceMeasurementSystem =  .metric
    options.locale = Locale(identifier: language)
    _ = Directions.shared.calculate(options) {[weak self] (_, result) in
      guard let strongSelf = self else { return }
      switch result {
      case .failure(let error):
        strongSelf.onError?(["message":"Error during getting routes \(error.localizedDescription)"])
      case .success(let response):
        strongSelf.onEvent?(["message":"Ready to start navigation"])
        let simulationMode: SimulationMode = strongSelf.isSimulationEnable ? .always : .never
        strongSelf.onEvent?(["message":"Creating navigation with response"])
        let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
        let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse, credentials: NavigationSettings.shared.directions.credentials,simulating: simulationMode)
        let navigationOptions = NavigationOptions(navigationService: navigationService)
        strongSelf.configureNavigationViewController(indexRouteResponse: indexedRouteResponse, navigationOptions: navigationOptions)
        
      }
      strongSelf._embedding = false
      strongSelf._embedded = true
    }
    
  }
  
  
  func getCurrentViewController() -> UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
    
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
  
  
  func configureNavigationViewController(indexRouteResponse: IndexedRouteResponse,navigationOptions: NavigationOptions ){
    let vc = NavigationViewController(for: indexRouteResponse,navigationOptions: navigationOptions)
    self._navViewController = vc
    let currentController = getViewController()
    guard let parentVc = currentController else {
      return
    }
    vc.delegate = self
    if !parentVc.isViewLoaded {
      onEvent!(["message":"Parent VC not loaded so just push navigation VC"])
      parentVc.present(vc, animated: true,completion: nil)
    }else {
      onEvent!(["message":"Parent VC already loaded"])
      vc.modalPresentationStyle = .fullScreen
      parentVc.present(vc, animated: true,completion: nil)
      
    }
  }
  
  
  private func makeWaypoints() {
    _wayPoints.removeAll()
    onEvent!(["message":"Creating... waypoints"])
    for i in 0..<dummyWaypoints.count {
      let point = Waypoint(coordinate: CLLocationCoordinate2D(latitude: dummyWaypoints[i].1, longitude: dummyWaypoints[i].0))
      _wayPoints.append(point)
    }
    onEvent!(["message":"Waypoint creation Done"])
    startNavigationWithWayPoints(wayPoints: _wayPoints)
  }
  
  
  func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
    if (!canceled) {
      return;
    }
   _navViewController!.delegate = nil
    onNavigationCancelled?(["message": "Driver cancelled the navigation"]);
  }
  
  func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
    onDestinationArrival?([
      "destinationLatitude": waypoint.coordinate.latitude,
      "destinationLongitude": waypoint.coordinate.longitude,
    ]);
    return true;
  }
  
}






let dummyWaypoints = [
  (8.182679, 53.134608),
  (8.182683, 53.134488),
  (8.182929, 53.134485),
  (8.183206, 53.134396),
  (8.183154, 53.134404),
  (8.18294, 53.134406),
  (8.1829, 53.134408),
  (8.18231, 53.134408),
  (8.182228, 53.134368),
  (8.182065, 53.134515),
  (8.181998, 53.134575),
  (8.181826, 53.13473),
  (8.181595, 53.135069),
  (8.181643, 53.135423),
  (8.181388, 53.13561),
  (8.181229, 53.135685),
  (8.180864, 53.135962),
  (8.180799, 53.135934),
  (8.180734, 53.135896),
  (8.179383, 53.13521),
  (8.179775, 53.134898)
]
