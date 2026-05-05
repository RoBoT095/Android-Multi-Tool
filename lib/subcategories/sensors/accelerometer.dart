import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

const _colorX = Color(0xFFFF4D6D);
const _colorY = Color(0xFF00FFB2);
const _colorZ = Color(0xFF4D9FFF);

class Accelerometer extends StatefulWidget {
  const Accelerometer({super.key});

  @override
  State<Accelerometer> createState() => _AccelerometerState();
}

class _AccelerometerState extends State<Accelerometer> {
  StreamSubscription<AccelerometerEvent>? _subscription;

  double _x = 0, _y = 0, _z = 0;

  static const int _maxPoints = 80;
  final List<double> _xHistory = [];
  final List<double> _yHistory = [];
  final List<double> _zHistory = [];

  bool _showX = true, _showY = true, _showZ = true;

  @override
  void initState() {
    super.initState();
    _subscription =
        accelerometerEventStream(
          samplingPeriod: SensorInterval.uiInterval,
        ).listen((event) {
          setState(() {
            _x = event.x;
            _y = event.y;
            _z = event.z;
            _xHistory.add(_x);
            _yHistory.add(_y);
            _zHistory.add(_z);
            if (_xHistory.length > _maxPoints) {
              _xHistory.removeAt(0);
              _yHistory.removeAt(0);
              _zHistory.removeAt(0);
            }
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: titleAppBar(context, title: 'ACCELEROMETER'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: isLandscape ? _buildLandscape() : _buildPortrait(),
        ),
      ),
    );
  }

  Widget _buildPortrait() => Column(
    children: [
      const SizedBox(height: 8),
      _buildReadoutRow(),
      const SizedBox(height: 12),
      _buildTiltBall(fixedHeight: 170),
      const SizedBox(height: 10),
      _buildAxisToggles(),
      const SizedBox(height: 6),
      Expanded(child: _buildGraph()),
      const SizedBox(height: 12),
    ],
  );

  Widget _buildLandscape() => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        width: 210,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 10),
          child: Column(
            children: [
              Expanded(child: _buildTiltBall()),
              const SizedBox(height: 6),
              _buildReadoutCompact(),
            ],
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 10, 10),
          child: Column(
            children: [
              _buildAxisToggles(),
              const SizedBox(height: 6),
              Expanded(child: _buildGraph()),
            ],
          ),
        ),
      ),
    ],
  );

  // Readout: portrait

  Widget _buildReadoutRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        _valueCard('X', _x, _colorX),
        const SizedBox(width: 8),
        _valueCard('Y', _y, _colorY),
        const SizedBox(width: 8),
        _valueCard('Z', _z, _colorZ),
      ],
    ),
  );

  Widget _valueCard(String axis, double value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            axis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 3),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value.toStringAsFixed(3),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: ' m/s²',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11, // smaller
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (value.clamp(-10.0, 10.0) + 10) / 20,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 2,
            ),
          ),
        ],
      ),
    ),
  );

  // Readout: landscape

  Widget _buildReadoutCompact() => Column(
    children: [
      _valueRow('X', _x, _colorX),
      const SizedBox(height: 5),
      _valueRow('Y', _y, _colorY),
      const SizedBox(height: 5),
      _valueRow('Z', _z, _colorZ),
    ],
  );

  Widget _valueRow(String axis, double value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        Text(
          axis,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value.toStringAsFixed(3),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: ' m/s²',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11, // smaller
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (value.clamp(-10.0, 10.0) + 10) / 20,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTiltBall({double? fixedHeight}) {
    final arena = LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const ballR = 14.0;
        final maxDx = w / 2 - ballR - 4;
        final maxDy = h / 2 - ballR - 4;
        final dx = (_y / 10).clamp(-1.0, 1.0) * maxDx;
        final dy = (_x / 10).clamp(-1.0, 1.0) * maxDy;

        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: Size(w, h), painter: _GridPainter()),
            Icon(Icons.add, color: Colors.white, size: 18),
            Transform.translate(
              offset: Offset(dx, dy),
              child: Container(
                width: ballR * 2,
                height: ballR * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.55),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 8,
              left: 10,
              child: Text(
                'TILT',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        );
      },
    );

    final deco = BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.surface),
    );

    if (fixedHeight != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: fixedHeight,
        decoration: deco,
        child: ClipRRect(borderRadius: BorderRadius.circular(14), child: arena),
      );
    }

    return Container(
      decoration: deco,
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: arena),
    );
  }

  // Axis toggles
  Widget _buildAxisToggles() => Row(
    children: [
      const Text(
        'AXES',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 9,
          letterSpacing: 3,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 10),
      _toggle('X', _colorX, _showX, (v) => setState(() => _showX = v)),
      const SizedBox(width: 6),
      _toggle('Y', _colorY, _showY, (v) => setState(() => _showY = v)),
      const SizedBox(width: 6),
      _toggle('Z', _colorZ, _showZ, (v) => setState(() => _showZ = v)),
    ],
  );

  /// Toggle for graph axes (x, y, z)
  Widget _toggle(
    String label,
    Color color,
    bool on,
    ValueChanged<bool> onChange,
  ) => GestureDetector(
    onTap: () => onChange(!on),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: on ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: on ? color.withValues(alpha: 0.6) : Colors.grey,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: on ? color : Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),
  );

  Widget _buildGraph() => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.surface),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GraphPainter(
                xData: _showX ? _xHistory : [],
                yData: _showY ? _yHistory : [],
                zData: _showZ ? _zHistory : [],
                maxPoints: _maxPoints,
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_yLabel('+10'), _yLabel('0'), _yLabel('-10')],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _yLabel(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 8,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    ),
  );
}

// Painters

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    for (int i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}

class _GraphPainter extends CustomPainter {
  final List<double> xData, yData, zData;
  final int maxPoints;

  static const double _min = -10, _max = 10;

  const _GraphPainter({
    required this.xData,
    required this.yData,
    required this.zData,
    required this.maxPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final zeroY = _toY(0, size.height);
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1,
    );

    _series(canvas, size, xData, _colorX);
    _series(canvas, size, yData, _colorY);
    _series(canvas, size, zData, _colorZ);
  }

  void _series(Canvas canvas, Size size, List<double> data, Color color) {
    if (data.length < 2) return;
    const lp = 26.0;
    final uw = size.width - lp;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = lp + (i / (maxPoints - 1)) * uw;
      final y = _toY(data[i], size.height);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
  }

  double _toY(double v, double h) =>
      h * (1 - ((v - _min) / (_max - _min)).clamp(0.0, 1.0));

  @override
  bool shouldRepaint(_GraphPainter o) =>
      xData != o.xData || yData != o.yData || zData != o.zData;
}
