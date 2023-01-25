/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */

declare type Coordinate = [number, number];

declare type onDestinationArrival = {
  nativeEvent?: {
    destinationLatitude: number;
    destinationLongitude: number;
  };
};

declare type onNavigationCancelled = {
  nativeEvent?: {
    message?: string;
  };
};

declare type onEvent = {
  nativeEvent?: {
    message?: string;
  };
};

declare type onError = {
  nativeEvent?: {
    message?: string;
  };
};

export interface IMapboxNavigationProps {
  origin?: Coordinate;
  destination?: Coordinate;
  shouldSimulateRoute?: boolean;
  onError?: (event: onError) => void;
  onEvent?: (event: onEvent) => void;
  onNavigationCancel?: (event: onNavigationCancelled) => void;
  onArrive?: (event: onDestinationArrival) => void;
  onDestinationArrival: (event: onDestinationArrival) => void;
  showsEndOfRouteFeedback?: boolean;
  hideStatusView?: boolean;
  mute?: boolean;
}

export {};
