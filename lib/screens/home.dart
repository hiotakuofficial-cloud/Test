import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/anime.dart';
import 'web_player.dart';
import '../widgets/anime_tile.dart';
import '../widgets/anime_list_skeleton.dart';
import '../widgets/shimmer_placeholder.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Anime> trending = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    final data = await ApiService.getHome();
    if (mounted) {
      if (data['success'] == true) {
        setState(() {
          trending = (data['data']['trending'] as List)
              .map((e) => Anime.fromJson(e))
              .toList();
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Failed to load home data'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trending Anime')),
      body: loading
          ? AnimeListSkeleton()
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => loading = true);
                await loadData();
              },
              child: ListView.builder(
                itemCount: trending.length,
                itemBuilder: (context, index) {
                  return AnimeTile(
                    anime: trending[index],
                    onTap: () => _showEpisodes(trending[index]),
                  );
                },
              ),
            ),
    );
  }

  _showEpisodes(Anime anime) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => EpisodesSheet(
          anime: anime,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class EpisodesSheet extends StatefulWidget {
  final Anime anime;
  final ScrollController scrollController;

  const EpisodesSheet({
    Key? key,
    required this.anime,
    required this.scrollController,
  }) : super(key: key);

  @override
  _EpisodesSheetState createState() => _EpisodesSheetState();
}

class _EpisodesSheetState extends State<EpisodesSheet> {
  List<dynamic> episodes = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadEpisodes();
  }

  loadEpisodes() async {
    final data = await ApiService.getEpisodes(widget.anime.id);
    if (mounted) {
      if (data['success'] == true) {
        setState(() {
          episodes = data['data'];
          loading = false;
        });
      } else {
        setState(() {
          error = data['error'];
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                widget.anime.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? Center(child: CircularProgressIndicator()) // Or a specific skeleton for episodes
              : error != null
                  ? Center(child: Text('Error: $error'))
                  : ListView.builder(
                      controller: widget.scrollController,
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        final episode = episodes[index];
                        return ListTile(
                          title: Text('Episode ${episode['number'] ?? episode['episodeNumber']}'),
                          subtitle: Text(episode['title'] ?? ''),
                          trailing: Icon(Icons.play_arrow, color: AppColors.secondary),
                          onTap: () => _playEpisode(context, episode['id']),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  _playEpisode(BuildContext context, String episodeId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Resolving stream...'),
          ],
        ),
      ),
    );

    final streamData = await ApiService.getWorkingStream(episodeId);
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
    } else {
      return;
    }
    
    if (streamData['success'] == true && streamData['data'] != null) {
      final streamUrl = streamData['data']['link']['file'];
      final isBypassed = streamData['data']['bypassed'] ?? false;
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebPlayerScreen(
              streamUrl: streamUrl,
              title: 'Episode Stream',
              isBypassed: isBypassed,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${streamData['error'] ?? 'Unknown error'}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
