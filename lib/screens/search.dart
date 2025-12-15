import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../models/anime.dart';
import '../providers/watchlist_provider.dart';
import 'web_player.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Anime> results = [];
  bool loading = false;
  TextEditingController controller = TextEditingController();

  search(String query) async {
    if (query.isEmpty) return;
    
    setState(() => loading = true);
    try {
      final data = await ApiService.search(query);
      if (data['success']) {
        setState(() {
          results = (data['data']['response'] as List)
              .map((e) => Anime.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      print('Search error: $e');
    }
    setState(() => loading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Anime')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => search(controller.text),
                ),
              ),
              onSubmitted: search,
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final anime = results[index];
                      return _SearchAnimeListTile(
                        anime: anime,
                        onTapEpisodes: _showEpisodes,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchAnimeListTile extends StatelessWidget {
  final Anime anime;
  final Function(Anime) onTapEpisodes;

  const _SearchAnimeListTile({
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
