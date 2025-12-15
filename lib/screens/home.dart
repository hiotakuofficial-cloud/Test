import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/api.dart';
import '../models/anime.dart';
import '../widgets/premium/hero_banner.dart';
import '../widgets/premium/carousel_card.dart';
import '../widgets/premium/gradient_section.dart';
import '../widgets/premium/loading_skeletons.dart';
import 'web_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Anime> trending = [];
  List<Anime> latest = [];
  List<Anime> popular = [];
  bool loading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  loadData() async {
    try {
      final data = await ApiService.getHome();
      if (data['success']) {
        final trendingData = data['data']['trending'] as List;
        setState(() {
          trending = trendingData.map((e) => Anime.fromJson(e)).toList();
          // Simulate other sections with some trending data
          latest = trendingData.skip(2).take(10).map((e) => Anime.fromJson(e)).toList();
          popular = trendingData.skip(1).take(10).map((e) => Anime.fromJson(e)).toList();
          loading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimationLimiter(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Hero Banner
                  if (trending.isNotEmpty)
                    HeroBanner(
                      title: trending.first.title,
                      subtitle: '${trending.first.type ?? 'Anime'} • ${trending.first.episodes?['eps'] ?? '12'} Episodes',
                      imageUrl: trending.first.poster,
                      onPlay: () => _showEpisodes(trending.first),
                      onMoreInfo: () => _showEpisodes(trending.first),
                    ),
                  
                  // Trending Section
                  GradientSection(
                    title: 'Trending Now',
                    subtitle: 'The most popular anime this season',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
                    ),
                    onViewAll: () {
                      // Navigate to full trending list
                    },
                    child: _buildCarousel(trending),
                  ),
                  
                  // Latest Section
                  GradientSection(
                    title: 'Latest Episodes',
                    subtitle: 'Fresh content just dropped',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
                    ),
                    onViewAll: () {
                      // Navigate to full latest list
                    },
                    child: _buildCarousel(latest),
                  ),
                  
                  // Popular Section
                  GradientSection(
                    title: 'Popular All Time',
                    subtitle: 'Timeless classics that never get old',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4081), Color(0xFFFF6B9D)],
                    ),
                    onViewAll: () {
                      // Navigate to full popular list
                    },
                    child: _buildCarousel(popular),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              // Hero skeleton
              Container(
                height: 400,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: const Color(0xFF1A1A2E),
                ),
                child: Column(
                  children: [
                    // Image skeleton
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                          gradient: LinearGradient(
                            colors: [Color(0xFF2A2A3E), Color(0xFF3A3A4E)],
                          ),
                        ),
                      ),
                    ),
                    
                    // Content skeleton
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Featured badge
                          Container(
                            width: 100,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A3E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Title
                          Container(
                            width: double.infinity,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A3E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Subtitle
                          Container(
                            width: 200,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A3E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Carousel skeletons
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 150,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A3E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 80,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A3E),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Carousel
                      SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return const CarouselCardSkeleton();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(List<Anime> animeList) {
    if (animeList.isEmpty) {
      return const SizedBox(height: 100);
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return CarouselCard(
            title: anime.title,
            imageUrl: anime.poster,
            subtitle: '${anime.type ?? 'Anime'}',
            genre: anime.type,
            rating: 4.2, // Mock rating
            onTap: () => _showEpisodes(anime),
          );
        },
      ),
    );
  }

  _showEpisodes(Anime anime) async {
    HapticFeedback.lightImpact();
    
    try {
      final data = await ApiService.getEpisodes(anime.id);
      if (data['success']) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _buildEpisodesModal(anime, data['data']),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading episodes'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }

  Widget _buildEpisodesModal(Anime anime, List episodes) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Modal handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF404040),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    anime.poster,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${anime.type ?? 'Anime'} • ${episodes.length} Episodes',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Episodes list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      episode['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Episode ${episode['episodeNumber']}',
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                    onTap: () => _playEpisode(episode['id']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _playEpisode(String episodeId) async {
    Navigator.pop(context); // Close episodes modal
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'Bypassing protection...',
                style: const TextStyle(color: Colors.white),
              ),
            ),
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
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => WebPlayerScreen(
              streamUrl: streamUrl,
              title: 'Episode Stream',
              isBypassed: isBypassed,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bypass failed: ${streamData['error'] ?? 'Unknown error'}'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }
}
