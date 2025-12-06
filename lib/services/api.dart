import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://servepiu.onrender.com/api/v1';
  
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
  
  static Future<Map<String, dynamic>> getStream(String episodeId) async {
    final response = await http.get(Uri.parse('$baseUrl/stream?id=$episodeId'));
    return json.decode(response.body);
  }
}
