import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../models/anime.dart';
import '../providers/watchlist_provider.dart';
import 'web_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Anime> trending = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    try {
      final data = await ApiService.getHome();
      if (data['success']) {
        setState(() {
          trending = (data['data']['trending'] as List)
              .map((e) => Anime.fromJson(e))
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anime App')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: trending.length,
              itemBuilder: (context, index) {
                final anime = trending[index];
                return _AnimeListTile(
                  anime: anime,
                  onTapEpisodes: _showEpisodes,
                );
              },
            ),
    );
  }

  _showEpisodes(Anime anime) async {
    try {
      final data = await ApiService.getEpisodes(anime.id);
      if (data['success']) {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            height: 400,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(anime.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: (data['data'] as List).length,
                    itemBuilder: (context, index) {
                      final episode = data['data'][index];
                      return ListTile(
                        title: Text(episode['title']),
                        subtitle: Text('Episode ${episode['episodeNumber']}'),
                        onTap: () => _playEpisode(episode['id']),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading episodes')),
      );
    }
  }

  _playEpisode(String episodeId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Bypassing protection...'),
          ],
        ),
      ),
    );

    try {
      final streamData = await ApiService.getWorkingStream(episodeId);
      Navigator.pop(context); // Close loading dialog
      
      if (streamData['success'] && streamData['data'] != null) {
        final streamUrl = streamData['data']['link']['file'];
        final isBypassed = streamData['data']['bypassed'] ?? false;
        
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bypass failed: ${streamData['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _AnimeListTile extends StatelessWidget {
  final Anime anime;
  final Function(Anime) onTapEpisodes;

  const _AnimeListTile({
    required this.anime,
    required this.onTapEpisodes,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, watchlistProvider, child) {
        return FutureBuilder<bool>(
          future: watchlistProvider.isInWatchlist(anime.id),
          builder: (context, snapshot) {
            final isInWatchlist = snapshot.data ?? false;
            
            return ListTile(
              leading: Image.network(anime.poster, width: 50),
              title: Text(anime.title),
              subtitle: Text('${anime.type ?? 'Unknown'} • ${anime.episodes?['eps'] ?? 'N/A'} eps'),
              trailing: IconButton(
                icon: Icon(
                  isInWatchlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWatchlist ? Colors.red : null,
                ),
                onPressed: () async {
                  if (isInWatchlist) {
                    await watchlistProvider.removeFromWatchlist(anime.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed from watchlist'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => watchlistProvider.addToWatchlist(anime),
                        ),
                      ),
                    );
                  } else {
                    await watchlistProvider.addToWatchlist(anime);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to watchlist')),
                    );
                  }
                },
              ),
              onTap: () => onTapEpisodes(anime),
            );
          },
        );
      },
    );
  }
}
