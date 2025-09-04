import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import '../main.dart';
import 'Environment.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AppConfig.setEnvironment(Environment.production);
  runApp(MyApp());
}