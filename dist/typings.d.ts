/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */
declare type AllowedWaypointType =
  | "pickup"
  | "dropoff"
  | "start"
  | "end"
  | "none";
declare type AllowedWhitelistKey = "pickup" | "dropoff" | "end" | "none";
export declare interface WayPoint {
  type: "pickup" | "dropoff" | "start" | "end" | "none";
  Order: number;
  Name?: string;
  Latitude: number;
  Longitude: number;
}

declare type WayPointMap = Record<number, WayPoint>;

declare type onLocationChange = {
  nativeEvent?: {
    longitude: number;
    latitude: number;
  };
};

type onMapboxEvent = {
  nativeEvent?: {
    message?: string;
  };
};

export interface IMapboxNavigationProps {
  isSimulationEnable?: boolean;
  onError: (event: onMapboxEvent) => void;
  onEvent?: (event: onMapboxEvent) => void;
  onCancelled?: () => void;
  onChange: (event: onLocationChange) => void;
  mute?: boolean;
  navigationMode?: "cycling" | "driving" | "walking";
  language?: "en" | "de";
  waypoints?: WayPointMap;
  whiteList: AllowedWhitelistKey[];
  updateLocationDelay?: number;
}
