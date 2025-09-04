import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import 'shared_preference/shared_preference_manager.dart';
import 'trainee/trainee_dashboard.dart';
import 'trainner/trainer_dashboard.dart';
import 'LanguageSelectionScreen.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final SharedPreferenceManager _pref = SharedPreferenceManager();

  late final AnimationController _controller;
  VideoPlayerController? _videoController;

  bool _isVideoError = false;
  bool _videoInitialized = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _initializeVideo();
    _setupNavigationTimeout();

    // Save refreshed FCM token (initial save is handled in MyApp)
    FirebaseMessaging.instance.onTokenRefresh.listen(_pref.saveToken);
  }

  void _initializeVideo() {
    try {
      final controller =
      VideoPlayerController.asset("assets/videos/splash_logo.mp4");
      _videoController = controller;

      controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _videoInitialized = true;
        });
        controller
          ..setLooping(true)
          ..setVolume(0.0)
          ..play();
      }).catchError((e) {
        if (!mounted) return;
        setState(() {
          _isVideoError = true;
          _videoInitialized = true;
        });
        debugPrint('Video initialization error: $e');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVideoError = true;
        _videoInitialized = true;
      });
    }
  }

  void _setupNavigationTimeout() {
    // Wait for video initialization or fallback after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (!_videoInitialized) {
        setState(() {
          _isVideoError = true;
          _videoInitialized = true;
        });
      }
      _checkLanguageAndNavigate();
    });
  }

  Future<void> _checkLanguageAndNavigate() async {
    try {
      final code = await _pref.getLanguageCode();
      if (code == null) {
        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>LanguageSelectionScreen()),
        );
      } else {
        _navigateNext();
      }
    } catch (e) {
      debugPrint('Error checking language: $e');
      _navigateNext();
    }
  }

  Future<void> _navigateNext() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final token = await _pref.getToken();
      final role = await _pref.getRole();

      Widget nextScreen;
      if (token != null && token.isNotEmpty) {
        if (role == 'trainer') {
          nextScreen = TrainerDashboard();
        } else if (role == 'trainee') {
          nextScreen =TraineeDashboard();
        } else {
          nextScreen = const Login();
        }
      } else {
        nextScreen =LanguageSelectionScreen();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>LanguageSelectionScreen()),
      );
    }
  }

  Widget _buildVideoOrFallback() {
    if (!_videoInitialized) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final vc = _videoController;
    if (_isVideoError || vc == null || !vc.value.isInitialized) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text('Video unavailable', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SizedBox(
      width: 200,
      child: AspectRatio(
        aspectRatio: vc.value.aspectRatio,
        child: VideoPlayer(vc),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: SvgPicture.asset("assets/icons/tenon.svg"),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 2.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset("assets/icons/Peregrine_logo.svg"),
                    const SizedBox(height: 20),
                    SvgPicture.asset("assets/icons/Tenon_fm_logo.svg"),
                    const SizedBox(height: 20),
                    SvgPicture.asset("assets/icons/soteria-logo.svg"),
                    const SizedBox(height: 20),
                    _buildVideoOrFallback(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
