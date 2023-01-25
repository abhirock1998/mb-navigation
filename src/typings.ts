type Coordinate = [number, number];

// RCT_EXPORT_VIEW_PROPERTY(onEvent, RCTDirectEventBlock);
// RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock);
// RCT_EXPORT_VIEW_PROPERTY(onNavigationCancelled, RCTDirectEventBlock);
// RCT_EXPORT_VIEW_PROPERTY(onDestinationArrival, RCTDirectEventBlock);

// "destinationLatitude": waypoint.coordinate.latitude,
// "destinationLongitude": waypoint.coordinate.longitude,

type onDestinationArrival = {
  nativeEvent?: {
    destinationLatitude: number;
    destinationLongitude: number;
  };
};

type onNavigationCancelled = {
  nativeEvent?: {
    message?: string;
  };
};

type OnRouteProgressChangeEvent = {
  nativeEvent?: {
    distanceTraveled: number;
    durationRemaining: number;
    fractionTraveled: number;
    distanceRemaining: number;
  };
};

type onEvent = {
  nativeEvent?: {
    message?: string;
  };
};

type onError = {
  nativeEvent?: {
    message?: string;
  };
};

export interface IMapboxNavigationProps {
  origin?: Coordinate;
  destination?: Coordinate;
  shouldSimulateRoute?: boolean;
  onError?: (event: onError) => void;
  onnavigationCancel?: (event: onNavigationCancelled) => void;
  onArrive?: () => void;
  showsEndOfRouteFeedback?: boolean;
  hideStatusView?: boolean;
  mute?: boolean;
}
