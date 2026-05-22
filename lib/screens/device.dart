import 'package:flutter/material.dart';

import 'package:android_multi_tool/components/navigator.dart';
import 'package:android_multi_tool/components/grid_tile.dart';
import 'package:android_multi_tool/components/under_construction_tape.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

import 'package:android_multi_tool/subcategories/device/battery.dart';
import 'package:android_multi_tool/subcategories/device/hardware.dart';
import 'package:android_multi_tool/subcategories/device/storage.dart';
import 'package:android_multi_tool/subcategories/device/system_usage.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleAppBar(context, title: 'DEVICE'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            CustomGridTile(
              title: 'Battery',
              icon: Icons.battery_4_bar,
              onTap: () {
                navigatorTo(context, BatteryInfo());
              },
            ),
            CustomGridTile(
              title: 'Hardware Info',
              icon: Icons.aod,
              onTap: () {
                navigatorTo(context, HardwareInfo());
              },
            ),
            UnderConstructionTape(
              child: CustomGridTile(
                title: 'Storage',
                icon: Icons.sd_storage,
                onTap: () {
                  navigatorTo(context, DeviceStorage());
                },
              ),
            ),
            UnderConstructionTape(
              child: CustomGridTile(
                title: 'CPU & RAM',
                icon: Icons.speed,
                onTap: () {
                  navigatorTo(context, SystemUsage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
