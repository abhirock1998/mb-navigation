/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */

export declare interface WayPoint {
  type: "pickup" | "dropoff" | "start" | "end" | "none";
  Order?: number;
  Name?: string;
  Latitude: number;
  Longitude: number;
}

declare type WayPointMap = Record<number, WayPoint>;

declare type onDestinationArrival = {
  nativeEvent?: {
    destinationLatitude: number;
    destinationLongitude: number;
  };
};

declare type onLocationChange = {
  nativeEvent?: {
    longitude: number;
    latitude: number;
    distanceTraveled: number;
    durationRemaining: number;
    fractionTraveled: number;
    distanceRemaining: number;
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
