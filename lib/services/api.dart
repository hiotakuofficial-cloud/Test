import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bypass_service.dart';

class ApiService {
  static const baseUrl = 'https://server-hiotaku.onrender.com/api/v1';
  
  static Future<Map<String, dynamic>> getHome() async {
    final response = await http.get(Uri.parse('$baseUrl/home'));
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> search(String keyword) async {
    final response = await http.get(Uri.parse('$baseUrl/search?keyword=$keyword'));
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
  
  static Future<Map<String, dynamic>> getWorkingStream(String episodeId, {
    Function(String)? onProgress,
    List<String>? preferredServers,
    String preferredType = 'sub',
  }) async {
    try {
      if (onProgress != null) onProgress('Initializing stream resolution...');
      
      // First try bypass service with progress
      if (onProgress != null) onProgress('Attempting primary bypass...');
      final bypassedStream = await BypassService.getBypassedStream(episodeId);
      if (bypassedStream['success']) {
        if (onProgress != null) onProgress('Primary bypass successful');
        return bypassedStream;
      }
      
      if (onProgress != null) onProgress('Primary bypass failed, trying servers...');
      
      // Fallback to original multi-server method
      final serversData = await getServers(episodeId);
      if (!serversData['success'] || serversData['data'] == null) {
        return {'success': false, 'error': 'No servers available'};
      }

      final subServers = serversData['data']['sub'] as List?;
      final dubServers = serversData['data']['dub'] as List?;
      List<dynamic> allServers = [];
      
      if (subServers != null) allServers.addAll(subServers);
      if (dubServers != null) allServers.addAll(dubServers);
      
      // Sort servers by preference
      if (preferredServers != null) {
        allServers.sort((a, b) {
          final aIndex = preferredServers.indexOf(a['name'] ?? '');
          final bIndex = preferredServers.indexOf(b['name'] ?? '');
          if (aIndex == -1 && bIndex == -1) return 0;
          if (aIndex == -1) return 1;
          if (bIndex == -1) return -1;
          return aIndex.compareTo(bIndex);
        });
      }
      
      for (var server in allServers) {
        if (server['name'] != null) {
          final serverType = dubServers?.contains(server) == true ? 'dub' : 'sub';
          
          try {
            if (onProgress != null) onProgress('Testing ${server['name']} ($serverType)...');
            
            final streamData = await getStream(
              episodeId, 
              server: server['name'], 
              type: serverType,
            );
            
            if (streamData['success'] && streamData['data'] != null) {
              if (onProgress != null) onProgress('Stream found, bypassing protection...');
              
              // Try to bypass this URL too
              final originalUrl = streamData['data']['link']['file'];
              final bypassedUrl = await BypassService.getBypassedUrl(originalUrl);
              
              if (bypassedUrl != null) {
                streamData['data']['link']['file'] = bypassedUrl;
                streamData['data']['bypassed'] = true;
                if (onProgress != null) onProgress('Bypass successful');
                return streamData;
              } else {
                if (onProgress != null) onProgress('Stream accessible without bypass');
                return streamData;
              }
            }
          } catch (e) {
            if (onProgress != null) onProgress('${server[\'name\']} failed, trying next...');
            continue;
          }
        }
      }
      
      return {'success': false, 'error': 'No working servers found after trying all options'};
    } catch (e) {
      if (onProgress != null) onProgress('Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getWorkingStreamWithFallback(
    String episodeId, {
    Function(String)? onProgress,
  }) async {
    final result = await getWorkingStream(episodeId, onProgress: onProgress);
    
    if (!result['success']) {
      // Try with different server preferences
      final fallbackServers = ['HD-2', 'HD-1', 'SD-1', 'HD-3'];
      if (onProgress != null) onProgress('Trying fallback servers...');
      
      return await getWorkingStream(
        episodeId,
        onProgress: onProgress,
        preferredServers: fallbackServers,
      );
    }
    
    return result;
  }
}
