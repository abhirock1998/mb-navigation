/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */

export type WayPoint = {
  Type: "pickup" | "dropoff" | "none";
  Order?: number;
  Name?: string;
  Latitude: number;
  Longitude: number;
};

type WayPointMap = Record<number, WayPoint>;

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

type onLocationChange = {
  nativeEvent?: {
    longitude: number;
    latitude: number;
    distanceTraveled: number;
    durationRemaining: number;
    fractionTraveled: number;
    distanceRemaining: number;
  };
};

export interface IMapboxNavigationProps {
  isSimulationEnable?: boolean;
  onError: (event: onError) => void;
  onEvent?: (event: onEvent) => void;
  onNavigationCancelled?: (event: onNavigationCancelled) => void;
  onArrive?: (event: onDestinationArrival) => void;
  onDestinationArrival: (event: onDestinationArrival) => void;
  onLocationChange: (event: onLocationChange) => void;
  mute?: boolean;
  navigationMode?: "cycling" | "driving" | "walking";
  language?: "en" | "de";
  waypoints?: WayPointMap;
  whiteList: string[];
}
// TODO:-> need to think about how this property  exposed to RN app
// RCT_EXPORT_VIEW_PROPERTY(onWaypointArrival, RCTDirectEventBlock);
// RCT_EXPORT_VIEW_PROPERTY(isListenerEnableOnEachWaypointArrival, BOOL);
