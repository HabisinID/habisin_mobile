import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'core/session.dart';
import 'core/theme.dart';
import 'core/widgets/home_shell.dart';

void main() => runApp(const HabisinApp());

class HabisinApp extends StatelessWidget {
  const HabisinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (_, mode, _) => MaterialApp(
        title: 'HABISIN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: const HomeShell(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
