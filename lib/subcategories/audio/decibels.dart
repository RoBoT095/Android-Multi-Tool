import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';
import 'package:android_multi_tool/components/info_tile.dart';

const _quietColor = Color(0xFF4CAF50);
const _moderateColor = Color(0xFF2196F3);
const _loudColor = Color(0xFFFFC107);
const _veryLoudColor = Color(0xFFFF9800);
const _dangerousColor = Color(0xFFF44336);

class Decibels extends StatefulWidget {
  const Decibels({super.key});

  @override
  State<Decibels> createState() => _DecibelsState();
}

class _DecibelsState extends State<Decibels> {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _subscription;

  bool _isRecording = false;
  bool _permissionDenied = false;
  String? _error;

  double _current = 0;
  double _min = double.infinity;
  double _max = 0;
  double _sum = 0;
  int _count = 0;

  static const double _minDb = 0;
  static const double _maxDb = 120;

  double get _average => _count == 0 ? 0 : _sum / _count;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _isRecording = false;
      });
      return;
    }

    try {
      _noiseMeter ??= NoiseMeter();
      _subscription = _noiseMeter!.noise.listen(
        _onData,
        onError: _onError,
        cancelOnError: true,
      );
      if (!mounted) return;
      setState(() {
        _permissionDenied = false;
        _error = null;
        _isRecording = true;
      });
    } catch (e) {
      _onError(e);
    }
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _current = 0;
    });
  }

  void _onData(NoiseReading reading) {
    if (!mounted) return;
    final db = reading.meanDecibel;
    if (db.isNaN || db.isInfinite) return;
    setState(() {
      _current = db;
      if (db < _min) _min = db;
      if (db > _max) _max = db;
      _sum += db;
      _count++;
    });
  }

  void _onError(Object error) {
    if (!mounted) return;
    setState(() {
      _error = error.toString();
      _isRecording = false;
    });
  }

  void _reset() {
    setState(() {
      _min = double.infinity;
      _max = 0;
      _sum = 0;
      _count = 0;
      _current = 0;
    });
  }

  String get _levelLabel {
    if (_current >= 100) return 'Dangerous · Hearing Damage';
    if (_current >= 85) return 'Very Loud · Prolonged Exposure Harmful';
    if (_current >= 70) return 'Loud · Busy Street';
    if (_current >= 40) return 'Moderate · Conversation';
    return 'Quiet · Library';
  }

  Color get _levelColor {
    if (_current >= 100) return _dangerousColor;
    if (_current >= 85) return _veryLoudColor;
    if (_current >= 70) return _loudColor;
    if (_current >= 40) return _moderateColor;
    return _quietColor;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: titleAppBar(context, title: 'DECIBEL METER'),
      body: SafeArea(
        child: _permissionDenied
            ? _buildPermissionDenied()
            : (isLandscape ? _buildLandscape() : _buildPortrait()),
      ),
    );
  }

  Widget _buildPortrait() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Expanded(flex: 3, child: _buildGauge()),
          const SizedBox(height: 8),
          _buildLevelChip(),
          const SizedBox(height: 16),
          _buildInfoRow(),
          const SizedBox(height: 16),
          _buildControls(),
          const SizedBox(height: 16),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLevelChip(),
                  const SizedBox(height: 16),
                  _buildInfoRow(),
                  const SizedBox(height: 16),
                  _buildControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Microphone permission is required to measure sound levels.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _start,
              child: const Text('Grant Permission'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge() {
    const width = 0.08;
    return SfRadialGauge(
      enableLoadingAnimation: true,
      animationDuration: 1500,
      axes: <RadialAxis>[
        RadialAxis(
          minimum: _minDb,
          maximum: _maxDb,
          startAngle: 150,
          endAngle: 30,
          interval: 20,
          minorTicksPerInterval: 4,
          axisLineStyle: const AxisLineStyle(
            thickness: width,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.grey,
          ),
          majorTickStyle: MajorTickStyle(
            length: 0.12,
            lengthUnit: GaugeSizeUnit.factor,
            thickness: 2,
            color: Colors.grey[400],
          ),
          minorTickStyle: const MinorTickStyle(
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
            GaugeRange(
              startValue: 0,
              endValue: 40,
              color: _quietColor,
              startWidth: width,
              endWidth: width,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 40,
              endValue: 70,
              color: _moderateColor,
              startWidth: width,
              endWidth: width,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 70,
              endValue: 85,
              color: _loudColor,
              startWidth: width,
              endWidth: width,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 85,
              endValue: 100,
              color: _veryLoudColor,
              startWidth: width,
              endWidth: width,
              sizeUnit: GaugeSizeUnit.factor,
            ),
            GaugeRange(
              startValue: 100,
              endValue: _maxDb,
              color: _dangerousColor,
              startWidth: width,
              endWidth: width,
              sizeUnit: GaugeSizeUnit.factor,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: _current.clamp(_minDb, _maxDb),
              enableAnimation: true,
              animationType: AnimationType.easeOutBack,
              animationDuration: 300,
              needleColor: Colors.white,
              needleLength: 0.72,
              needleStartWidth: 1,
              needleEndWidth: 4,
              knobStyle: const KnobStyle(
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
                    _current.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'dB',
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

  Widget _buildLevelChip() {
    final color = _error != null ? _dangerousColor : _levelColor;
    final label = _error != null
        ? 'Microphone error'
        : (_isRecording ? _levelLabel : 'Paused');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    final minText = _count == 0 ? '--' : '${_min.toStringAsFixed(1)} dB';
    final avgText = _count == 0 ? '--' : '${_average.toStringAsFixed(1)} dB';
    final maxText = _count == 0 ? '--' : '${_max.toStringAsFixed(1)} dB';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InfoTile(label: 'Min', value: minText, icon: Icons.arrow_downward),
        const SizedBox(width: 12),
        InfoTile(label: 'Avg', value: avgText, icon: Icons.drag_handle),
        const SizedBox(width: 12),
        InfoTile(label: 'Max', value: maxText, icon: Icons.arrow_upward),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: _isRecording ? _stop : _start,
          icon: Icon(_isRecording ? Icons.pause : Icons.mic),
          label: Text(_isRecording ? 'Pause' : 'Start'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
