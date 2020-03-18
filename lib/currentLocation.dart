import 'package:geolocator/geolocator.dart';

class CurrentLocation {
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);
  }
}
