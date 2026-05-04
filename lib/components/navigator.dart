import 'package:flutter/material.dart';

Future<void> navigatorTo(BuildContext context, Widget screen) {
  return Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}
