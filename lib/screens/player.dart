import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;

  PlayerScreen({required this.streamUrl, required this.title});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl));
      await _controller!.initialize();
      setState(() => _isLoading = false);
      _controller!.play();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading video: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _controller!.value.isInitialized
              ? Column(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    VideoProgressIndicator(_controller!, allowScrubbing: true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                )
              : Center(child: Text('Failed to load video')),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
