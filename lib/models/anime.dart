class Anime {
  final String id;
  final String title;
  final String poster;
  final String type;
  final Map<String, int> episodes;
  
  Anime({
    required this.id,
    required this.title,
    required this.poster,
    required this.type,
    required this.episodes,
  });
  
  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      poster: json['poster'] ?? '',
      type: json['type'] ?? '',
      episodes: Map<String, int>.from(json['episodes'] ?? {}),
    );
  }
}
