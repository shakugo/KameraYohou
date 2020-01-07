import 'package:location/location.dart';
import 'package:flutter/services.dart';

class CurrentLocation {
  LocationData currentLocation;

  var location = new Location();

// Platform messages may fail, so we use a try/catch PlatformException.
  void getCurrentLocation() async {
    try {
      currentLocation = await location.getLocation();
      print(currentLocation.latitude);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        var error = 'Permission denied';
        print(error);
      }
      currentLocation = null;
    }
  }
}
