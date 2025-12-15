class Anime {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String poster;
  final String? type;
  final Map<String, int>? episodes;
  final String? duration;
  final int? rank;
  final String? synopsis;
  final String? aired;
  final String? quality;
  
  Anime({
    required this.id,
    required this.title,
    this.alternativeTitle,
    required this.poster,
    this.type,
    this.episodes,
    this.duration,
    this.rank,
    this.synopsis,
    this.aired,
    this.quality,
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
      synopsis: json['synopsis'],
      aired: json['aired'],
      quality: json['quality'],
    );
  }
}

class HomeData {
  final List<Anime> spotlight;
  final List<Anime> trending;
  final List<Anime> mostPopular;
  final List<Anime> top10;
  final List<Anime> topAiring;
  final List<Anime> topUpcoming;
  final List<Anime> newAdded;
  final List<Anime> latestEpisode;
  final List<Anime> latestCompleted;
  final List<Anime> mostFavorite;
  final List<String> genres;

  HomeData({
    required this.spotlight,
    required this.trending,
    required this.mostPopular,
    required this.top10,
    required this.topAiring,
    required this.topUpcoming,
    required this.newAdded,
    required this.latestEpisode,
    required this.latestCompleted,
    required this.mostFavorite,
    required this.genres,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    List<Anime> _parseAnimeList(dynamic data) {
      if (data == null || data is! List) return [];
      return data.map((e) => Anime.fromJson(e)).toList();
    }

    List<String> _parseGenresList(dynamic data) {
      if (data == null || data is! List) return [];
      return data.map((e) => e.toString()).toList();
    }

    return HomeData(
      spotlight: _parseAnimeList(json['spotlight']),
      trending: _parseAnimeList(json['trending']),
      mostPopular: _parseAnimeList(json['mostPopular']),
      top10: _parseAnimeList(json['top10']),
      topAiring: _parseAnimeList(json['topAiring']),
      topUpcoming: _parseAnimeList(json['topUpcoming']),
      newAdded: _parseAnimeList(json['newAdded']),
      latestEpisode: _parseAnimeList(json['latestEpisode']),
      latestCompleted: _parseAnimeList(json['latestCompleted']),
      mostFavorite: _parseAnimeList(json['mostFavorite']),
      genres: _parseGenresList(json['genres']),
    );
  }
}
