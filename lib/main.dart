import 'package:flutter/material.dart';

import 'package:android_multi_tool/utils/navigator.dart';
import 'package:android_multi_tool/components/grid_tile.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';
import 'package:android_multi_tool/components/under_construction_tape.dart';

import 'package:android_multi_tool/screens/settings.dart';
import 'package:android_multi_tool/screens/sensors.dart';
import 'package:android_multi_tool/screens/device.dart';
import 'package:android_multi_tool/screens/wireless.dart';
import 'package:android_multi_tool/screens/audio.dart';
import 'package:android_multi_tool/screens/utility_tools.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleAppBar(
        context,
        title: 'ANDROID MULTI-TOOL',
        actions: [
          IconButton(
            onPressed: () {
              navigatorTo(context, SettingsPage());
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            CustomGridTile(
              title: 'Sensors',
              icon: Icons.sensors,
              onTap: () {
                navigatorTo(context, SensorsScreen());
              },
            ),
            CustomGridTile(
              title: 'Device',
              icon: Icons.phone_android,
              onTap: () {
                navigatorTo(context, DeviceScreen());
              },
            ),
            UnderConstructionTape(
              child: CustomGridTile(
                title: 'Wireless',
                icon: Icons.wifi,
                onTap: () {
                  navigatorTo(context, WirelessScreen());
                },
              ),
            ),
            CustomGridTile(
              title: 'Audio',
              icon: Icons.music_note,
              onTap: () {
                navigatorTo(context, AudioScreen());
              },
            ),

            UnderConstructionTape(
              child: CustomGridTile(
                title: 'Utility Tools',
                icon: Icons.construction,
                onTap: () {
                  navigatorTo(context, UtilityToolsScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
