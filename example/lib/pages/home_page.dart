import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_finder/geo_finder.dart';

import '../widgets/permission_card.dart';
import '../widgets/location_card.dart';
import '../widgets/heading_card.dart';
import '../widgets/orientation_card.dart';
import '../widgets/stream_control_card.dart';
import '../widgets/error_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _geoFinder = GeoFinder();

  GeoLocation? _location;
  Heading? _heading;
  GeoDeviceOrientation? _orientation;
  bool _hasPermission = false;
  String _error = '';

  StreamSubscription<GeoLocation>? _locationSubscription;
  StreamSubscription<Heading>? _headingSubscription;
  StreamSubscription<GeoDeviceOrientation>? _orientationSubscription;

  bool _isStreaming = false;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('HomePage initState called');
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await _checkPermission();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _stopStreams();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    try {
      final hasPermission = await _geoFinder.checkLocationPermission();
      setState(() {
        _hasPermission = hasPermission;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _requestPermission() async {
    try {
      final granted = await _geoFinder.requestLocationPermission();
      setState(() {
        _hasPermission = granted;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _geoFinder.getCurrentLocation();
      setState(() {
        _location = location;
        _error = '';
      });
    } on PlatformException catch (e) {
      setState(() {
        _error = 'Location error: ${e.message}';
      });
    }
  }

  Future<void> _getHeading() async {
    try {
      final heading = await _geoFinder.getHeading();
      setState(() {
        _heading = heading;
        _error = '';
      });
    } on PlatformException catch (e) {
      setState(() {
        _error = 'Heading error: ${e.message}';
      });
    }
  }

  Future<void> _getOrientation() async {
    try {
      final orientation = await _geoFinder.getDeviceOrientation();
      setState(() {
        _orientation = orientation;
        _error = '';
      });
    } on PlatformException catch (e) {
      setState(() {
        _error = 'Orientation error: ${e.message}';
      });
    }
  }

  void _startStreams() {
    _locationSubscription = _geoFinder.getLocationStream().listen(
      (location) {
        setState(() {
          _location = location;
        });
      },
      onError: (e) {
        setState(() {
          _error = 'Location stream error: $e';
        });
      },
    );

    _headingSubscription = _geoFinder.getHeadingStream().listen(
      (heading) {
        setState(() {
          _heading = heading;
        });
      },
      onError: (e) {
        setState(() {
          _error = 'Heading stream error: $e';
        });
      },
    );

    _orientationSubscription = _geoFinder.getOrientationStream().listen(
      (orientation) {
        setState(() {
          _orientation = orientation;
        });
      },
      onError: (e) {
        setState(() {
          _error = 'Orientation stream error: $e';
        });
      },
    );

    setState(() {
      _isStreaming = true;
    });
  }

  void _stopStreams() {
    _locationSubscription?.cancel();
    _headingSubscription?.cancel();
    _orientationSubscription?.cancel();
    _locationSubscription = null;
    _headingSubscription = null;
    _orientationSubscription = null;

    setState(() {
      _isStreaming = false;
    });
  }

  void _toggleStreams() {
    if (_isStreaming) {
      _stopStreams();
    } else {
      _startStreams();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomePage build called, isInitialized: $_isInitialized');

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoFinder Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PermissionCard(
              hasPermission: _hasPermission,
              onRequestPermission: _requestPermission,
            ),
            const SizedBox(height: 16),
            LocationCard(
              location: _location,
              hasPermission: _hasPermission,
              onGetLocation: _getCurrentLocation,
            ),
            const SizedBox(height: 16),
            HeadingCard(
              heading: _heading,
              onGetHeading: _getHeading,
            ),
            const SizedBox(height: 16),
            OrientationCard(
              orientation: _orientation,
              onGetOrientation: _getOrientation,
            ),
            const SizedBox(height: 16),
            StreamControlCard(
              hasPermission: _hasPermission,
              isStreaming: _isStreaming,
              onToggleStreams: _toggleStreams,
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ErrorCard(error: _error),
              ),
          ],
        ),
      ),
    );
  }
}
