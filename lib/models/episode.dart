class Episode {
  final String id;
  final String episodeNumber;
  final String title;
  final String? description;
  final String? duration;
  final String? releaseDate;
  final String? language;
  final Map<String, ServerOption>? servers;
  
  Episode({
    required this.id,
    required this.episodeNumber,
    required this.title,
    this.description,
    this.duration,
    this.releaseDate,
    this.language,
    this.servers,
  });
  
  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? '',
      episodeNumber: json['episodeNumber']?.toString() ?? '',
      title: json['title'] ?? 'Episode ${json['episodeNumber']}',
      description: json['description'],
      duration: json['duration'],
      releaseDate: json['releaseDate'],
      language: json['language'] ?? 'sub',
    );
  }
  
  factory Episode.fromDetailedJson(Map<String, dynamic> json, Map<String, dynamic> serversData) {
    Map<String, ServerOption>? processedServers;
    if (serversData['success'] && serversData['data'] != null) {
      processedServers = {};
      final subServers = serversData['data']['sub'] as List?;
      final dubServers = serversData['data']['dub'] as List?;
      
      if (subServers != null) {
        for (var server in subServers) {
          if (server['name'] != null) {
            processedServers!['${server['name']}_sub'] = ServerOption(
              name: server['name'],
              type: 'sub',
              quality: extractQuality(server['name']),
            );
          }
        }
      }
      
      if (dubServers != null) {
        for (var server in dubServers) {
          if (server['name'] != null) {
            processedServers!['${server['name']}_dub'] = ServerOption(
              name: server['name'],
              type: 'dub',
              quality: extractQuality(server['name']),
            );
          }
        }
      }
    }
    
    return Episode(
      id: json['id'] ?? '',
      episodeNumber: json['episodeNumber']?.toString() ?? '',
      title: json['title'] ?? 'Episode ${json['episodeNumber']}',
      description: json['description'],
      duration: json['duration'],
      releaseDate: json['releaseDate'],
      language: json['language'] ?? 'sub',
      servers: processedServers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'episodeNumber': episodeNumber,
      'title': title,
      'description': description,
      'duration': duration,
      'releaseDate': releaseDate,
      'language': language,
    };
  }
  
  static String extractQuality(String serverName) {
    if (serverName.contains('HD')) return 'HD';
    if (serverName.contains('FHD')) return 'FHD';
    if (serverName.contains('4K')) return '4K';
    return 'Unknown';
  }
}

class ServerOption {
  final String name;
  final String type;
  final String quality;
  
  ServerOption({
    required this.name,
    required this.type,
    required this.quality,
  });
  
  String get displayName => '$name ($quality)';
  String get fullName => '${name}_$type';
}