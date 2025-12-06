import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/anime.dart';
import 'player.dart';

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
                return ListTile(
                  leading: Image.network(anime.poster, width: 50),
                  title: Text(anime.title),
                  subtitle: Text('${anime.type ?? 'Unknown'} • ${anime.episodes?['eps'] ?? 'N/A'} eps'),
                  onTap: () => _showEpisodes(anime),
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
    try {
      final streamData = await ApiService.getStream(episodeId);
      if (streamData['success'] && streamData['data'] != null) {
        final streamUrl = streamData['data']['link']['file'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              streamUrl: streamUrl,
              title: 'Episode Player',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No stream available')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting stream')),
      );
    }
  }
}
