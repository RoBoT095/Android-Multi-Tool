import 'package:flutter/material.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

class Magnetometer extends StatefulWidget {
  const Magnetometer({super.key});

  @override
  State<Magnetometer> createState() => _MagnetometerState();
}

class _MagnetometerState extends State<Magnetometer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: titleAppBar(context, title: 'MAGNETOMETER'));
  }
}
