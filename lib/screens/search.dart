import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/anime.dart';
import '../models/search_filters.dart';
import '../widgets/filter_drawer.dart';
import '../widgets/result_count_badge.dart';
import '../widgets/anime_card.dart';
import 'web_player.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Anime> results = [];
  bool loading = false;
  TextEditingController controller = TextEditingController();
  SearchFilters filters = SearchFilters();
  bool isGridView = false;
  int page = 1;
  bool hasMoreResults = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (hasMoreResults && !loading && controller.text.isNotEmpty) {
        _loadMore();
      }
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      loading = true;
      page = 1;
      hasMoreResults = true;
      results = [];
    });
    
    try {
      final data = await ApiService.search(query, filters: filters);
      if (data['success']) {
        setState(() {
          results = (data['data']['response'] as List)
              .map((e) => Anime.fromJson(e))
              .toList();
          hasMoreResults = results.length > 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    }
    setState(() => loading = false);
  }

  Future<void> _loadMore() async {
    setState(() => loading = true);
    try {
      page++;
      final data = await ApiService.search(controller.text, filters: filters);
      if (data['success']) {
        final newResults = (data['data']['response'] as List)
            .map((e) => Anime.fromJson(e))
            .toList();
        setState(() {
          results.addAll(newResults);
          hasMoreResults = newResults.isNotEmpty;
        });
      }
    } catch (e) {
      setState(() => hasMoreResults = false);
    }
    setState(() => loading = false);
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => FilterDrawer(
          initialFilters: filters,
          onApply: (newFilters) {
            setState(() => filters = newFilters);
            search(controller.text);
          },
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() => filters = filters.reset());
    search(controller.text);
  }

  void _toggleViewMode() {
    setState(() => isGridView = !isGridView);
  }

  void _playEpisode(Anime anime) {
    // Navigate to anime details and play first episode
    _showEpisodes(anime);
  }

  void _addToWatchlist(Anime anime) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${anime.title} added to watchlist')),
    );
  }

  void _showEpisodes(Anime anime) async {
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
                  child: Text(
                    anime.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: (data['data'] as List).length,
                    itemBuilder: (context, index) {
                      final episode = data['data'][index];
                      return ListTile(
                        title: Text(episode['title']),
                        subtitle: Text('Episode ${episode['episodeNumber']}'),
                        onTap: () => _playEpisodeStream(episode['id']),
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

  void _playEpisodeStream(String episodeId) async {
    Navigator.pop(context);
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
      Navigator.pop(context);
      
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Anime'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Search anime...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          isDense: true,
                        ),
                        onSubmitted: search,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.tune, color: Colors.white),
                        onPressed: _showFilterDrawer,
                        tooltip: 'Filters & Sort',
                      ),
                    ),
                  ],
                ),
                if (controller.text.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResultCountBadge(
                        count: results.length,
                        hasFilters: filters.hasActiveFilters,
                      ),
                      if (filters.hasActiveFilters)
                        GestureDetector(
                          onTap: _resetFilters,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.clear, size: 16, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Clear filters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: loading && results.isEmpty
                ? Center(child: CircularProgressIndicator())
                : results.isEmpty && controller.text.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : isGridView
                        ? _buildGridView()
                        : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length + (loading && results.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          return Center(child: CircularProgressIndicator());
        }
        final anime = results[index];
        return AnimeCard(
          anime: anime,
          onTap: () => _showEpisodes(anime),
          onPlay: () => _playEpisode(anime),
          onAddToWatchlist: () => _addToWatchlist(anime),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: results.length + (loading && results.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final anime = results[index];
        return AnimeListTile(
          anime: anime,
          onTap: () => _showEpisodes(anime),
          onPlay: () => _playEpisode(anime),
          onAddToWatchlist: () => _addToWatchlist(anime),
        );
      },
    );
  }
}
