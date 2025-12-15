import 'package:flutter/material.dart';
import '../models/anime.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onPlay;
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onTap;

  const AnimeCard({
    required this.anime,
    this.onPlay,
    this.onAddToWatchlist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    anime.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                  if (anime.rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              anime.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (anime.type != null)
                            Text(
                              anime.type!,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          SizedBox(height: 2),
                          Text(
                            anime.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (anime.status != null)
                          Text(
                            anime.status!,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        if (anime.releaseYear != null)
                          Text(
                            '${anime.releaseYear}',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  if (onPlay != null)
                    GestureDetector(
                      onTap: onPlay,
                      child: Icon(Icons.play_circle_outline, size: 20, color: Colors.blue),
                    ),
                  if (onAddToWatchlist != null) ...[
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: onAddToWatchlist,
                      child: Icon(Icons.bookmark_outline, size: 20, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeListTile extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onPlay;
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onTap;

  const AnimeListTile({
    required this.anime,
    this.onPlay,
    this.onAddToWatchlist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  anime.poster,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (anime.type != null)
                          Flexible(child: Text(anime.type!, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
                        if (anime.type != null && anime.episodes != null) SizedBox(width: 4),
                        if (anime.episodes != null)
                          Flexible(
                            child: Text(
                              '${anime.episodes!['eps'] ?? 'N/A'} eps',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                    if (anime.rating != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            anime.rating!.toStringAsFixed(1),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    if (anime.genres != null && anime.genres!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          anime.genres!.take(2).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onPlay != null)
                    GestureDetector(
                      onTap: onPlay,
                      child: Icon(Icons.play_circle_outline, size: 24, color: Colors.blue),
                    ),
                  if (onAddToWatchlist != null) ...[
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: onAddToWatchlist,
                      child: Icon(Icons.bookmark_outline, size: 20, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
