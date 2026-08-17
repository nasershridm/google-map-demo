import 'package:flutter/material.dart';
import 'package:dndn/app.dart';
import 'package:dndn/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  runApp(const App());
}
