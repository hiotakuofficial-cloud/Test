import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../models/episode.dart';
import '../services/episode_cache_service.dart';
import '../services/api.dart';
import '../services/bypass_service.dart';
import 'player.dart';
import 'web_player.dart';

class EpisodeManagerScreen extends StatefulWidget {
  final Anime anime;

  const EpisodeManagerScreen({Key? key, required this.anime}) : super(key: key);

  @override
  _EpisodeManagerScreenState createState() => _EpisodeManagerScreenState();
}

class _EpisodeManagerScreenState extends State<EpisodeManagerScreen> {
  List<Episode> episodes = [];
  bool loading = true;
  String? error;
  Episode? selectedEpisode;
  ServerOption? selectedServer;
  String? bypassProgress;
  bool isBypassing = false;

  @override
  void initState() {
    super.initState();
    loadEpisodes();
  }

  Future<void> loadEpisodes() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final cachedEpisodes = EpisodeCacheService.getCachedEpisodes(widget.anime.id);
      if (cachedEpisodes != null) {
        setState(() {
          episodes = cachedEpisodes;
          loading = false;
        });
        return;
      }

      final data = await ApiService.getEpisodes(widget.anime.id);
      if (data['success']) {
        final episodeData = (data['data'] as List)
            .map((e) => Episode.fromJson(e))
            .toList();
        
        // Fetch server information for each episode (parallel requests for better performance)
        final enhancedEpisodes = <Episode>[];
        final serverRequests = episodeData.map((episode) async {
          try {
            final serversData = await ApiService.getServers(episode.id);
            return Episode.fromDetailedJson(episode.toJson(), serversData);
          } catch (e) {
            // If server data fails, use original episode but add a note
            print('Failed to get servers for episode ${episode.id}: $e');
            return episode;
          }
        }).toList();
        
        final results = await Future.wait(serverRequests);
        enhancedEpisodes.addAll(results);

        setState(() {
          episodes = enhancedEpisodes;
          EpisodeCacheService._episodeCache[widget.anime.id] = enhancedEpisodes;
          EpisodeCacheService._cacheTimestamp[widget.anime.id] = DateTime.now();
          loading = false;
        });
      } else {
        setState(() {
          error = data['error'] ?? 'Failed to load episodes';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  void _showEpisodeDetail(Episode episode) {
    setState(() {
      selectedEpisode = episode;
      selectedServer = null;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EpisodeDetailBottomSheet(
        episode: episode,
        onPlay: _playEpisode,
        isBypassing: isBypassing,
        bypassProgress: bypassProgress,
      ),
    );
  }

  Future<void> _playEpisode(Episode episode, ServerOption server) async {
    Navigator.pop(context); // Close bottom sheet
    
    setState(() {
      selectedEpisode = episode;
      selectedServer = server;
      isBypassing = true;
      bypassProgress = 'Initializing bypass...';
    });

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BypassProgressDialog(
        episode: episode,
        server: server,
        onCancel: () => Navigator.pop(context),
      ),
    );

    try {
      setState(() => bypassProgress = 'Getting stream URL...');
      
      // Get stream data for selected server
      final streamData = await ApiService.getStream(
        episode.id,
        server: server.name,
        type: server.type,
      );
      
      if (!streamData['success'] || streamData['data'] == null) {
        Navigator.pop(context); // Close progress dialog
        _showFallbackDialog('Stream not available', 'This server/quality combination is not available.');
        return;
      }

      setState(() => bypassProgress = 'Bypassing protection...');
      
      final originalUrl = streamData['data']['link']['file'];
      
      // Try to bypass the URL
      final bypassedUrl = await BypassService.getBypassedUrlWithProgress(
        originalUrl,
        (progress) => setState(() => bypassProgress = progress),
      );

      Navigator.pop(context); // Close progress dialog

      if (bypassedUrl != null) {
        setState(() {
          isBypassing = false;
          bypassProgress = 'Bypass successful!';
        });

        // Show playback options
        _showPlaybackOptions(episode, bypassedUrl, true);
      } else {
        setState(() => bypassProgress = 'Bypass failed');
        _showFallbackDialog('Bypass Failed', 'Could not bypass protection for this server.');
      }
      
    } catch (e) {
      Navigator.pop(context); // Close progress dialog
      _showFallbackDialog('Error', 'Error during playback: $e');
    } finally {
      setState(() {
        isBypassing = false;
        bypassProgress = null;
      });
    }
  }

  void _showPlaybackOptions(Episode episode, String streamUrl, bool isBypassed) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Player',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.play_circle, color: Colors.blue),
              title: Text('Native Player'),
              subtitle: Text('Best performance with hardware acceleration'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      streamUrl: streamUrl,
                      title: '${widget.anime.title} - ${episode.title}',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.web, color: Colors.green),
              title: Text('Web Player / Export URL'),
              subtitle: Text('Copy URL or view instructions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPlayerScreen(
                      streamUrl: streamUrl,
                      title: '${widget.anime.title} - ${episode.title}',
                      isBypassed: isBypassed,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFallbackDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.anime.title),
            Text(
              '${episodes.length} episodes',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadEpisodes,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(error!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadEpisodes,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : episodes.isEmpty
                  ? Center(
                      child: Text('No episodes available'),
                    )
                  : RefreshIndicator(
                      onRefresh: loadEpisodes,
                      child: ListView.builder(
                        itemCount: episodes.length,
                        itemBuilder: (context, index) {
                          final episode = episodes[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(episode.episodeNumber),
                              ),
                              title: Text(episode.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (episode.duration != null)
                                    Text('Duration: ${episode.duration}'),
                                  if (episode.releaseDate != null)
                                    Text('Released: ${episode.releaseDate}'),
                                  if (episode.servers != null && episode.servers!.isNotEmpty)
                                    Text('Servers: ${episode.servers!.length} available'),
                                ],
                              ),
                              trailing: episode.servers != null && episode.servers!.isNotEmpty
                                  ? Icon(Icons.play_arrow)
                                  : null,
                              onTap: () => _showEpisodeDetail(episode),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class EpisodeDetailBottomSheet extends StatefulWidget {
  final Episode episode;
  final Function(Episode, ServerOption) onPlay;
  final bool isBypassing;
  final String? bypassProgress;

  const EpisodeDetailBottomSheet({
    Key? key,
    required this.episode,
    required this.onPlay,
    this.isBypassing = false,
    this.bypassProgress,
  }) : super(key: key);

  @override
  _EpisodeDetailBottomSheetState createState() => _EpisodeDetailBottomSheetState();
}

class _EpisodeDetailBottomSheetState extends State<EpisodeDetailBottomSheet> {
  ServerOption? selectedServer;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Episode info
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.episode.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text('Episode ${widget.episode.episodeNumber}'),
                        ),
                        if (widget.episode.language != null) ...[
                          SizedBox(width: 8),
                          Chip(
                            label: Text(widget.episode.language!),
                            backgroundColor: Colors.blue[100],
                          ),
                        ],
                        if (widget.episode.duration != null) ...[
                          SizedBox(width: 8),
                          Chip(
                            label: Text(widget.episode.duration!),
                            backgroundColor: Colors.green[100],
                          ),
                        ],
                      ],
                    ),
                    if (widget.episode.description != null) ...[
                      SizedBox(height: 12),
                      Text(
                        widget.episode.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              // Server selection
              if (widget.episode.servers != null && widget.episode.servers!.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select Server & Quality',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: widget.episode.servers!.values.map((server) {
                      return RadioListTile<ServerOption>(
                        value: server,
                        groupValue: selectedServer,
                        onChanged: (value) {
                          setState(() {
                            selectedServer = value;
                          });
                        },
                        title: Text(server.displayName),
                        subtitle: Text('${server.type.toUpperCase()} • ${server.quality}'),
                        secondary: Icon(Icons.play_circle_outline),
                      );
                    }).toList(),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No servers available for this episode'),
                      ],
                    ),
                  ),
                ),
              ],
              // Play button
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: selectedServer != null
                        ? () => widget.onPlay(widget.episode, selectedServer!)
                        : null,
                    icon: widget.isBypassing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.play_arrow),
                    label: widget.isBypassing
                        ? Text(widget.bypassProgress ?? 'Processing...')
                        : Text('Play Episode'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BypassProgressDialog extends StatelessWidget {
  final Episode episode;
  final ServerOption server;
  final VoidCallback onCancel;

  const BypassProgressDialog({
    Key? key,
    required this.episode,
    required this.server,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Processing Episode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '${episode.title}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Server: ${server.displayName}'),
          Text(
            'Bypassing protection...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel'),
        ),
      ],
    );
  }
}