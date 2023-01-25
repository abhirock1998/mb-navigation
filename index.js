// main index.js
import * as React from "react";
import { requireNativeComponent, StyleSheet } from "react-native";

const RNMapboxNavigation = requireNativeComponent(
  "MapboxNavigation",
  MapboxNavigation
);

const MapboxNavigation = (props) => {
  return <RNMapboxNavigation style={styles.container} {...props} />;
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default MapboxNavigation;
