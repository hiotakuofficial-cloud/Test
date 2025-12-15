class Anime {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String poster;
  final String? type;
  final Map<String, int>? episodes;
  final String? duration;
  final int? rank;
  
  Anime({
    required this.id,
    required this.title,
    this.alternativeTitle,
    required this.poster,
    this.type,
    this.episodes,
    this.duration,
    this.rank,
  });
  
  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      alternativeTitle: json['alternativeTitle'],
      poster: json['poster'] ?? '',
      type: json['type'],
      episodes: json['episodes'] != null ? Map<String, int>.from(json['episodes']) : null,
      duration: json['duration'],
      rank: json['rank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'alternativeTitle': alternativeTitle,
      'poster': poster,
      'type': type,
      'episodes': episodes,
      'duration': duration,
      'rank': rank,
    };
  }
}
