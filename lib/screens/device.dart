import 'package:flutter/material.dart';

import 'package:android_multi_tool/components/navigator.dart';
import 'package:android_multi_tool/components/grid_tile.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device'), centerTitle: true),
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
              onTap: () {},
            ),
            CustomGridTile(
              title: 'Hardware Info',
              icon: Icons.aod,
              onTap: () {},
            ),
            CustomGridTile(
              title: 'Storage',
              icon: Icons.sd_storage,
              onTap: () {},
            ),
            CustomGridTile(title: 'CPU & RAM', icon: Icons.speed, onTap: () {}),
          ],
        ),
      ),
    );
  }
}
