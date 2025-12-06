import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/anime.dart';

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
                  subtitle: Text('${anime.type} • ${anime.episodes['eps']} eps'),
                );
              },
            ),
    );
  }
}
