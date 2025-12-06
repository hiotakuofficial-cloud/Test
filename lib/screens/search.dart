import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/anime.dart';

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
                      return ListTile(
                        leading: Image.network(anime.poster, width: 50),
                        title: Text(anime.title),
                        subtitle: Text('${anime.type} • ${anime.episodes['eps']} eps'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
