import Foundation
import UIKit
import React

@objc(MapboxNavigationManager)
class MapboxNavigationManager: RCTViewManager {
  override func view() -> UIView! {
    return MapboxNavigation()
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true;
  }
}