import 'package:flutter/material.dart';

import 'package:android_multi_tool/utils/navigator.dart';
import 'package:android_multi_tool/components/grid_tile.dart';
import 'package:android_multi_tool/widgets/title_app_bars.dart';

import 'package:android_multi_tool/subcategories/audio/decibels.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleAppBar(context, title: 'AUDIO'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            CustomGridTile(
              title: 'Decibels',
              icon: Icons.volume_up,
              onTap: () {
                navigatorTo(context, Decibels());
              },
            ),
          ],
        ),
      ),
    );
  }
}
