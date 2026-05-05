import 'package:flutter/material.dart';

import 'package:android_multi_tool/widgets/title_app_bars.dart';

class Barometer extends StatelessWidget {
  const Barometer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: titleAppBar(context, title: 'BAROMETER'));
  }
}
