import 'package:geolocator/geolocator.dart';

class CurrentLocation {
  void getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("CurrentPosition:"position);
  }
}
