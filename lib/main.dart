import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'environment/Environment.dart';
import 'splash.dart';
import 'networking/api_config.dart';
import 'shared_preference/shared_preference_manager.dart';
import 'NotificationScreen.dart'; // keep file name exactly as in your project
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

// Top-level or static function for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

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

/// Navigate to NotificationScreen when a notification is tapped.
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

  // Read env from --dart-define=ENV=dev|staging|production
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

  // Initialize Firebase
  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        // TODO: Fill in real web options if you run on web
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "YOUR_API_KEY",
            authDomain: "YOUR_AUTH_DOMAIN",
            projectId: "tenontraining360",
            storageBucket: "tenontraining360.firebasestorage.app",
            messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
            appId: "YOUR_APP_ID",
            measurementId: "YOUR_MEASUREMENT_ID",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    }

    // Must be set before using background messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notifications init
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
    const InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) => _handleNotificationTap(),
    );

    // Create Android notification channel (Android 8+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);

    // iOS/macOS foreground presentation options (no-op on Android)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Ask permissions on iOS
    await FirebaseMessaging.instance.requestPermission();

    // Show notifications when a message arrives in foreground
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
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Run app
  runApp(const MyApp());

  // Handle notification when app opened from terminated state
  try {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleNotificationTap();
  } catch (e) {
    debugPrint('getInitialMessage error: $e');
  }

  // Handle when app reopened from background by tapping notification
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
    setState(() {
      _locale = newLocale;
    });
  }

  Future<void> _loadLocale() async {
    try {
      final pref = SharedPreferenceManager();
      final langCode = await pref.getLanguageCode();
      if (langCode != null && mounted) {
        setState(() => _locale = Locale(langCode));
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  /// Grab and store current token once on startup
  Future<void> _cacheFcmToken() async {
    try {
      final pref = SharedPreferenceManager();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await pref.saveToken(token);
      }
      // Also keep saving on refresh
      FirebaseMessaging.instance.onTokenRefresh.listen(pref.saveToken);
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
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
