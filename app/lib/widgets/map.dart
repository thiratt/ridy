import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:app/utils/env.dart';
import 'package:app/widgets/location_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;

class RidyMapController extends ChangeNotifier {
  _RidyMapState? _mapState;

  void _attach(_RidyMapState mapState) {
    _mapState = mapState;
  }

  void _detach() {
    _mapState = null;
  }

  LatLng? get center => _mapState?._mapController.camera.center;
  double? get zoom => _mapState?._mapController.camera.zoom;
  LatLng? get userLocation => _mapState?._lastReal;
  bool get isFollowingUser => _mapState?._followUser ?? false;
  String get locationStatus => _mapState?._locationStatus ?? 'Unknown';

  Future<void> animateToLocation(
    LatLng location, {
    double? zoom,
    Duration? duration,
  }) async {
    if (_mapState == null) {
      throw StateError('RidyMapController is not attached to a map widget');
    }

    final targetZoom = zoom ?? _mapState!._mapController.camera.zoom;
    _mapState!._animatedMapMove(
      location,
      targetZoom,
      overrideDuration: duration,
    );
  }

  void setCenter(LatLng location, {double? zoom}) {
    if (_mapState == null) {
      throw StateError('RidyMapController is not attached to a map widget');
    }

    final targetZoom = zoom ?? _mapState!._mapController.camera.zoom;
    _mapState!._mapController.move(location, targetZoom);
  }

  void setFollowUser(bool follow) {
    if (_mapState == null) {
      throw StateError('RidyMapController is not attached to a map widget');
    }

    _mapState!._setFollowUser(follow);

    if (follow && _mapState!._lastReal != null) {
      animateToLocation(_mapState!._lastReal!);
    }

    notifyListeners();
  }

  void toggleFollowUser() {
    setFollowUser(!isFollowingUser);
  }

  Future<void> moveToUserLocation() async {
    if (_mapState?._lastReal != null) {
      await animateToLocation(
        _mapState!._lastReal!,
        zoom: _mapState!._mapController.camera.zoom.clamp(16, 18),
      );
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }
}

class RidyMapConfig {
  final LatLng defaultCenter;
  final double defaultZoom;
  final double maxZoom;
  final double minZoom;
  final LocationAccuracy locationAccuracy;
  final Duration locationTimeout;
  final String userAgentPackageName;
  final String tileUrlTemplate;
  final bool showFloatingButtons;
  final bool enableFollowUser;
  final Duration animationDuration;

  RidyMapConfig({
    this.defaultCenter = const LatLng(13.736717, 100.523186),
    this.defaultZoom = 16.0,
    this.maxZoom = 20.0,
    this.minZoom = 5.0,
    this.locationAccuracy = LocationAccuracy.high,
    this.locationTimeout = const Duration(seconds: 10),
    this.userAgentPackageName = 'app.ridy',
    String? tileUrlTemplate,
    this.showFloatingButtons = false,
    this.enableFollowUser = false,
    this.animationDuration = const Duration(milliseconds: 250),
  }) : tileUrlTemplate =
           tileUrlTemplate ??
           'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png';
}

class RidyMapStatusMessages {
  static const String initializing = 'กำลังเริ่มต้นระบบตำแหน่ง';
  static const String locationServiceDisabled =
      'บริการตำแหน่งถูกปิดอยู่ กรุณาเปิดใช้งานในการตั้งค่า';
  static const String permissionDenied = 'ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง';
  static const String permissionDeniedForever =
      'การเข้าถึงตำแหน่งถูกปฏิเสธถาวร กรุณาตั้งค่าในระบบ';
  static const String generalLocationError = 'เกิดข้อผิดพลาดในการหาตำแหน่ง';
}

enum RidyMapStatus {
  initializing,
  permissionDenied,
  permissionDeniedForever,
  locationServiceDisabled,
  active,
  error,
}

class RidyMapStatusCallback {
  final RidyMapStatus status;
  final String message;

  RidyMapStatusCallback(this.status, this.message);
}

class RidyMap extends StatefulWidget {
  final RidyMapConfig config;
  final Function(RidyMapStatusCallback status)? onStatusChanged;
  final Function(LatLng)? onLocationChanged;
  final List<Marker>? additionalMarkers;
  final List<Widget>? additionalLayers;
  final Widget? customLocationMarker;
  final RidyMapController? controller;

  RidyMap({
    super.key,
    RidyMapConfig? config,
    this.onStatusChanged,
    this.onLocationChanged,
    this.additionalMarkers,
    this.additionalLayers,
    this.customLocationMarker,
    this.controller,
  }) : config = config ?? RidyMapConfig();

  @override
  State<RidyMap> createState() => _RidyMapState();
}

class _RidyMapState extends State<RidyMap> with TickerProviderStateMixin {
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  final MapController _mapController = MapController();

  bool _followUser = false;
  String _locationStatus = 'Initializing';

  LatLng? _lastReal;
  double _headingTarget = 0;

  LatLng? _markerShown;
  double _headingShown = 0;

  LatLng? _markerFrom;
  LatLng? _markerTo;
  double _headingFrom = 0;
  bool _isMapReady = false;

  late AnimationController _markerCtrl;
  late Animation<double> _markerAnim;

  AnimationController? _moveC;

  Timer? _locationTimer;

  loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  void _notifyStatusChange(RidyMapStatus status, String message) {
    if (mounted) {
      setState(() {
        _locationStatus = message;
      });
    }
    widget.onStatusChanged?.call(RidyMapStatusCallback(status, message));
  }

  String get locationStatus => _locationStatus;

  Future<void> _initLocationPackage() async {
    _notifyStatusChange(
      RidyMapStatus.initializing,
      RidyMapStatusMessages.initializing,
    );

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _notifyStatusChange(
          RidyMapStatus.locationServiceDisabled,
          RidyMapStatusMessages.locationServiceDisabled,
        );
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        _notifyStatusChange(
          RidyMapStatus.permissionDenied,
          RidyMapStatusMessages.permissionDenied,
        );
        return;
      }
    }

    await location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 1,
      distanceFilter: 0.0,
    );

    try {
      final locationData = await location.getLocation();
      final first = LatLng(locationData.latitude!, locationData.longitude!);
      _onNewLocationData(locationData);
      _mapController.move(first, 17);
      _notifyStatusChange(RidyMapStatus.active, 'Location tracking active');
      setState(() {
        _isMapReady = true;
      });
    } catch (e) {
      _notifyStatusChange(
        RidyMapStatus.error,
        RidyMapStatusMessages.generalLocationError,
      );
      return;
    }

    _locationSubscription?.cancel();
    _locationSubscription = location.onLocationChanged.listen(
      (loc.LocationData locationData) {
        _onNewLocationData(locationData);
      },
      onError: (error) {
        log('Location stream error: $error');
        setState(() => _locationStatus = 'Stream error: $error');

        // Restart
        if (mounted) {
          Future.delayed(
            const Duration(seconds: 1),
            () => _initLocationPackage(),
          );
        }
      },
    );
  }

  void _onNewLocationData(loc.LocationData locationData) {
    if (locationData.latitude == null || locationData.longitude == null) return;

    final next = LatLng(locationData.latitude!, locationData.longitude!);
    final heading = locationData.heading;
    _onNewLocation(next, heading: heading);
  }

  @override
  void initState() {
    super.initState();
    _initSmoother();
    _initLocationPackage();

    widget.controller?._attach(this);

    if (widget.config.enableFollowUser) {
      _followUser = true;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();

    _markerCtrl.dispose();
    _moveC?.dispose();
    _locationSubscription?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  void _setFollowUser(bool follow) {
    setState(() {
      _followUser = follow;
    });
  }

  void _initSmoother() {
    _markerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _markerAnim = CurvedAnimation(parent: _markerCtrl, curve: Curves.easeOut);

    _markerAnim.addListener(() {
      if (_markerFrom == null || _markerTo == null) return;
      final t = _markerAnim.value;
      final cur = _lerpLatLng(_markerFrom!, _markerTo!, t);
      final head = _lerpAngleShortest(_headingFrom, _headingTarget, t);
      setState(() {
        _markerShown = cur;
        _headingShown = head;
      });
    });
  }

  void _onNewLocation(LatLng next, {double? heading}) {
    if (_markerShown != null) {
      final jump = const Distance().as(LengthUnit.Meter, _markerShown!, next);
      if (jump < 0.5) return;
    }

    _lastReal = next;

    widget.onLocationChanged?.call(next);

    if (heading != null && heading >= 0) {
      _headingTarget = heading;
    } else if (_markerShown != null) {
      _headingTarget = _bearing(_markerShown!, next);
    }

    if (_markerShown == null) {
      setState(() {
        _markerShown = next;
        _markerFrom = next;
        _markerTo = next;
        _headingShown = _headingTarget;
        _headingFrom = _headingTarget;
      });
      return;
    }

    _markerFrom = _markerShown!;
    _markerTo = next;
    _headingFrom = _headingShown;

    _markerCtrl.duration = _durationForDistance(_markerFrom!, _markerTo!);
    _markerCtrl.forward(from: 0);

    if (_followUser) {
      _animatedMapMove(
        next,
        _mapController.camera.zoom,
        overrideDuration: _markerCtrl.duration,
      );
    }
  }

  void _animatedMapMove(
    LatLng dest,
    double destZoom, {
    Duration? overrideDuration,
  }) {
    _moveC?.stop();
    _moveC?.dispose();

    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: dest.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: dest.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final c = AnimationController(
      duration: overrideDuration ?? const Duration(milliseconds: 250),
      vsync: this,
    );
    _moveC = c;

    final anim = CurvedAnimation(parent: c, curve: Curves.easeOut);
    final startId = '$_startedId#${dest.latitude},${dest.longitude},$destZoom';
    bool started = false;

    c.addListener(() {
      final id = anim.value == 1.0
          ? _finishedId
          : (!started ? startId : _inProgressId);
      started |= _mapController.move(
        LatLng(latTween.evaluate(anim), lngTween.evaluate(anim)),
        zoomTween.evaluate(anim),
        id: id,
      );
    });

    c.addStatusListener((s) {
      if (s == AnimationStatus.completed || s == AnimationStatus.dismissed) {
        c.dispose();
        if (identical(_moveC, c)) _moveC = null;
      }
    });

    c.forward();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _markerShown;
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            maxZoom: widget.config.maxZoom,
            minZoom: widget.config.minZoom,
            initialCenter: shown ?? widget.config.defaultCenter,
            initialZoom: shown == null
                ? widget.config.defaultZoom - 4
                : widget.config.defaultZoom + 1,
            onMapEvent: (evt) {
              if (evt.source == MapEventSource.onDrag ||
                  evt.source == MapEventSource.onMultiFinger) {
                if (_followUser) setState(() => _followUser = false);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  '${widget.config.tileUrlTemplate}?apikey=${getEnv('THUNDER_FOREST_API_KEY')}',
              userAgentPackageName: widget.config.userAgentPackageName,
            ),
            if (shown != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: shown,
                    width: 50,
                    height: 50,
                    child: const CurrentLocationDot(),
                  ),
                  if (widget.additionalMarkers != null)
                    ...widget.additionalMarkers!,
                ],
              ),
            if (widget.additionalLayers != null) ...widget.additionalLayers!,
          ],
        ),

        AnimatedOpacity(
          opacity: _isMapReady ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: _isMapReady,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'กำลังค้นหาตำแหน่ง...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LatLng _lerpLatLng(LatLng a, LatLng b, double t) => LatLng(
    lerpDouble(a.latitude, b.latitude, t)!,
    lerpDouble(a.longitude, b.longitude, t)!,
  );

  double _lerpAngleShortest(double a, double b, double t) {
    double norm(double x) => (x % 360 + 360) % 360;
    a = norm(a);
    b = norm(b);
    var d = b - a;
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return norm(a + d * t);
  }

  double _bearing(LatLng a, LatLng b) {
    double rad(double d) => d * math.pi / 180.0;
    double deg(double r) => r * 180.0 / math.pi;
    final a1 = rad(a.latitude), a2 = rad(b.latitude);
    final a3 = rad(b.longitude - a.longitude);
    final y = math.sin(a3) * math.cos(a2);
    final x =
        math.cos(a1) * math.sin(a2) -
        math.sin(a1) * math.cos(a2) * math.cos(a3);
    final a4 = math.atan2(y, x);
    return (deg(a4) + 360.0) % 360.0;
  }

  Duration _durationForDistance(LatLng from, LatLng to) {
    final meters = const Distance().as(LengthUnit.Meter, from, to);
    final ms = (meters * 2 + 100).clamp(100, 400).toInt();
    return Duration(milliseconds: ms);
  }
}
