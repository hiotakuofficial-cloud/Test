import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bypass_service.dart';

class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  CacheEntry(this.data, this.timestamp);
}

class ApiService {
  static const baseUrl = 'https://server-hiotaku.onrender.com/api/v1';
  static final Map<String, CacheEntry> _cache = {};
  
  static Future<Map<String, dynamic>> _get(String endpoint, {bool useCache = false, Duration ttl = const Duration(minutes: 5)}) async {
    final url = '$baseUrl$endpoint';
    
    if (useCache && _cache.containsKey(url)) {
      final entry = _cache[url]!;
      if (DateTime.now().difference(entry.timestamp) < ttl) {
        return entry.data;
      } else {
        _cache.remove(url);
      }
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (useCache && data['success'] == true) {
          _cache[url] = CacheEntry(data, DateTime.now());
        }
        return data;
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getHome() async {
    return _get('/home', useCache: true);
  }
  
  static Future<Map<String, dynamic>> search(String keyword) async {
    return _get('/search?keyword=$keyword', useCache: true);
  }
  
  static Future<Map<String, dynamic>> getAnimeDetails(String id) async {
    return _get('/anime/$id', useCache: true);
  }
  
  static Future<Map<String, dynamic>> getEpisodes(String id) async {
    return _get('/episodes/$id', useCache: true);
  }
  
  static Future<Map<String, dynamic>> getServers(String episodeId) async {
    return _get('/servers?id=$episodeId');
  }
  
  static Future<Map<String, dynamic>> getStream(String episodeId, {String server = 'HD-2', String type = 'sub'}) async {
    return _get('/stream?id=$episodeId&server=$server&type=$type');
  }
  
  static Future<Map<String, dynamic>> getWorkingStream(String episodeId) async {
    try {
      // First try bypass service
      final bypassedStream = await BypassService.getBypassedStream(episodeId);
      if (bypassedStream['success']) {
        return bypassedStream;
      }
      
      // Fallback to original multi-server method
      final serversData = await getServers(episodeId);
      if (!serversData['success'] || serversData['data'] == null) {
        return {'success': false, 'error': 'No servers available'};
      }

      final servers = serversData['data']['sub'] as List;
      
      for (var server in servers) {
        if (server['name'] != null) {
          try {
            final streamData = await getStream(episodeId, server: server['name'], type: 'sub');
            if (streamData['success'] && streamData['data'] != null) {
              // Try to bypass this URL too
              final originalUrl = streamData['data']['link']['file'];
              final bypassedUrl = await BypassService.getBypassedUrl(originalUrl);
              
              if (bypassedUrl != null) {
                streamData['data']['link']['file'] = bypassedUrl;
                streamData['data']['bypassed'] = true;
              }
              
              return streamData;
            }
          } catch (e) {
            continue;
          }
        }
      }
      
      return {'success': false, 'error': 'No working servers found'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
