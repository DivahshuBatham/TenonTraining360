import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tenon_training_app/main.dart';

import 'Environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AppConfig.setEnvironment(Environment.dev);
  runApp(MyApp());
}