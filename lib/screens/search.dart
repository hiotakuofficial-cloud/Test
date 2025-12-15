import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/anime.dart';
import '../theme.dart';
import '../widgets/anime_tile.dart';
import '../widgets/anime_list_skeleton.dart';
import 'home.dart'; // Reuse EpisodesSheet

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Anime> results = [];
  bool loading = false;
  bool searched = false;
  TextEditingController controller = TextEditingController();

  search(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      loading = true;
      searched = true;
    });
    
    final data = await ApiService.search(query);
    
    if (mounted) {
      if (data['success'] == true) {
        setState(() {
          results = (data['data']['response'] as List)
              .map((e) => Anime.fromJson(e))
              .toList();
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          results = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Search failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Anime')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search anime...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    setState(() {
                      results = [];
                      searched = false;
                    });
                  },
                ),
              ),
              onSubmitted: search,
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: loading
                ? AnimeListSkeleton()
                : results.isEmpty
                    ? Center(
                        child: Text(
                          searched ? 'No results found' : 'Type to search',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          return AnimeTile(
                            anime: results[index],
                            onTap: () => _showEpisodes(results[index]),
                          );
                        },
                      ),
          ),
        ],
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
