class Anime {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String poster;
  final String? type;
  final Map<String, int>? episodes;
  final String? duration;
  final int? rank;
  final double? rating;
  final int? releaseYear;
  final String? status;
  final List<String>? genres;
  
  Anime({
    required this.id,
    required this.title,
    this.alternativeTitle,
    required this.poster,
    this.type,
    this.episodes,
    this.duration,
    this.rank,
    this.rating,
    this.releaseYear,
    this.status,
    this.genres,
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
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      releaseYear: json['releaseYear'],
      status: json['status'],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
    );
  }
}
