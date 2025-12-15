import 'package:flutter/foundation.dart';
import '../models/anime.dart';
import '../services/watchlist_service.dart';

class WatchlistProvider with ChangeNotifier {
  final WatchlistService _watchlistService = WatchlistService();
  
  List<Anime> _watchlist = [];
  bool _isLoading = false;
  String? _error;

  List<Anime> get watchlist => List.unmodifiable(_watchlist);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWatchlist() async {
    _setLoading(true);
    try {
      _watchlist = await _watchlistService.getWatchlist();
      _setError(null);
    } catch (e) {
      _setError('Failed to load watchlist');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addToWatchlist(Anime anime) async {
    final success = await _watchlistService.addToWatchlist(anime);
    if (success) {
      _watchlist.add(anime);
      notifyListeners();
    }
    return success;
  }

  Future<bool> removeFromWatchlist(String animeId) async {
    final success = await _watchlistService.removeFromWatchlist(animeId);
    if (success) {
      _watchlist.removeWhere((anime) => anime.id == animeId);
      notifyListeners();
    }
    return success;
  }

  Future<bool> isInWatchlist(String animeId) async {
    return await _watchlistService.isInWatchlist(animeId);
  }

  Future<void> clearWatchlist() async {
    await _watchlistService.clearWatchlist();
    _watchlist.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}