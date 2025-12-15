import 'package:flutter/material.dart';
import '../models/anime.dart';

class AnimeCarousel extends StatelessWidget {
  final List<Anime> animeList;
  final Function(Anime)? onAnimeTap;
  final double height;
  final double width;

  const AnimeCarousel({
    Key? key,
    required this.animeList,
    this.onAnimeTap,
    this.height = 200,
    this.width = 130,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animeList.isEmpty) {
      return Container(
        height: height,
        child: Center(
          child: Text(
            'No items available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: animeList.length,
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return Container(
            width: width,
            margin: EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onAnimeTap?.call(anime),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        anime.poster,
                        width: width,
                        height: height * 0.7,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: width,
                            height: height * 0.7,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    anime.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (anime.episodes?['eps'] != null) ...[
                    SizedBox(height: 4),
                    Text(
                      '${anime.episodes!['eps']} eps',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}