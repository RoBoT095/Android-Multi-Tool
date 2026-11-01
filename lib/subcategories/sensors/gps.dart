import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';
import 'package:android_multi_tool/widgets/permission_denied.dart';
import 'package:android_multi_tool/components/info_tile.dart';

const _lowSpeedColor = Color(0xFF4CAF50);
const _medSpeedColor = Color(0xFFFFC107);
const _highSpeedColor = Color(0xFFF44336);

class GPS extends StatefulWidget {
  const GPS({super.key});

  @override
  State<GPS> createState() => _GPSState();
}

class _GPSState extends State<GPS> {
  StreamSubscription<Position>? _subscription;

  bool _permissionDenied = false;
  bool _permanentlyDenied = false;

  double _speedKmh = 0.0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _altitude = 0.0;
  double _accuracy = 0.0;
  double _heading = 0.0;
  bool _isLoading = true;
  bool _useMph = true;

  static const double _maxSpeedKmh = 180.0;
  static const double _maxSpeedMph = 120.0;

  double get _displaySpeed => _useMph ? _speedKmh * 0.621371 : _speedKmh;
  double get _maxSpeed => _useMph ? _maxSpeedMph : _maxSpeedKmh;
  String get _speedUnit => _useMph ? 'mph' : 'km/h';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _isLoading = false;
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _permanentlyDenied = permission == LocationPermission.deniedForever;
        _permissionDenied = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });

    LocationSettings settings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      intervalDuration: const Duration(milliseconds: 500),
      forceLocationManager: true,
    );

    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position position) {
          setState(() {
            _speedKmh = (position.speed < 0 ? 0 : position.speed) * 3.6;
            _latitude = position.latitude;
            _longitude = position.longitude;
            _altitude = position.altitude;
            _accuracy = position.accuracy;
            _heading = position.heading;
          });
        });
  }

  String _cardinalHeading(double degrees) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((degrees + 22.5) / 45).floor() % 8;
    return dirs[idx];
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: titleAppBar(
        context,
        title: 'GPS',
        actions: _permissionDenied
            ? []
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _useMph = !_useMph),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[700]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'mph',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _useMph ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('|', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(width: 6),
                          Text(
                            'km/h',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: !_useMph ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _permissionDenied
            ? permissionDenied(
                icon: Icons.location_off,
                message: _permanentlyDenied
                    ? 'Location permission was permanently denied. Enable it in app settings.'
                    : 'Location permission denied.',
                onPressed: () {
                  _initLocation();
                },
              )
            : isLandscape
            ? _buildLandscape()
            : _buildPortrait(),
      ),
    );
  }

  Widget _buildPortrait() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Expanded(flex: 3, child: _buildGauge()),
          Text(
            'Precise location is required to get an accurate speed.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildCoordinatesCard(),
          const SizedBox(height: 12),
          _buildInfoRow(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLandscape() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 5, child: _buildGauge()),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Precise location is required to get an accurate speed.',
                  style: TextStyle(color: Colors.grey),
                ),
                _buildCoordinatesCard(),
                const SizedBox(height: 12),
                _buildInfoRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge() {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      animationDuration: 1500,
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: _maxSpeed,
          startAngle: 150,
          endAngle: 30,
          interval: _useMph ? 20 : 20,
          minorTicksPerInterval: 4,
          axisLineStyle: AxisLineStyle(
            thickness: 0.08,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.grey,
          ),
          majorTickStyle: MajorTickStyle(
            length: 0.12,
            lengthUnit: GaugeSizeUnit.factor,
            thickness: 2,
            color: Colors.grey[400],
          ),
          minorTickStyle: MinorTickStyle(
            length: 0.06,
            lengthUnit: GaugeSizeUnit.factor,
            thickness: 1,
            color: Colors.grey,
          ),
          axisLabelStyle: GaugeTextStyle(
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
          ranges: _useMph
              ? <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: 40,
                    color: _lowSpeedColor,
                    startWidth: 0.08,
                    endWidth: 0.08,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                  GaugeRange(
                    startValue: 40,
                    endValue: 80,
                    color: _medSpeedColor,
                    startWidth: 0.08,
                    endWidth: 0.08,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                  GaugeRange(
                    startValue: 80,
                    endValue: _maxSpeedMph,
                    color: _highSpeedColor,
                    startWidth: 0.08,
                    endWidth: 0.08,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                ]
              : <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: 60,
                    color: _lowSpeedColor,
                    startWidth: 0.08,
                    endWidth: 0.08,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                  GaugeRange(
                    startValue: 60,
                    endValue: 120,
                    color: _medSpeedColor,
                    startWidth: 0.08,
                    endWidth: 0.08,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                  GaugeRange(
                    startValue: 120,
                    endValue: _maxSpeedKmh,
                    color: _highSpeedColor,
                    startWidth: 0.08,
                    endWidth: 0.08,
                    sizeUnit: GaugeSizeUnit.factor,
                  ),
                ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: _displaySpeed.clamp(0, _maxSpeed),
              enableAnimation: true,
              animationType: AnimationType.easeOutBack,
              animationDuration: 600,
              needleColor: Colors.white,
              needleLength: 0.72,
              needleStartWidth: 1,
              needleEndWidth: 4,
              knobStyle: KnobStyle(
                sizeUnit: GaugeSizeUnit.factor,
                color: Colors.white,
              ),
              tailStyle: const TailStyle(
                length: 0.12,
                lengthUnit: GaugeSizeUnit.factor,
                width: 3,
              ),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              angle: 90,
              positionFactor: 0.55,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _displaySpeed.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _speedUnit,
                      key: ValueKey(_speedUnit),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordinatesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _coordItem(Icons.location_on, 'LAT', _latitude.toStringAsFixed(6)),
          Container(width: 1, height: 36, color: Colors.grey[700]),
          _coordItem(
            Icons.location_on_outlined,
            'LON',
            _longitude.toStringAsFixed(6),
          ),
        ],
      ),
    );
  }

  Widget _coordItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InfoTile(
          label: 'Altitude',
          value: '${_altitude.toStringAsFixed(1)} m',
          icon: Icons.terrain,
        ),
        const SizedBox(width: 12),
        InfoTile(
          label: 'Heading',
          value:
              '${_heading.toStringAsFixed(0)}° ${_cardinalHeading(_heading)}',
          icon: Icons.explore,
        ),
        const SizedBox(width: 12),
        InfoTile(
          label: 'Accuracy',
          value: '±${_accuracy.toStringAsFixed(1)} m',
          icon: Icons.gps_fixed,
        ),
      ],
    );
  }
}
