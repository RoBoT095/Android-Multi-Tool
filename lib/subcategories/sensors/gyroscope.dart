import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

class Gyroscope extends StatefulWidget {
  const Gyroscope({super.key});

  @override
  State<Gyroscope> createState() => _GyroscopeState();
}

class _GyroscopeState extends State<Gyroscope>
    with SingleTickerProviderStateMixin {
  StreamSubscription<GyroscopeEvent>? _subscription;
  double _x = 0, _y = 0, _z = 0;

  // Rotation angles accumulated over time
  double _rotX = 0, _rotY = 0, _rotZ = 0.0;

  late AnimationController _animController;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Animation controller to drive continuous repaints
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _subscription =
        gyroscopeEventStream(samplingPeriod: SensorInterval.uiInterval).listen((
          event,
        ) {
          final now = DateTime.now();
          final dt = now.difference(_lastUpdate).inMilliseconds / 1000.0;
          _lastUpdate = now;

          setState(() {
            _x = event.x;
            _y = event.y;
            _z = event.z;

            const double decayFactor = 0.92; // Slowly rotate back to zero
            _rotX = _rotX * decayFactor + event.x * dt;
            _rotY = _rotY * decayFactor + event.y * dt;
            _rotZ = _rotZ * decayFactor + event.z * dt;
          });
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: titleAppBar(context, title: 'GYROSCOPE'),
      body: SafeArea(
        child: Column(
          children: [
            // 3D Cube Viewport
            Expanded(
              flex: 3,
              child: Center(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: CubePainter(
                        rotX: _rotX,
                        rotY: _rotY,
                        rotZ: _rotZ,
                        colorScheme: colorScheme,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Data readout panel
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                  Text(
                    'ANGULAR VELOCITY  (rad/s)',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _AxisReadout(
                        label: 'X',
                        value: _x,
                        color: const Color(0xFFFF4D4D),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 12),
                      _AxisReadout(
                        label: 'Y',
                        value: _y,
                        color: const Color(0xFF4DFF88),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 12),
                      _AxisReadout(
                        label: 'Z',
                        value: _z,
                        color: const Color(0xFF4DB8FF),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisReadout extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ColorScheme colorScheme;

  const _AxisReadout({
    required this.label,
    required this.value,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final intensity = (value.abs() / 5.0).clamp(0.0, 1.0);

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
              value.toStringAsFixed(3),
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

// 3D Cube Painter

class CubePainter extends CustomPainter {
  final double rotX, rotY, rotZ;
  final ColorScheme colorScheme;

  CubePainter({
    required this.rotX,
    required this.rotY,
    required this.rotZ,
    required this.colorScheme,
  });

  // Rotate a 3D point by Euler angles (ZYX order)
  List<double> _rotate(double x, double y, double z) {
    // Rotate around X
    double y1 = y * math.cos(rotX) - z * math.sin(rotX);
    double z1 = y * math.sin(rotX) + z * math.cos(rotX);

    // Rotate around Y
    double x2 = x * math.cos(rotY) + z1 * math.sin(rotY);
    double z2 = -x * math.sin(rotY) + z1 * math.cos(rotY);

    // Rotate around Z
    double x3 = x2 * math.cos(rotZ) - y1 * math.sin(rotZ);
    double y3 = x2 * math.sin(rotZ) + y1 * math.cos(rotZ);

    return [x3, y3, z2];
  }

  // Project 3D → 2D with perspective
  Offset _project(List<double> p, Offset center, double scale) {
    const double fov = 4.0;
    final double perspective = fov / (fov + p[2]);
    return Offset(
      center.dx + p[0] * scale * perspective,
      center.dy - p[1] * scale * perspective,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide * 0.28;

    // Cube vertices (unit cube, centered at origin)
    const double s = 1.0;
    final rawVerts = [
      [-s, -s, -s], [s, -s, -s], [s, s, -s], [-s, s, -s], // back face
      [-s, -s, s], [s, -s, s], [s, s, s], [-s, s, s], // front face
    ];

    // Rotate all vertices
    final verts = rawVerts.map((v) => _rotate(v[0], v[1], v[2])).toList();

    // Project to 2D
    final pts = verts.map((v) => _project(v, center, scale)).toList();

    // Cube faces [indices, base color opacity]
    final faces = [
      [0, 1, 2, 3], // back
      [4, 5, 6, 7], // front
      [0, 4, 7, 3], // left
      [1, 5, 6, 2], // right
      [3, 2, 6, 7], // top
      [0, 1, 5, 4], // bottom
    ];

    // Compute face normals for basic lighting
    List<double> faceDepths = [];
    List<double> faceDots = [];

    final lightDir = _normalize([0.4, 0.7, 1.0]);

    for (final face in faces) {
      final a = verts[face[0]];
      final b = verts[face[1]];
      final c = verts[face[2]];

      final ab = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
      final ac = [c[0] - a[0], c[1] - a[1], c[2] - a[2]];
      final normal = _normalize(_cross(ab, ac));
      final dot = _dot(normal, lightDir).clamp(0.0, 1.0);

      final avgZ = (a[2] + b[2] + c[2] + verts[face[3]][2]) / 4;
      faceDepths.add(avgZ);
      faceDots.add(dot);
    }

    // Sort faces back-to-front (painter's algorithm)
    final sortedIndices = List.generate(faces.length, (i) => i)
      ..sort((a, b) => faceDepths[a].compareTo(faceDepths[b]));

    final faceColor = colorScheme.primary;

    // Draw faces
    for (final fi in sortedIndices) {
      final face = faces[fi];
      final dot = faceDots[fi];

      final path = Path()
        ..moveTo(pts[face[0]].dx, pts[face[0]].dy)
        ..lineTo(pts[face[1]].dx, pts[face[1]].dy)
        ..lineTo(pts[face[2]].dx, pts[face[2]].dy)
        ..lineTo(pts[face[3]].dx, pts[face[3]].dy)
        ..close();

      // Face fill
      final fillPaint = Paint()
        ..color = Color.lerp(
          colorScheme.surfaceContainerHighest,
          faceColor,
          0.35 + dot * 0.45,
        )!.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, fillPaint);

      // Edge outline
      final edgePaint = Paint()
        ..color = colorScheme.outline.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawPath(path, edgePaint);
    }

    // Axis lines
    const double axisLen = 1.7;

    // X axis – red
    _drawAxis(
      canvas,
      center,
      scale,
      end: [axisLen, 0.0, 0.0],
      label: 'X',
      color: const Color(0xFFFF4D4D),
    );
    // Y axis – green
    _drawAxis(
      canvas,
      center,
      scale,
      end: [0.0, axisLen, 0.0],
      label: 'Y',
      color: const Color(0xFF4DFF88),
    );
    // Z axis – blue
    _drawAxis(
      canvas,
      center,
      scale,
      end: [0.0, 0.0, axisLen],
      label: 'Z',
      color: const Color(0xFF4DB8FF),
    );
  }

  void _drawAxis(
    Canvas canvas,
    Offset center,
    double scale, {
    required List<double> end,
    required String label,
    required Color color,
  }) {
    final origin = _project(_rotate(0, 0, 0), center, scale);
    final tip = _project(_rotate(end[0], end[1], end[2]), center, scale);

    // Shaft
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(origin, tip, paint);

    // Arrowhead
    final dir = (tip - origin);
    final len = dir.distance;
    if (len < 1) return;
    final unit = dir / len;
    final perp = Offset(-unit.dy, unit.dx);
    const double arrowSize = 10;

    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - unit.dx * arrowSize + perp.dx * arrowSize * 0.4,
        tip.dy - unit.dy * arrowSize + perp.dy * arrowSize * 0.4,
      )
      ..lineTo(
        tip.dx - unit.dx * arrowSize - perp.dx * arrowSize * 0.4,
        tip.dy - unit.dy * arrowSize - perp.dy * arrowSize * 0.4,
      )
      ..close();

    canvas.drawPath(arrowPath, Paint()..color = color);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        tip.dx + unit.dx * 10 - textPainter.width / 2,
        tip.dy + unit.dy * 10 - textPainter.height / 2,
      ),
    );
  }

  // Math helpers

  List<double> _cross(List<double> a, List<double> b) => [
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0],
  ];

  double _dot(List<double> a, List<double> b) =>
      a[0] * b[0] + a[1] * b[1] + a[2] * b[2];

  List<double> _normalize(List<double> v) {
    final mag = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (mag == 0) return [0, 0, 0];
    return [v[0] / mag, v[1] / mag, v[2] / mag];
  }

  @override
  bool shouldRepaint(CubePainter old) =>
      old.rotX != rotX || old.rotY != rotY || old.rotZ != rotZ;
}
