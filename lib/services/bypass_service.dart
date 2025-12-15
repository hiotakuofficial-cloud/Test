import 'dart:convert';
import 'package:http/http.dart' as http;

class BypassService {
  static const String proxyUrl = 'https://cors-anywhere.herokuapp.com/';
  
  static Map<String, String> getBypassHeaders() {
    return {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Referer': 'https://hianime.to/',
      'Origin': 'https://hianime.to',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'cross-site',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };
  }
  
  static Future<String?> getBypassedUrl(String originalUrl) async {
    try {
      // Method 1: Try with bypass headers
      final response = await http.head(
        Uri.parse(originalUrl),
        headers: getBypassHeaders(),
      );
      
      if (response.statusCode == 200) {
        return originalUrl;
      }
      
      // Method 2: Try with CORS proxy
      final proxyResponse = await http.head(
        Uri.parse('$proxyUrl$originalUrl'),
        headers: getBypassHeaders(),
      );
      
      if (proxyResponse.statusCode == 200) {
        return '$proxyUrl$originalUrl';
      }
      
      // Method 3: Extract direct URL from m3u8
      return await extractDirectUrl(originalUrl);
      
    } catch (e) {
      print('Bypass error: $e');
      return null;
    }
  }

  static Future<String?> getBypassedUrlWithProgress(
    String originalUrl,
    Function(String) onProgress,
  ) async {
    try {
      onProgress('Testing bypass method 1...');
      // Method 1: Try with bypass headers
      final response = await http.head(
        Uri.parse(originalUrl),
        headers: getBypassHeaders(),
      );
      
      if (response.statusCode == 200) {
        onProgress('Bypass successful (Method 1)');
        return originalUrl;
      }
      
      onProgress('Testing bypass method 2...');
      // Method 2: Try with CORS proxy
      final proxyResponse = await http.head(
        Uri.parse('$proxyUrl$originalUrl'),
        headers: getBypassHeaders(),
      );
      
      if (proxyResponse.statusCode == 200) {
        onProgress('Bypass successful (Method 2)');
        return '$proxyUrl$originalUrl';
      }
      
      onProgress('Extracting direct URL...');
      // Method 3: Extract direct URL from m3u8
      final directUrl = await extractDirectUrl(originalUrl);
      if (directUrl != null) {
        onProgress('Direct URL extracted');
        return directUrl;
      }
      
      onProgress('All bypass methods failed');
      return null;
      
    } catch (e) {
      onProgress('Error: $e');
      return null;
    }
  }
  
  static Future<String?> extractDirectUrl(String m3u8Url) async {
    try {
      final response = await http.get(
        Uri.parse(m3u8Url),
        headers: getBypassHeaders(),
      );
      
      if (response.statusCode == 200) {
        final content = response.body;
        
        // Parse m3u8 content to find highest quality stream
        final lines = content.split('\n');
        String? bestUrl;
        
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('#EXT-X-STREAM-INF')) {
            if (i + 1 < lines.length && !lines[i + 1].startsWith('#')) {
              bestUrl = lines[i + 1].trim();
              
              // Make relative URLs absolute
              if (bestUrl.startsWith('/')) {
                final uri = Uri.parse(m3u8Url);
                bestUrl = '${uri.scheme}://${uri.host}$bestUrl';
              } else if (!bestUrl.startsWith('http')) {
                final uri = Uri.parse(m3u8Url);
                final basePath = uri.path.substring(0, uri.path.lastIndexOf('/') + 1);
                bestUrl = '${uri.scheme}://${uri.host}$basePath$bestUrl';
              }
            }
          }
        }
        
        return bestUrl;
      }
    } catch (e) {
      print('M3U8 parse error: $e');
    }
    
    return null;
  }
  
  static Future<Map<String, dynamic>> getBypassedStream(String episodeId) async {
    try {
      // Get original stream data
      final response = await http.get(
        Uri.parse('https://server-hiotaku.onrender.com/api/v1/stream?id=$episodeId&server=HD-2&type=sub'),
        headers: getBypassHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] && data['data'] != null) {
          final originalUrl = data['data']['link']['file'];
          
          // Try to bypass the URL
          final bypassedUrl = await getBypassedUrl(originalUrl);
          
          if (bypassedUrl != null) {
            // Update the URL in response
            data['data']['link']['file'] = bypassedUrl;
            data['data']['bypassed'] = true;
            return data;
          }
        }
      }
      
      return {'success': false, 'error': 'Bypass failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
