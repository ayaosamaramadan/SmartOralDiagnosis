import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/logo.mp4')
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(false);
        _controller.play();
        _controller.addListener(() {
          if (!_navigated && _controller.value.isInitialized) {
            final pos = _controller.value.position;
            final dur = _controller.value.duration;
            if (pos >= dur) {
              _navigated = true;
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          }
        });

        Future.delayed(const Duration(seconds: 8), () {
          if (!_navigated && mounted) {
            _navigated = true;
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }).catchError((e) {
        debugPrint('Video initialization error: $e');
      });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {  
    const Color dark = Color.fromARGB(255, 0, 0, 0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 0, 0, 0), dark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                    
                      constraints: const BoxConstraints(
                        maxWidth: 480,
                        maxHeight: 320,
                      ),
                      child: _initialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : SizedBox(
                              width: 200,
                              height: 120,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
