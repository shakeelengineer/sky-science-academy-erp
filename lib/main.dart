import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'database/database_helper.dart';
import 'features/app_state.dart';
import 'features/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AcademyState(DatabaseHelper.instance);
  await state.load();
  runApp(
    ChangeNotifierProvider.value(value: state, child: const SkyAcademyApp()),
  );
}

class SkyAcademyApp extends StatelessWidget {
  const SkyAcademyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SkyPro',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const AppShell(),
  );
}
