import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../theme.dart';
import 'app_image.dart';

class AnimeTile extends StatelessWidget {
  final Anime anime;
  final VoidCallback onTap;

  const AnimeTile({Key? key, required this.anime, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AppImage(
          imageUrl: anime.poster,
          width: 50,
          height: 75,
        ),
      ),
      title: Text(
        anime.title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${anime.type ?? 'Unknown'} • ${anime.episodes?['eps'] ?? 'N/A'} eps',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: onTap,
    );
  }
}
