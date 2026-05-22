import 'package:flutter/material.dart';

import 'package:android_multi_tool/utils/navigator.dart';
import 'package:android_multi_tool/components/grid_tile.dart';
import 'package:android_multi_tool/components/under_construction_tape.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

import 'package:android_multi_tool/subcategories/wireless/wifi.dart';
import 'package:android_multi_tool/subcategories/wireless/bluetooth.dart';
import 'package:android_multi_tool/subcategories/wireless/mobile.dart';

class WirelessScreen extends StatelessWidget {
  const WirelessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleAppBar(context, title: 'WIRELESS'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            UnderConstructionTape(
              child: CustomGridTile(
                title: 'WiFi',
                icon: Icons.wifi,
                onTap: () {
                  navigatorTo(context, WifiInfo());
                },
              ),
            ),
            UnderConstructionTape(
              child: CustomGridTile(
                title: 'Bluetooth',
                icon: Icons.bluetooth,
                onTap: () {
                  navigatorTo(context, Bluetooth());
                },
              ),
            ),
            UnderConstructionTape(
              child: CustomGridTile(
                title: 'Mobile',
                icon: Icons.sim_card,
                onTap: () {
                  navigatorTo(context, MobileSIM());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
