import 'package:flutter/material.dart';

PreferredSizeWidget titleAppBar(
  BuildContext context, {
  String title = '',
  List<Widget>? actions,
}) => AppBar(
  backgroundColor: Theme.of(context).colorScheme.surface,
  elevation: 0,
  title: Text(
    title,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 4,
    ),
  ),
  centerTitle: true,
  leading: Navigator.canPop(context)
      ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => Navigator.of(context).maybePop(),
        )
      : null,
  actions: actions,
);
