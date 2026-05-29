import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:meal_box/spalsh/onboarding_page.dart';

import 'package:video_player/video_player.dart';

class VideoSplashPage extends StatefulWidget {
  const VideoSplashPage({super.key});

  @override
  State<VideoSplashPage> createState() => _VideoSplashPageState();
}

class _VideoSplashPageState extends State<VideoSplashPage> {
  late VideoPlayerController _videoController;
  bool _initialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/intro.mp4');

    try {
      await _videoController.initialize();
      log('✅ Video initialized', name: 'VideoSplash');
      log(
        '📏 Duration: ${_videoController.value.duration}',
        name: 'VideoSplash',
      );
      log('📐 Size: ${_videoController.value.size}', name: 'VideoSplash');

      _videoController
        ..setLooping(false)
        ..setVolume(1.0);

      if (!mounted) return;
      setState(() => _initialized = true);
      log('✅ setState done, _initialized = true', name: 'VideoSplash');

      _videoController.play();
      log('▶️ play() called', name: 'VideoSplash');

      await Future.delayed(_videoController.value.duration);
      log('⏱️ Duration elapsed, calling _navigate()', name: 'VideoSplash');

      _navigate();
    } catch (e, st) {
      log('❌ Error: $e', name: 'VideoSplash');
      log('❌ Stack: $st', name: 'VideoSplash');
      _navigate();
    }
  }

  void _onVideoProgress() {
    final val = _videoController.value;
    if (val.isInitialized &&
        !val.isPlaying &&
        !val.isBuffering &&
        val.duration > Duration.zero &&
        val.position >= val.duration - const Duration(milliseconds: 100)) {
      _navigate();
    }
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _videoController.removeListener(_onVideoProgress);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoProgress);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _initialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          : const SizedBox.shrink(), // black screen while video initializes
    );
  }
}
