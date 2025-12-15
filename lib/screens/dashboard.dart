import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/anime.dart';
import '../widgets/section_header.dart';
import '../widgets/anime_carousel.dart';
import '../widgets/hero_banner.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/category_chips.dart';
import 'web_player.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  HomeData? _homeData;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _error = null;
        _loading = true;
      });
      
      final data = await ApiService.getHomeData();
      setState(() {
        _homeData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _refreshing = true);
    await _loadData();
    setState(() => _refreshing = false);
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
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

  void _playEpisode(String episodeId) async {
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

  List<Anime> _getFilteredAnime() {
    if (_homeData == null || _selectedGenre == null) return [];
    
    // This is a simplified filter - in a real app you'd need genre data for each anime
    return _selectedGenre == 'All' ? [] : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anime Dashboard'),
        elevation: 0,
      ),
      body: _loading ? _buildLoadingView() : _buildContentView(),
    );
  }

  Widget _buildLoadingView() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SkeletonHeroBanner(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(height: 24, width: 150),
                  SizedBox(height: 16),
                  SkeletonCarousel(itemCount: 5),
                  SizedBox(height: 24),
                  SkeletonLoader(height: 24, width: 140),
                  SizedBox(height: 16),
                  SkeletonCarousel(itemCount: 4),
                  SizedBox(height: 24),
                  SkeletonLoader(height: 24, width: 160),
                  SizedBox(height: 16),
                  SkeletonCarousel(itemCount: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView() {
    if (_error != null) {
      return _buildErrorView();
    }

    if (_homeData == null) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner (Spotlight)
            if (_homeData!.spotlight.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: HeroBanner(
                  anime: _homeData!.spotlight.first,
                  onTap: () => _showEpisodes(_homeData!.spotlight.first),
                ),
              ),
            
            // Categories
            if (_homeData!.genres.isNotEmpty) ..[
              SectionHeader(title: 'Browse by Genre'),
              CategoryGrid(
                categories: _selectedGenre == null ? ['All'] : ['All', ..._homeData!.genres],
                selectedCategory: _selectedGenre,
                onCategorySelected: (genre) {
                  setState(() {
                    _selectedGenre = genre == 'All' ? null : genre;
                  });
                },
              ),
            ],

            // Trending
            if (_homeData!.trending.isNotEmpty) ..[
              SectionHeader(
                title: 'Trending Now',
                subtitle: 'Most popular this week',
              ),
              AnimeCarousel(
                animeList: _homeData!.trending,
                onAnimeTap: _showEpisodes,
              ),
            ],

            // Most Popular
            if (_homeData!.mostPopular.isNotEmpty) ..[
              SectionHeader(
                title: 'Most Popular',
                subtitle: 'All-time favorites',
              ),
              AnimeCarousel(
                animeList: _homeData!.mostPopular,
                onAnimeTap: _showEpisodes,
              ),
            ],

            // Top Airing
            if (_homeData!.topAiring.isNotEmpty) ..[
              SectionHeader(
                title: 'Top Airing',
                subtitle: 'Currently airing shows',
              ),
              AnimeCarousel(
                animeList: _homeData!.topAiring,
                onAnimeTap: _showEpisodes,
              ),
            ],

            // New Added
            if (_homeData!.newAdded.isNotEmpty) ..[
              SectionHeader(
                title: 'Newly Added',
                subtitle: 'Latest additions to the catalog',
              ),
              AnimeCarousel(
                animeList: _homeData!.newAdded,
                onAnimeTap: _showEpisodes,
              ),
            ],

            // Top 10 (if available and not already shown)
            if (_homeData!.top10.isNotEmpty && !_homeData!.top10.any((a) => _homeData!.trending.contains(a))) ..[
              SectionHeader(
                title: 'Top 10',
                subtitle: 'Highest rated anime',
              ),
              AnimeCarousel(
                animeList: _homeData!.top10,
                onAnimeTap: _showEpisodes,
              ),
            ],

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Failed to load dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: Icon(Icons.refresh),
                  label: Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No data available',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  'The dashboard is currently empty',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}