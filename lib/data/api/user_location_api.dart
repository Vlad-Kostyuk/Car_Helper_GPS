import 'dart:async';
import 'package:location/location.dart';


class UserLocationAPI {
  Location location = Location();

  UserLocationAPI();

  Stream<LocationData> getLocation() {
    return location.onLocationChanged;
  }
}
