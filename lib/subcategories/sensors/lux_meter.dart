// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:light/light.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

// import 'package:android_multi_tool/widgets/title_app_bars.dart';
// import 'package:android_multi_tool/components/info_tile.dart';

// const _darkColor = Color(0xFF9C27B0); // < 10 lux
// const _dimColor = Color(0xFF2196F3); // 10–100
// const _indoorColor = Color(0xFF4CAF50); // 100–500
// const _brightColor = Color(0xFFFFC107); // 500–10000
// const _sunlightColor = Color(0xFFF44336); // 10000+

// class LuxMeter extends StatefulWidget {
//   const LuxMeter({super.key});

//   @override
//   State<LuxMeter> createState() => _LuxMeterState();
// }

// class _LuxMeterState extends State<LuxMeter> {
//   StreamSubscription<int>? _subscription;

//   double _luxValue = 0;
//   double _peakLux = 0;

//   static const double _minLux = 0;
//   static const double _maxLux = 10000;

//   @override
//   void initState() {
//     super.initState();
//     _subscription = Light().lightSensorStream.listen((int lux) {
//       setState(() {
//         _luxValue = lux.toDouble();
//         if (_luxValue > _peakLux) _peakLux = _luxValue;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }

//   String get _lightLabel {
//     if (_luxValue < 10) return 'Very Dark · Night';
//     if (_luxValue < 100) return 'Dim · Low Light';
//     if (_luxValue < 500) return 'Indoor · Office';
//     if (_luxValue < 10000) return 'Bright · Overcast';
//     return 'Direct Sunlight';
//   }

//   Color get _conditionColor {
//     if (_luxValue < 10) return _darkColor;
//     if (_luxValue < 100) return _dimColor;
//     if (_luxValue < 500) return _indoorColor;
//     if (_luxValue < 10000) return _brightColor;
//     return _sunlightColor;
//   }

//   String get _luxDisplay {
//     if (_luxValue >= 1000) {
//       return '${(_luxValue / 1000).toStringAsFixed(1)}k';
//     }
//     return _luxValue.toStringAsFixed(0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;

//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: titleAppBar(context, title: 'LUX METER'),
//       body: SafeArea(child: isLandscape ? _buildLandscape() : _buildPortrait()),
//     );
//   }

//   Widget _buildPortrait() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         children: [
//           Expanded(flex: 3, child: _buildGauge()),
//           const SizedBox(height: 8),
//           _buildConditionChip(),
//           const SizedBox(height: 16),
//           _buildInfoRow(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildLandscape() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: Row(
//         children: [
//           Expanded(flex: 5, child: _buildGauge()),
//           Expanded(
//             flex: 3,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildConditionChip(),
//                 const SizedBox(height: 20),
//                 _buildInfoRow(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGauge() {
//     return SfRadialGauge(
//       enableLoadingAnimation: true,
//       animationDuration: 1200,
//       axes: <RadialAxis>[
//         RadialAxis(
//           minimum: _minLux,
//           maximum: _maxLux,
//           startAngle: 150,
//           endAngle: 30,
//           maximumLabels: 3,
//           interval: 1000,
//           minorTicksPerInterval: 4,
//           axisLineStyle: AxisLineStyle(
//             thickness: 0.08,
//             thicknessUnit: GaugeSizeUnit.factor,
//             color: Colors.grey,
//           ),
//           majorTickStyle: MajorTickStyle(
//             length: 0.12,
//             lengthUnit: GaugeSizeUnit.factor,
//             thickness: 2,
//             color: Colors.grey[400],
//           ),
//           minorTickStyle: MinorTickStyle(
//             length: 0.06,
//             lengthUnit: GaugeSizeUnit.factor,
//             thickness: 1,
//             color: Colors.grey,
//           ),
//           axisLabelStyle: GaugeTextStyle(
//             fontSize: 11,
//             color: Colors.grey[400],
//             fontWeight: FontWeight.w600,
//           ),
//           ranges: <GaugeRange>[
//             GaugeRange(
//               startValue: 0,
//               endValue: 10,
//               color: _darkColor,
//               startWidth: 0.08,
//               endWidth: 0.08,
//               sizeUnit: GaugeSizeUnit.factor,
//             ),
//             GaugeRange(
//               startValue: 10,
//               endValue: 100,
//               color: _dimColor,
//               startWidth: 0.08,
//               endWidth: 0.08,
//               sizeUnit: GaugeSizeUnit.factor,
//             ),
//             GaugeRange(
//               startValue: 100,
//               endValue: 500,
//               color: _indoorColor,
//               startWidth: 0.08,
//               endWidth: 0.08,
//               sizeUnit: GaugeSizeUnit.factor,
//             ),
//             GaugeRange(
//               startValue: 500,
//               endValue: 9000,
//               color: _brightColor,
//               startWidth: 0.08,
//               endWidth: 0.08,
//               sizeUnit: GaugeSizeUnit.factor,
//             ),
//             GaugeRange(
//               startValue: 9000,
//               endValue: 10000,
//               color: _sunlightColor,
//               startWidth: 0.08,
//               endWidth: 0.08,
//               sizeUnit: GaugeSizeUnit.factor,
//             ),
//           ],
//           pointers: <GaugePointer>[
//             NeedlePointer(
//               value: _luxValue.clamp(_minLux, _maxLux),
//               enableAnimation: true,
//               animationType: AnimationType.easeOutBack,
//               animationDuration: 600,
//               needleColor: Colors.white,
//               needleLength: 0.72,
//               needleStartWidth: 1,
//               needleEndWidth: 4,
//               knobStyle: KnobStyle(
//                 sizeUnit: GaugeSizeUnit.factor,
//                 color: Colors.white,
//               ),
//               tailStyle: const TailStyle(
//                 length: 0.12,
//                 lengthUnit: GaugeSizeUnit.factor,
//                 width: 3,
//               ),
//             ),
//           ],

//           annotations: <GaugeAnnotation>[
//             GaugeAnnotation(
//               angle: 90,
//               positionFactor: 0.55,
//               widget: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     _luxDisplay,
//                     style: const TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   const Text(
//                     'lux',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildConditionChip() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 400),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: _conditionColor.withValues(alpha: 0.15),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: _conditionColor.withValues(alpha: 0.5),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.circle, size: 10, color: _conditionColor),
//           const SizedBox(width: 8),
//           Text(
//             _lightLabel,
//             style: TextStyle(
//               color: _conditionColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 13,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         InfoTile(
//           label: 'Peak',
//           value: '${_peakLux.toStringAsFixed(0)} lux',
//           icon: Icons.arrow_upward,
//           endButton: _resetButton(),
//         ),
//         const SizedBox(width: 16),
//         InfoTile(
//           label: 'Exposure (approx)',
//           value: _evApprox,
//           icon: Icons.camera_outlined,
//         ),
//       ],
//     );
//   }

//   /// Rough exposure value from lux: EV = log2(lux / 2.5)
//   String get _evApprox {
//     if (_luxValue <= 0) return '— EV';
//     final ev = (log(_luxValue / 2.5) / log(2));
//     return '${ev.toStringAsFixed(1)} EV';
//   }

//   Widget _resetButton() {
//     return Tooltip(
//       message: 'Reset max',
//       child: InkWell(
//         onTap: () => setState(() => _peakLux = 0),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surfaceBright,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             Icons.refresh,
//             size: 16,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//       ),
//     );
//   }
// }
