import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:doloooki/utils/palette.dart';

class VideoLoadingScreen extends StatefulWidget {
  const VideoLoadingScreen({super.key});

  @override
  State<VideoLoadingScreen> createState() => _VideoLoadingScreenState();
}

class _VideoLoadingScreenState extends State<VideoLoadingScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/onboarding/onboarding_video.mp4');
      await _controller.initialize();
      
      setState(() {
        _isVideoInitialized = true;
      });
      
      _controller.play();
      _controller.setLooping(true);
      
    } catch (e) {
      print('Ошибка загрузки видео: $e');
      // Если видео не загружается, просто показываем красный фон
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.red600,
      body: _isVideoInitialized
          ? VideoPlayer(_controller)
          : Container(
              color: Palette.red600,
              child: Center(
                child: CircularProgressIndicator(
                  color: Palette.white100,
                ),
              ),
            ),
    );
  }
} 