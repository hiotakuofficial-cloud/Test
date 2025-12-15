import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';

class WatchlistService {
  static const String _key = 'watchlist_anime_ids';
  static final WatchlistService _instance = WatchlistService._internal();
  factory WatchlistService() => _instance;
  WatchlistService._internal();

  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<String>> _getIds() async {
    await _init();
    return _prefs?.getStringList(_key) ?? [];
  }

  Future<void> _setIds(List<String> ids) async {
    await _init();
    await _prefs?.setStringList(_key, ids);
  }

  Future<List<Anime>> getWatchlist() async {
    final ids = await _getIds();
    if (ids.isEmpty) return [];

    List<Anime> watchlist = [];
    for (String id in ids) {
      try {
        final jsonStr = _prefs?.getString('anime_$id');
        if (jsonStr != null) {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          watchlist.add(Anime.fromJson(json));
        }
      } catch (e) {
        // Skip corrupted entries
        continue;
      }
    }
    return watchlist;
  }

  Future<bool> addToWatchlist(Anime anime) async {
    try {
      final ids = await _getIds();
      if (ids.contains(anime.id)) {
        return false; // Already in watchlist
      }

      ids.add(anime.id);
      await _setIds(ids);
      
      // Store anime data
      final json = anime.toJson();
      final jsonStr = jsonEncode(json);
      await _init();
      await _prefs?.setString('anime_${anime.id}', jsonStr);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromWatchlist(String animeId) async {
    try {
      final ids = await _getIds();
      if (!ids.contains(animeId)) {
        return false; // Not in watchlist
      }

      ids.remove(animeId);
      await _setIds(ids);
      
      // Remove stored anime data
      await _init();
      await _prefs?.remove('anime_$animeId');
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isInWatchlist(String animeId) async {
    final ids = await _getIds();
    return ids.contains(animeId);
  }

  Future<void> clearWatchlist() async {
    await _init();
    final ids = await _getIds();
    
    // Remove all anime data
    for (String id in ids) {
      await _prefs?.remove('anime_$id');
    }
    
    // Clear IDs
    await _prefs?.remove(_key);
  }
}