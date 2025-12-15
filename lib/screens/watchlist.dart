import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../providers/watchlist_provider.dart';
import '../services/api.dart';
import 'web_player.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late WatchlistProvider _watchlistProvider;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _watchlistProvider = WatchlistProvider();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    await _watchlistProvider.loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Watchlist'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all, color: Colors.red),
                  title: Text('Clear All'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_watchlistProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_watchlistProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_watchlistProvider.error!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadWatchlist,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_watchlistProvider.watchlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Your watchlist is empty'),
            SizedBox(height: 8),
            Text('Add anime to your watchlist to see them here'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWatchlist,
      child: _isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _watchlistProvider.watchlist.length,
      itemBuilder: (context, index) {
        final anime = _watchlistProvider.watchlist[index];
        return _buildAnimeCard(anime);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _watchlistProvider.watchlist.length,
      itemBuilder: (context, index) {
        final anime = _watchlistProvider.watchlist[index];
        return _buildAnimeListTile(anime);
      },
    );
  }

  Widget _buildAnimeCard(Anime anime) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Image.network(
              anime.poster,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${anime.type ?? 'Unknown'} • ${anime.episodes?['eps'] ?? 'N/A'} eps',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow, size: 20),
                        onPressed: () => _showEpisodes(anime),
                        tooltip: 'Play latest episode',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _showRemoveDialog(anime),
                        tooltip: 'Remove from watchlist',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeListTile(Anime anime) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Image.network(anime.poster, width: 50, fit: BoxFit.cover),
        title: Text(anime.title),
        subtitle: Text('${anime.type ?? 'Unknown'} • ${anime.episodes?['eps'] ?? 'N/A'} eps'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'play') {
              _showEpisodes(anime);
            } else if (value == 'remove') {
              _showRemoveDialog(anime);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'play',
              child: ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Play latest'),
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove'),
              ),
            ),
          ],
        ),
        onTap: () => _showEpisodes(anime),
      ),
    );
  }

  Future<void> _showEpisodes(Anime anime) async {
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

  Future<void> _playEpisode(String episodeId) async {
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

  void _showRemoveDialog(Anime anime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove from Watchlist'),
          content: Text('Are you sure you want to remove "${anime.title}" from your watchlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _watchlistProvider.removeFromWatchlist(anime.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed from watchlist'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => _watchlistProvider.addToWatchlist(anime),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Watchlist'),
          content: Text('Are you sure you want to clear your entire watchlist? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _watchlistProvider.clearWatchlist();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Watchlist cleared')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}