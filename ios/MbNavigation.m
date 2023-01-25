#import <Foundation/Foundation.h>
#import "React/RCTViewManager.h"
#import <MapboxDirections/MapboxDirections.h>

@interface RCT_EXTERN_MODULE(MapboxNavigationManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(onEvent, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onNavigationCancelled, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDestinationArrival, RCTDirectEventBlock)

@end