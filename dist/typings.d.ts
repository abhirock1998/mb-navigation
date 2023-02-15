declare type AllowedWaypointType = "pickup" | "dropoff" | "end" | "none";

export declare interface WayPoint {
  Type: AllowedWaypointType;
  Order: number;
  Name?: string;
  Latitude: number;
  Longitude: number;
}

declare type WayPointMap = Record<number, WayPoint>;

declare type onMapboxEvent = {
  nativeEvent: {
    message: string;
  };
};

declare type onArrivalEvent = {
  nativeEvent: {
    message: string;
    longitude: number;
    latitude: number;
  };
};

export interface IMapboxNavigationProps {
  isSimulationEnable?: boolean;
  onError: (event: onMapboxEvent) => void;
  onEvent?: (event: onMapboxEvent) => void;
  onCancelled?: () => void;
  onLocationChange: (event: onArrivalEvent) => void;
  mute?: boolean;
  navigationMode?: "cycling" | "driving" | "walking";
  language?: "en" | "de";
  waypoints: WayPointMap;
  whiteList: AllowedWaypointType[];
  updateLocationDelay?: number;
  onWaypointArrival?: (event: onArrivalEvent) => void;
  onDestinationArrival?: (event: onArrivalEvent) => void;
}
