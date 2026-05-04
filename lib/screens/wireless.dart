import 'package:flutter/material.dart';

import 'package:android_multi_tool/components/navigator.dart';
import 'package:android_multi_tool/components/grid_tile.dart';

class WirelessScreen extends StatelessWidget {
  const WirelessScreen({super.key});

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
            CustomGridTile(title: 'WiFi', icon: Icons.wifi, onTap: () {}),
            CustomGridTile(
              title: 'Bluetooth',
              icon: Icons.bluetooth,
              onTap: () {},
            ),
            CustomGridTile(title: 'Mobile', icon: Icons.sim_card, onTap: () {}),
          ],
        ),
      ),
    );
  }
}
