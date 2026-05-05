import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

class Gyroscope extends StatefulWidget {
  const Gyroscope({super.key});

  @override
  State<Gyroscope> createState() => _GyroscopeState();
}

class _GyroscopeState extends State<Gyroscope> {
  StreamSubscription<GyroscopeEvent>? _subscription;

  double _x = 0, _y = 0, _z = 0;

  @override
  void initState() {
    super.initState();
    _subscription =
        gyroscopeEventStream(samplingPeriod: SensorInterval.uiInterval).listen((
          event,
        ) {
          setState(() {
            _x = event.x;
            _y = event.y;
            _z = event.z;
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
    return Scaffold(appBar: titleAppBar(context, title: 'GYROSCOPE'));
  }
}
