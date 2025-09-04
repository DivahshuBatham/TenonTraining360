import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../environment/Environment.dart';
import '../model/VirtualCourseFilterById.dart';
import '../networking/api_config.dart';
import 'VirtualPdfViewerScreen.dart';

class VideoTrainingByTrainee extends StatefulWidget {
  const VideoTrainingByTrainee({super.key});

  @override
  State<VideoTrainingByTrainee> createState() => _VideoTrainingByTraineeState();
}

class _VideoTrainingByTraineeState extends State<VideoTrainingByTrainee> {
  CourseData? selectedCourse;
  YoutubePlayerController? _controller;
  bool _isLoading = true;
  bool _isValidUrl = true;
  bool _trainingCompletedShown = false;
  bool _durationInitialized = false;

  DateTime? _startTime;
  Duration _watchedDuration = Duration.zero;
  int _totalDurationInSeconds = 0;

  int? _courseId;
  String? _pdfUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _courseId = args['course_id'] as int?;
      _pdfUrl = args['pdf_url'] as String?;
    }
    _fetchCourse();
  }

  Future<void> _fetchCourse() async {
    setState(() => _isLoading = true);
    try {
      if (_courseId == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final response = await Dio().get(
        '${AppConfig.baseUrl}${ApiConfig.getCourse}?training_type=virtual&id=$_courseId',
      );

      if (!mounted) return;

      final result = VirtualCourseFilterById.fromJson(response.data);
      if (result.data.isNotEmpty) {
        setState(() {
          selectedCourse = result.data.first;
          _isLoading = false;
        });
        _initializePlayer(result.data.first);
      } else {
        setState(() {
          selectedCourse = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching course: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _initializePlayer(CourseData course) {
    _clearVideoSession();

    setState(() {
      _isValidUrl = true;
      _trainingCompletedShown = false;
      _durationInitialized = false;
      _watchedDuration = Duration.zero;
    });

    final videoId = YoutubePlayer.convertUrlToId(course.videoUrl.toString());
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          controlsVisibleAtStart: true,
        ),
      );

      _controller!.addListener(_youtubeListener);
    } else {
      setState(() => _isValidUrl = false);
    }
  }

  void _youtubeListener() {
    if (!mounted || _controller == null) return;

    final playerState = _controller!.value.playerState;

    if (!_durationInitialized && _controller!.metadata.duration.inSeconds > 0) {
      _totalDurationInSeconds = _controller!.metadata.duration.inSeconds;
      _durationInitialized = true;
    }

    if (playerState == PlayerState.playing && _startTime == null) {
      _startTime = DateTime.now();
    }

    if (_startTime != null &&
        (playerState == PlayerState.paused || playerState == PlayerState.ended)) {
      final sessionDuration = DateTime.now().difference(_startTime!);
      _watchedDuration += sessionDuration;
      _startTime = null;
      if (mounted) setState(() {});
    }

    final percentWatched = _totalDurationInSeconds > 0
        ? _watchedDuration.inSeconds / _totalDurationInSeconds
        : 0;

    if (!_trainingCompletedShown && percentWatched >= 0.7) {
      _trainingCompletedShown = true;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "🎉 You have completed 70% of the training! You can now open the material."
              ),
            ),
          );
          setState(() {});
        });
      }
    }
  }

  void _clearVideoSession() {
    if (_startTime != null) {
      final sessionDuration = DateTime.now().difference(_startTime!);
      _watchedDuration += sessionDuration;
      _startTime = null;
    }

    if (_controller != null) {
      _controller!.removeListener(_youtubeListener);
      _controller!.dispose();
      _controller = null;
    }
  }

  void _openPdfInline() {
    if (!mounted) return;
    if (_pdfUrl != null && _pdfUrl!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VirtualPdfViewerScreen(pdfUrl: _pdfUrl!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF URL not available.")),
      );
    }
  }

  @override
  void dispose() {
    _clearVideoSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : selectedCourse == null
            ? const Center(child: Text("No course found."))
            : SingleChildScrollView(child: _buildVideoContent()),
      ),
    );
  }

  Widget _buildVideoContent() {
    final percentWatched = _totalDurationInSeconds > 0
        ? (_watchedDuration.inSeconds / _totalDurationInSeconds * 100)
        .clamp(0, 100)
        : 0.0;

    if (_controller == null) {
      return const Center(child: Text("Invalid or no video URL"));
    }

    return Column(
      children: [
        YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.purple,
            bottomActions: const [
              SizedBox(width: 10),
              CurrentPosition(),
              SizedBox(width: 10),
              ProgressBar(isExpanded: true),
              FullScreenButton(),
            ],
          ),
          builder: (context, player) => Column(
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: player),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '⏱️ Watch Duration: ${_formatDuration(_watchedDuration)}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        Text(
          '📊 Watched: ${percentWatched.toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        if (_trainingCompletedShown)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '✅ Training Complete!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_pdfUrl != null && _pdfUrl!.isNotEmpty)
          Tooltip(
            message: _trainingCompletedShown
                ? 'Open the training material'
                : 'Watch at least 70% of video to unlock',
            child: OutlinedButton.icon(
              onPressed: _trainingCompletedShown ? _openPdfInline : null,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Open Training Material'),
              style: OutlinedButton.styleFrom(
                backgroundColor: _trainingCompletedShown
                    ? Colors.deepPurple
                    : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return minutes > 0
        ? '$minutes min ${seconds.toString().padLeft(2, '0')} sec'
        : '$seconds sec';
  }
}
