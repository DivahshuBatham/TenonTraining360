import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'environment/Environment.dart';
import 'splash.dart';
import 'networking/api_config.dart';
import 'shared_preference/shared_preference_manager.dart';
import 'NotificationScreen.dart';
import 'l10n/app_localizations.dart';

// ---------------- Notifications setup ----------------

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  'default_channel',
  'Default Channel',
  description: 'Used for important notifications.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "tenontraining360",
      storageBucket: "tenontraining360.appspot.com",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID",
      measurementId: "YOUR_MEASUREMENT_ID",
    )
        : null,
  );

  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

void _handleNotificationTap() {
  ApiConfig.showToastMessage('Notification is clicked');
  final navigatorState = MyApp.navigatorKey.currentState;
  if (navigatorState != null) {
    navigatorState.push(
      MaterialPageRoute(builder: (_) => NotificationScreen()),
    );
  } else {
    debugPrint('NavigatorState is null, cannot navigate');
  }
}

// ---------------- Main ----------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------- Set environment ----------------
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  switch (env) {
    case 'production':
      AppConfig.setEnvironment(Environment.production);
      break;
    case 'staging':
      AppConfig.setEnvironment(Environment.staging);
      break;
    default:
      AppConfig.setEnvironment(Environment.dev);
  }
  debugPrint("Running Environment: ${AppConfig.environment}");

  // ---------------- Initialize Firebase ----------------
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "tenontraining360",
        storageBucket: "tenontraining360.appspot.com",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
        measurementId: "YOUR_MEASUREMENT_ID",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // ---------------- Crashlytics Setup ----------------
  // Catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Catch platform-level errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Catch async errors
  runZonedGuarded<Future<void>>(() async {
    await _setupFirebaseMessaging();
    runApp(const MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

// ---------------- Firebase Messaging & Local Notifications Setup ----------------
Future<void> _setupFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (_) => _handleNotificationTap(),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_defaultChannel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null) {
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'Used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) _handleNotificationTap();

  FirebaseMessaging.onMessageOpenedApp.listen((_) => _handleNotificationTap());
}

// ---------------- App ----------------
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _cacheFcmToken();
  }

  void setLocale(Locale newLocale) {
    setState(() => _locale = newLocale);
  }

  Future<void> _loadLocale() async {
    try {
      final pref = SharedPreferenceManager();
      final langCode = await pref.getLanguageCode();
      if (langCode != null && mounted) {
        setState(() => _locale = Locale(langCode));
      }
    } catch (e, st) {
      debugPrint('Error loading locale: $e');
      FirebaseCrashlytics.instance.recordError(e, st);
    }
  }

  Future<void> _cacheFcmToken() async {
    try {
      final pref = SharedPreferenceManager();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await pref.saveToken(token);
      FirebaseMessaging.instance.onTokenRefresh.listen(pref.saveToken);
    } catch (e, st) {
      debugPrint('Error fetching FCM token: $e');
      FirebaseCrashlytics.instance.recordError(e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
        Locale('kn'),
        Locale('ta'),
        Locale('pa'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
