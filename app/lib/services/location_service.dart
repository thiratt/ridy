import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../models/delivery.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return position;
    } catch (e) {
      log('Error getting location: $e');
      return null;
    }
  }

  static Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      await setLocaleIdentifier("th_TH");
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        List<String> addressParts = [];

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.join(', ');
      }

      return 'ไม่สามารถระบุตำแหน่งได้';
    } catch (e) {
      log('Error getting address: $e');
      return 'ไม่สามารถระบุตำแหน่งได้';
    }
  }

  static Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      Position? position = await getCurrentLocation();
      if (position == null) return null;

      String address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      log('Error getting location with address: $e');
      return null;
    }
  }
}

class DeliveryService {
  static const String _baseUrl = 'http://100.69.213.128:5200';

  static Future<List<Delivery>> getUserDeliveries(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'Success' &&
            responseData['data'] != null) {
          List<dynamic> deliveriesJson = responseData['data'];
          return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
        } else {
          log('API returned error: ${responseData['message']}');
          return [];
        }
      } else {
        log('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching deliveries: $e');
      return [];
    }
  }

  static Future<List<Delivery>> getSentDeliveries(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery/sent/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'Success' &&
            responseData['data'] != null) {
          List<dynamic> deliveriesJson = responseData['data'];
          return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('Error fetching sent deliveries: $e');
      return [];
    }
  }

  static Future<List<Delivery>> getReceivedDeliveries(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery/received/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'Success' &&
            responseData['data'] != null) {
          List<dynamic> deliveriesJson = responseData['data'];
          return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('Error fetching received deliveries: $e');
      return [];
    }
  }

  static Future<List<Delivery>> getDeliveriesByStatus(
    String userId,
    String status,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery/user/$userId/status/$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'Success' &&
            responseData['data'] != null) {
          List<dynamic> deliveriesJson = responseData['data'];
          return deliveriesJson.map((json) => Delivery.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('Error fetching deliveries by status: $e');
      return [];
    }
  }
}
