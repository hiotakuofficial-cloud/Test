import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_filters.dart';
import 'bypass_service.dart';

class ApiService {
  static const baseUrl = 'https://server-hiotaku.onrender.com/api/v1';
  
  static Future<Map<String, dynamic>> getHome() async {
    final response = await http.get(Uri.parse('$baseUrl/home'));
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> search(String keyword, {SearchFilters? filters}) async {
    final params = <String, String>{'keyword': keyword};
    if (filters != null) {
      params.addAll(filters.toQueryParams());
    }
    
    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: params);
    final response = await http.get(uri);
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getAnimeDetails(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/anime/$id'));
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getEpisodes(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/episodes/$id'));
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getServers(String episodeId) async {
    final response = await http.get(Uri.parse('$baseUrl/servers?id=$episodeId'));
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getStream(String episodeId, {String server = 'HD-2', String type = 'sub'}) async {
    final response = await http.get(Uri.parse('$baseUrl/stream?id=$episodeId&server=$server&type=$type'));
    return json.decode(response.body);
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
