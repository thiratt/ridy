import 'dart:developer';
import 'package:app/utils/env.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/location_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class _LocationConfig {
  static const LatLng defaultCenter = LatLng(13.736717, 100.523186);

  static const double defaultZoom = 16.0;
  static const double recenterZoom = 17.0;

  static const double crosshairSize = 14.0;
  static const double crosshairBorderWidth = 3.0;
  static const double fabBottomOffset = 88.0;
  static const double contentPadding = 16.0;
  static const double markerSize = 20.0;

  static const LocationAccuracy locationAccuracy = LocationAccuracy.high;
  static const Duration locationTimeout = Duration(seconds: 10);

  static const String localeIdentifier = "th_TH";
  static const String userAgentPackageName = 'app.ridy';

  static String tileUrlTemplate =
      'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=${getEnv('THUNDER_FOREST_API_KEY')}';
}

class _LocationErrorMessages {
  static const String locationServiceDisabled =
      'บริการตำแหน่งถูกปิดอยู่ กรุณาเปิดใช้งานในการตั้งค่า';
  static const String permissionDenied = 'ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง';
  static const String permissionDeniedForever =
      'การเข้าถึงตำแหน่งถูกปฏิเสธถาวร กรุณาตั้งค่าในระบบ';
  static const String geocodingFailed = 'ไม่สามารถค้นหาที่อยู่ได้';
  static const String generalLocationError = 'เกิดข้อผิดพลาดในการหาตำแหน่ง';
}

class _LocationTexts {
  static const String appBarTitle = 'เลือกที่อยู่';
  static const String confirmButton = 'ยืนยันตำแหน่ง';
  static const String recenterTooltip = 'กลับไปยังตำแหน่งของฉัน';
  static const String crosshairSemantic = 'ตำแหน่งที่เลือก';
  static const String mapSemantic = 'แผนที่สำหรับเลือกตำแหน่ง';
}

class SelectedLocation {
  final double lat;
  final double lng;
  final String? address;

  const SelectedLocation({required this.lat, required this.lng, this.address});

  @override
  String toString() =>
      'SelectedLocation(lat: $lat, lng: $lng, address: $address)';

  bool get isValid => lat.abs() <= 90 && lng.abs() <= 180;
}

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  final _mapController = MapController();
  LatLng _center = _LocationConfig.defaultCenter;
  LatLng? _currentUserLocation;
  double _zoom = _LocationConfig.defaultZoom;
  bool _isLoadingLocation = false;
  bool _isConfirmingLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      await _requestLocationAndUpdateMap();
    } catch (e) {
      log('Location initialization failed: $e');
      if (mounted) {
        setState(() {
          _errorMessage = _LocationErrorMessages.generalLocationError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _requestLocationAndUpdateMap() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(_LocationErrorMessages.locationServiceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(_LocationErrorMessages.permissionDenied);
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(_LocationErrorMessages.permissionDeniedForever);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: _LocationConfig.locationAccuracy,
      ),
    ).timeout(_LocationConfig.locationTimeout);

    final userLocation = LatLng(position.latitude, position.longitude);
    if (!_isValidCoordinate(userLocation)) {
      throw Exception('Invalid coordinates received');
    }

    if (mounted) {
      setState(() {
        _currentUserLocation = userLocation;
        _center = userLocation;
      });

      _mapController.move(_center, _LocationConfig.defaultZoom);
    }
  }

  bool _isValidCoordinate(LatLng location) {
    return location.latitude.abs() <= 90 &&
        location.longitude.abs() <= 180 &&
        location.latitude != 0 &&
        location.longitude != 0;
  }

  Future<void> _recenterToUserLocation() async {
    if (_currentUserLocation == null) {
      await _initializeLocation();
    } else {
      _mapController.move(_currentUserLocation!, _LocationConfig.recenterZoom);
    }
  }

  Future<void> _confirmSelectedLocation() async {
    if (!mounted) return;

    setState(() {
      _isConfirmingLocation = true;
      _errorMessage = null;
    });

    try {
      final selectedCenter = _mapController.camera.center;

      if (!_isValidCoordinate(selectedCenter)) {
        throw Exception('ตำแหน่งที่เลือกไม่ถูกต้อง');
      }

      String? addressLine;
      try {
        addressLine = await _getAddressFromCoordinates(selectedCenter);
      } catch (e) {
        log('Geocoding failed: $e');
      }

      final selectedLocation = SelectedLocation(
        lat: selectedCenter.latitude,
        lng: selectedCenter.longitude,
        address: addressLine,
      );

      if (mounted) {
        Navigator.pop(context, selectedLocation);
      }
    } catch (e) {
      log('Location confirmation failed: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirmingLocation = false;
        });
      }
    }
  }

  Future<String?> _getAddressFromCoordinates(LatLng coordinates) async {
    try {
      await setLocaleIdentifier(_LocationConfig.localeIdentifier);

      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      log('Reverse geocoding result: $placemarks');

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final addressParts = [
          placemark.name,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
          placemark.postalCode,
        ].where((part) => part != null && part.trim().isNotEmpty);

        return addressParts.join(' ');
      }
    } catch (e) {
      log('Reverse geocoding error: $e');
      throw Exception(_LocationErrorMessages.geocodingFailed);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _LocationTexts.appBarTitle,
          semanticsLabel: _LocationTexts.appBarTitle,
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Semantics(
            label: _LocationTexts.mapSemantic,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _zoom,
                onPositionChanged: (position, hasGesture) {
                  _center = position.center;
                  _zoom = position.zoom;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _LocationConfig.tileUrlTemplate,
                  userAgentPackageName: _LocationConfig.userAgentPackageName,
                ),
                if (_currentUserLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentUserLocation!,
                        width: _LocationConfig.markerSize,
                        height: _LocationConfig.markerSize,
                        child: Semantics(
                          label: 'ตำแหน่งปัจจุบันของคุณ',
                          child: const CurrentLocationDot(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          IgnorePointer(
            child: Center(
              child: Semantics(
                label: _LocationTexts.crosshairSemantic,
                child: Container(
                  width: _LocationConfig.crosshairSize,
                  height: _LocationConfig.crosshairSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: _LocationConfig.crosshairBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoadingLocation)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        _LocationConfig.contentPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'กำลังค้นหาตำแหน่ง...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (_errorMessage != null)
            Positioned(
              top: _LocationConfig.contentPadding,
              left: _LocationConfig.contentPadding,
              right: _LocationConfig.contentPadding,
              child: Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(_LocationConfig.contentPadding),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        onPressed: () => setState(() => _errorMessage = null),
                        tooltip: 'ปิด',
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            right: _LocationConfig.contentPadding,
            bottom: _LocationConfig.fabBottomOffset + bottom,
            child: FloatingActionButton(
              onPressed: _isLoadingLocation ? null : _recenterToUserLocation,
              heroTag: 'recenter',
              tooltip: _LocationTexts.recenterTooltip,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_outlined),
            ),
          ),

          Positioned(
            left: _LocationConfig.contentPadding,
            right: _LocationConfig.contentPadding,
            bottom: _LocationConfig.contentPadding + bottom,
            child: PrimaryButton(
              text: _isConfirmingLocation
                  ? 'กำลังยืนยันตำแหน่ง...'
                  : _LocationTexts.confirmButton,
              onPressed: _confirmSelectedLocation,
              disabled: _isLoadingLocation || _isConfirmingLocation,
            ),
          ),
        ],
      ),
    );
  }
}
