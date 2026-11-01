import 'package:flutter/material.dart';

import 'package:android_multi_tool/utils/navigator.dart';
import 'package:android_multi_tool/components/grid_tile.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

import 'package:android_multi_tool/subcategories/sensors/accelerometer.dart';
import 'package:android_multi_tool/subcategories/sensors/gyroscope.dart';
import 'package:android_multi_tool/subcategories/sensors/magnetometer.dart';
import 'package:android_multi_tool/subcategories/sensors/barometer.dart';
// import 'package:android_multi_tool/subcategories/sensors/lux_meter.dart';
import 'package:android_multi_tool/subcategories/sensors/gps.dart';

import 'package:android_multi_tool/components/under_construction_tape.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleAppBar(context, title: 'SENSORS'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            CustomGridTile(
              title: 'Accelerometer',
              icon: Icons.speed,
              onTap: () {
                navigatorTo(context, Accelerometer());
              },
            ),
            CustomGridTile(
              title: 'Gyroscope',
              icon: Icons.rotate_right,
              onTap: () {
                navigatorTo(context, Gyroscope());
              },
            ),
            CustomGridTile(
              title: 'Magnetometer',
              icon: Icons.explore,
              onTap: () {
                navigatorTo(context, Magnetometer());
              },
            ),
            CustomGridTile(
              title: 'Barometer',
              icon: Icons.compress,
              onTap: () {
                navigatorTo(context, Barometer());
              },
            ),
            CustomGridTile(
              title: 'GPS',
              icon: Icons.gps_fixed,
              onTap: () {
                navigatorTo(context, GPS());
              },
            ),
            UnderConstructionTape(
              child: CustomGridTile(
                title: 'LUX Meter\n(Light)',
                icon: Icons.lightbulb,
                onTap: () {
                  // navigatorTo(context, LuxMeter());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
