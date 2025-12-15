import '../models/anime.dart';
import '../models/episode.dart';
import 'api.dart';

class EpisodeCacheService {
  static final Map<String, List<Episode>> _episodeCache = {};
  static final Map<String, DateTime> _cacheTimestamp = {};
  static const Duration _cacheValidity = Duration(hours: 1);

  static bool hasValidCache(String animeId) {
    final timestamp = _cacheTimestamp[animeId];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheValidity;
  }

  static List<Episode>? getCachedEpisodes(String animeId) {
    if (hasValidCache(animeId)) {
      return _episodeCache[animeId];
    }
    return null;
  }

  static Future<List<Episode>> getEpisodesWithCache(String animeId) async {
    // Return cached episodes if valid
    final cached = getCachedEpisodes(animeId);
    if (cached != null) {
      return cached;
    }

    // Fetch fresh episodes
    try {
      final data = await ApiService.getEpisodes(animeId);
      if (data['success']) {
        final episodes = (data['data'] as List)
            .map((e) => Episode.fromJson(e))
            .toList();
        
        // Cache the episodes
        _episodeCache[animeId] = episodes;
        _cacheTimestamp[animeId] = DateTime.now();
        
        return episodes;
      }
    } catch (e) {
      print('Error fetching episodes: $e');
    }
    
    return [];
  }

  static void clearCache() {
    _episodeCache.clear();
    _cacheTimestamp.clear();
  }

  static void clearAnimeCache(String animeId) {
    _episodeCache.remove(animeId);
    _cacheTimestamp.remove(animeId);
  }

  static int get cacheSize => _episodeCache.length;
}