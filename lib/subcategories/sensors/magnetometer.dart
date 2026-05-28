import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

class Magnetometer extends StatefulWidget {
  const Magnetometer({super.key});

  @override
  State<Magnetometer> createState() => _MagnetometerState();
}

class _MagnetometerState extends State<Magnetometer>
    with SingleTickerProviderStateMixin {
  StreamSubscription<MagnetometerEvent>? _subscription;
  double _x = 0, _y = 0, _z = 0;

  // Smoothed values for stable rendering
  double _smoothX = 0, _smoothY = 0, _smoothZ = 1;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _subscription =
        magnetometerEventStream(
          samplingPeriod: SensorInterval.uiInterval,
        ).listen((event) {
          setState(() {
            _x = event.x;
            _y = event.y;
            _z = event.z;

            // Low-pass filter for smooth arrow movement
            const double alpha = 0.15;
            _smoothX = _smoothX + alpha * (event.x - _smoothX);
            _smoothY = _smoothY + alpha * (event.y - _smoothY);
            _smoothZ = _smoothZ + alpha * (event.z - _smoothZ);
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  double get _magnitude => math.sqrt(_x * _x + _y * _y + _z * _z);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: titleAppBar(context, title: 'MAGNETOMETER'),
      body: SafeArea(
        child: Column(
          children: [
            // 3D Field Arrow Viewport
            Expanded(
              flex: 3,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: MagnetPainter(
                        fx: _smoothX,
                        fy: _smoothY,
                        fz: _smoothZ,
                        colorScheme: colorScheme,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Info Text
            Text(
              'Try putting a magnet near your device',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            // Data readout panel
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MAGNETIC FIELD  (µT)',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '|B| ${_magnitude.toStringAsFixed(1)} µT',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _AxisReadout(
                        label: 'X',
                        value: _x,
                        maxVal: 100,
                        color: const Color(0xFFFF4D4D),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 12),
                      _AxisReadout(
                        label: 'Y',
                        value: _y,
                        maxVal: 100,
                        color: const Color(0xFF4DFF88),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 12),
                      _AxisReadout(
                        label: 'Z',
                        value: _z,
                        maxVal: 100,
                        color: const Color(0xFF4DB8FF),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Compass heading strip
            _CompassStrip(x: _smoothX, y: _smoothY, colorScheme: colorScheme),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Compass Heading Strip

class _CompassStrip extends StatelessWidget {
  final double x, y;
  final ColorScheme colorScheme;

  const _CompassStrip({
    required this.x,
    required this.y,
    required this.colorScheme,
  });

  String _headingLabel(double deg) {
    if (deg < 22.5 || deg >= 337.5) return 'N';
    if (deg < 67.5) return 'NE';
    if (deg < 112.5) return 'E';
    if (deg < 157.5) return 'SE';
    if (deg < 202.5) return 'S';
    if (deg < 247.5) return 'SW';
    if (deg < 292.5) return 'W';
    return 'NW';
  }

  @override
  Widget build(BuildContext context) {
    // Heading: angle of XY projection from magnetic north
    double heading = math.atan2(-x, y) * 180 / math.pi;
    if (heading < 0) heading += 360;
    final label = _headingLabel(heading);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'HEADING',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                '${heading.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Axis Readout Widget

class _AxisReadout extends StatelessWidget {
  final String label;
  final double value;
  final double maxVal;
  final Color color;
  final ColorScheme colorScheme;

  const _AxisReadout({
    required this.label,
    required this.value,
    required this.maxVal,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final intensity = (value.abs() / maxVal).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08 + intensity * 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.25 + intensity * 0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3D Magnetic Field Painter

class MagnetPainter extends CustomPainter {
  final double fx, fy, fz;
  final ColorScheme colorScheme;

  MagnetPainter({
    required this.fx,
    required this.fy,
    required this.fz,
    required this.colorScheme,
  });

  List<double> _normalize(List<double> v) {
    final mag = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (mag < 0.0001) return [0, 0, 1];
    return [v[0] / mag, v[1] / mag, v[2] / mag];
  }

  // Project 3D → 2D isometric-ish perspective
  Offset _project(double x, double y, double z, Offset center, double scale) {
    const double fov = 4.5;
    final double perspective = fov / (fov + z);
    return Offset(
      center.dx + x * scale * perspective,
      center.dy - y * scale * perspective,
    );
  }

  void _drawGridAxis(
    Canvas canvas,
    Offset center,
    double scale,
    List<double> dir,
    Color color,
    String label,
  ) {
    const double len = 1.2;
    final end = _project(
      dir[0] * len,
      dir[1] * len,
      dir[2] * len,
      center,
      scale,
    );
    final start = _project(
      -dir[0] * len,
      -dir[1] * len,
      -dir[2] * len,
      center,
      scale,
    );

    // Dashed reference axis
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dashed line manually
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final total = math.sqrt(dx * dx + dy * dy);
    if (total < 1) return;
    const double dashLen = 6, gapLen = 5;
    double traveled = 0;
    bool drawing = true;
    final path = Path();
    while (traveled < total) {
      final segment = drawing ? dashLen : gapLen;
      final t0 = traveled / total;
      final t1 = math.min((traveled + segment) / total, 1.0);
      if (drawing) {
        path.moveTo(start.dx + dx * t0, start.dy + dy * t0);
        path.lineTo(start.dx + dx * t1, start.dy + dy * t1);
      }
      traveled += segment;
      drawing = !drawing;
    }
    canvas.drawPath(path, paint);

    // Positive end label
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final unitDir = Offset(dx, dy) / total;
    tp.paint(
      canvas,
      Offset(
        end.dx + unitDir.dx * 8 - tp.width / 2,
        end.dy + unitDir.dy * 8 - tp.height / 2,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide * 0.30;

    // Draw reference grid axes (fixed, not rotating)
    _drawGridAxis(
      canvas,
      center,
      scale,
      [1, 0, 0],
      const Color(0xFFFF4D4D),
      'X',
    );
    _drawGridAxis(
      canvas,
      center,
      scale,
      [0, 1, 0],
      const Color(0xFF4DFF88),
      'Y',
    );
    _drawGridAxis(
      canvas,
      center,
      scale,
      [0, 0, 1],
      const Color(0xFF4DB8FF),
      'Z',
    );

    // Origin dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = colorScheme.onSurface.withValues(alpha: 0.4),
    );

    // Normalize field vector
    final norm = _normalize([fx, fy, fz]);
    final magnitude = math.sqrt(fx * fx + fy * fy + fz * fz);

    // Arrow length scales slightly with magnitude (clamped)
    final arrowLen = 0.7 + (magnitude / 120).clamp(0.0, 0.5);

    final tip = _project(
      norm[0] * arrowLen,
      norm[1] * arrowLen,
      norm[2] * arrowLen,
      center,
      scale,
    );
    final tail = _project(
      -norm[0] * arrowLen * 0.4,
      -norm[1] * arrowLen * 0.4,
      -norm[2] * arrowLen * 0.4,
      center,
      scale,
    );

    final arrowColor = colorScheme.primary;
    final glowColor = colorScheme.primary.withValues(alpha: 0.25);

    // Glow effect behind arrow
    canvas.drawLine(
      tail,
      tip,
      Paint()
        ..color = glowColor
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Arrow shaft
    canvas.drawLine(
      tail,
      tip,
      Paint()
        ..color = arrowColor
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Arrowhead
    final dir = tip - tail;
    final len = dir.distance;
    if (len > 10) {
      final unit = dir / len;
      final perp = Offset(-unit.dy, unit.dx);
      const double arrowSize = 14;

      final arrowPath = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - unit.dx * arrowSize + perp.dx * arrowSize * 0.45,
          tip.dy - unit.dy * arrowSize + perp.dy * arrowSize * 0.45,
        )
        ..lineTo(
          tip.dx - unit.dx * arrowSize - perp.dx * arrowSize * 0.45,
          tip.dy - unit.dy * arrowSize - perp.dy * arrowSize * 0.45,
        )
        ..close();

      canvas.drawPath(arrowPath, Paint()..color = arrowColor);
    }

    // Tail dot
    canvas.drawCircle(
      tail,
      5,
      Paint()..color = arrowColor.withValues(alpha: 0.6),
    );

    // Field vector label near tip
    final tp = TextPainter(
      text: TextSpan(
        text: 'B',
        style: TextStyle(
          color: arrowColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final arrowDir = (tip - tail);
    if (arrowDir.distance < 1) return;
    final arrowUnit = arrowDir / arrowDir.distance;
    tp.paint(
      canvas,
      Offset(
        tip.dx + arrowUnit.dx * 18 - tp.width / 2,
        tip.dy + arrowUnit.dy * 18 - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(MagnetPainter old) =>
      old.fx != fx || old.fy != fy || old.fz != fz;
}
