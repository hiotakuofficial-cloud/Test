import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class PlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;

  PlayerScreen({required this.streamUrl, required this.title});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  BetterPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  _initializePlayer() {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.streamUrl,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Referer': 'https://hianime.to/',
      },
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        fullScreenByDefault: false,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePlayPause: true,
          enableMute: true,
          enableFullscreen: true,
          enableProgressBar: true,
          enableSkips: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _controller != null
          ? BetterPlayer(controller: _controller!)
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
