import 'dart:async';
import 'package:location/location.dart';


class UserLocationAPI {
  Location location = Location();

  UserLocationAPI();

  Stream<LocationData> getLocation() {
    location.enableBackgroundMode(enable: true);
    location.changeSettings(distanceFilter: 0, accuracy: LocationAccuracy.high);
    return location.onLocationChanged;
  }
}
