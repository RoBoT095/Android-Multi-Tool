import 'package:flutter/material.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

class WifiInfo extends StatelessWidget {
  const WifiInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: titleAppBar(context, title: 'WIFI'));
  }
}
