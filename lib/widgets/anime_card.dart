import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final String title;
  final String image;
  
  const AnimeCard({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Image placeholder
          Container(
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
