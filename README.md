# react-native-mb-navigation

## Getting started

Paste this line in your project `Package.json` and run `npm i`

<!-- `$ npm install react-native-mb-navigation --save` -->

```javascript
"react-native-mb-navigation": "https://github.com/abhirock1998/mb-navigation.git"
```

### Installation

#### For iOS

```javascript
cd ios
pod install
```

## Usage

```javascript
import MapboxNavigation from "react-native-mb-navigation";
```

> Depend on `MapoboxNavigation 1.3.0`

# Feature

- Include the option to input multiple coordinates up to a maximum of 25, as Mapbox can only handle 25 waypoints at once.
- To designate certain points as "SilentWaypoints" where the driver does not need to stop, create a "whitelist" property. By default, all points are designated as stoppage points, but this array allows other points to be specified as "SilentWaypoints."
- Include a "delay" property, which would enable the user to listen at specific time intervals. By default, it listens every second.

## Available property

- **isSimulationEnable** `boolean` We can test the navigation functionality during development by passing certain parameters.
- **onError** `Function` This function is called when an error occurs.
- **onEvent** `Function` usable for debugging
- **onCancelled** `Function` This function is called when the user cancels navigation by either pressing the close icon on the bottom bar or from the Notification tray.
- **onDestinationArrival** `Function` called once user arrived at final waypoint
- **onLocationChange** `Function` This function is called every second and returns the current user location along with additional details.
- **mute** `boolean` To mute navigation speech, a property can be set to true, with false being the default.
- **navigationMode** `String` The mode can be used for different types of transportation, such as walking, cycling, or driving. The default mode is driving
- **language** `String` A property can be used to change the navigation language, with `en` being the default.
- **waypoints** `Waypoint` Dictionary of coordinate
- **whiteList** use for making specific point as sopppage point and other waypoint type that not include in this arry will make as non stoppage point by default `[]`
- **updateLocationDelay** `number` for add delay in location change update function
- **onWaypointArrival** `Function` this function fire whenever user arrive at waypoint except `Destination` waypoint
- **onDestinationArrival** `Function` this function fire only once when user arrived at ts `Destination` waypoint

```javascript
Waypoint;

{
  type: "pickup" | "dropoff" | "start" | "end" | "none";
  Order: number;
  Name: string;
  Latitude: number;
  Longitude: number;
}
```

```
{
  1 : {
    type: "start";
    Order: number;
    Name: string;
    Latitude: number;
    Longitude: number;
   },
  2 : {
   type: "end";
   Order: number;
   Name: string;
   Latitude: number;
   Longitude: number;
 }
 ... more
}

```

- _required_ `type` A property is used to indicate the type of point. By default, all points are designated as stop points. To specify a specific stop point, a value must be provided to Mapbox.
- _required_ `Order` This number is used to sort the waypoint.
- _optional_ `Name` is name of the waypoint
- _required_ `Latitude` latitude of thwe waypoint
- _required_ `Longitude` longitude of thwe waypoint
- _optional_ `whiteList` To designate a specific point as a stoppage point, all points are set as stoppage points by default.
- _optional_ `updateLocationDelay` This is the number of seconds for which we listen to any location changes. The default value is `0`
