import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

const _veryLowPresColor = Color(0xFFF44336);
const _lowPresColor = Color(0xFFFF9800);
const _slightlyLowPresColor = Color(0xFFFFC107);
const _normalPresColor = Color(0xFF2196F3);
const _highPresColor = Color(0xFF4CAF50);

class Barometer extends StatefulWidget {
  const Barometer({super.key});

  @override
  State<Barometer> createState() => _BarometerState();
}

class _BarometerState extends State<Barometer> {
  StreamSubscription<BarometerEvent>? _subscription;

  // Standard sea-level pressure in hPa
  double _pressure = 1013.25;

  // Typical atmospheric pressure range (hPa)
  static const double _minPressure = 870.0;
  static const double _maxPressure = 1084.0;

  @override
  void initState() {
    super.initState();
    _subscription =
        barometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen((
          event,
        ) {
          setState(() {
            _pressure = event.pressure;
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Returns a human-readable weather condition based on pressure.
  String get _weatherCondition {
    if (_pressure >= 1022) return 'High Pressure · Clear';
    if (_pressure >= 1009) return 'Normal · Stable';
    if (_pressure >= 995) return 'Slightly Low · Cloudy';
    if (_pressure >= 980) return 'Low · Rain Likely';
    return 'Very Low · Storm Warning';
  }

  /// Returns a color matching the weather condition.
  Color get _conditionColor {
    if (_pressure >= 1022) return _highPresColor;
    if (_pressure >= 1009) return _normalPresColor;
    if (_pressure >= 995) return _slightlyLowPresColor;
    if (_pressure >= 980) return _lowPresColor;
    return _veryLowPresColor;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: titleAppBar(context, title: 'BAROMETER'),
      body: SafeArea(child: isLandscape ? _buildLandscape() : _buildPortrait()),
    );
  }

  Widget _buildPortrait() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Expanded(flex: 3, child: _buildGauge()),
          const SizedBox(height: 8),
          _buildConditionChip(),
          const SizedBox(height: 16),
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
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildConditionChip(),
                const SizedBox(height: 20),
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
          minimum: _minPressure,
          maximum: _maxPressure,
          startAngle: 150,
          endAngle: 30,
          interval: 50,
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
          ranges: <GaugeRange>[
            // Storm / Very Low
            GaugeRange(
              startValue: _minPressure,
              endValue: 980,
              color: _veryLowPresColor,
              startWidth: 0.08,
              endWidth: 0.08,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            // Low
            GaugeRange(
              startValue: 980,
              endValue: 995,
              color: _lowPresColor,
              startWidth: 0.08,
              endWidth: 0.08,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            // Slightly Low
            GaugeRange(
              startValue: 995,
              endValue: 1009,
              color: _slightlyLowPresColor,
              startWidth: 0.08,
              endWidth: 0.08,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            // Normal
            GaugeRange(
              startValue: 1009,
              endValue: 1022,
              color: _normalPresColor,
              startWidth: 0.08,
              endWidth: 0.08,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            // High
            GaugeRange(
              startValue: 1022,
              endValue: _maxPressure,
              color: _highPresColor,
              startWidth: 0.08,
              endWidth: 0.08,
              sizeUnit: GaugeSizeUnit.factor,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: _pressure.clamp(_minPressure, _maxPressure),
              enableAnimation: true,
              animationType: AnimationType.easeOutBack,
              animationDuration: 800,
              needleColor: Colors.white,
              needleLength: 0.72,
              needleStartWidth: 1,
              needleEndWidth: 4,
              knobStyle: KnobStyle(
                knobRadius: 0.01,
                sizeUnit: GaugeSizeUnit.factor,
                color: Colors.white,
                borderColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                borderWidth: 2,
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
                    _pressure.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'hPa',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      letterSpacing: 2,
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

  Widget _buildConditionChip() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _conditionColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _conditionColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: _conditionColor),
          const SizedBox(width: 8),
          Text(
            _weatherCondition,
            style: TextStyle(
              color: _conditionColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoTile('Sea Level', '1013.25 hPa', Icons.water),
        const SizedBox(width: 16),
        _infoTile(
          'Delta',
          '${(_pressure - 1013.25).toStringAsFixed(1)} hPa',
          Icons.swap_vert,
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
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
      ),
    );
  }
}
