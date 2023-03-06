type AllowedWaypointType = "pickup" | "dropoff" | "end" | "none";

export interface WayPoint {
  Type: AllowedWaypointType;
  Order: number;
  Name?: string;
  Latitude: number;
  Longitude: number;
  userId?: string;
}

type WayPointMap = Record<number, WayPoint>;

type onMapboxEvent = {
  nativeEvent: {
    message: string;
  };
};

type onArrivalEvent = {
  nativeEvent: {
    message: string;
    longitude: number;
    latitude: number;
  };
};

export type WaypointArrival = {
  nativeEvent: {
    message: string;
    longitude: number;
    latitude: number;
    details: Location;
  };
};

type Location = {
  name: string;
  id: string;
  latitude: string;
  longitude: string;
  type: string;
  userIs: string;
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
  onWaypointArrival?: (event: WaypointArrival) => void;
  onDestinationArrival?: (event: onArrivalEvent) => void;
}
