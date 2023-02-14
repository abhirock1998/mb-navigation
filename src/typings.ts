/** @type {[number, number]}
 * Provide an array with longitude and latitude [$longitude, $latitude]
 */

export interface WayPoint {
  type: "pickup" | "dropoff" | "start" | "end" | "none";
  Order: number;
  Name?: string;
  Latitude: number;
  Longitude: number;
}

type WayPointMap = Record<number, WayPoint>;

type onMapboxEvent = {
  nativeEvent?: {
    message?: string;
  };
};

type onLocationChange = {
  nativeEvent?: {
    longitude: number;
    latitude: number;
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
  whiteList: string[];
  updateLocationDelay?: number;
}
