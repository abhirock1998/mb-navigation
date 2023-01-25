/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */

type Coordinate = [number, number];

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
  isSimulationEnable?: boolean;
  onError?: (event: onError) => void;
  onEvent?: (event: onEvent) => void;
  onNavigationCancel?: (event: onNavigationCancelled) => void;
  onArrive?: (event: onDestinationArrival) => void;
  onDestinationArrival: (event: onDestinationArrival) => void;
  showsEndOfRouteFeedback?: boolean;
  hideStatusView?: boolean;
  mute?: boolean;
  navigationMode?: "cycling" | "driving" | "walking";
  language?: "en";
}
