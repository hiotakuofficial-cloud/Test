class SearchFilters {
  final String? format; // TV, Movie, OVA
  final String? status; // Ongoing, Completed, Upcoming
  final int? yearFrom;
  final int? yearTo;
  final List<String> genres;
  final String sortBy; // popularity, rating, newest
  final bool ascending;

  SearchFilters({
    this.format,
    this.status,
    this.yearFrom,
    this.yearTo,
    this.genres = const [],
    this.sortBy = 'popularity',
    this.ascending = false,
  });

  bool get hasActiveFilters =>
      format != null ||
      status != null ||
      yearFrom != null ||
      yearTo != null ||
      genres.isNotEmpty ||
      sortBy != 'popularity' ||
      ascending != false;

  SearchFilters copyWith({
    String? format,
    String? status,
    int? yearFrom,
    int? yearTo,
    List<String>? genres,
    String? sortBy,
    bool? ascending,
  }) {
    return SearchFilters(
      format: format ?? this.format,
      status: status ?? this.status,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      genres: genres ?? this.genres,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  SearchFilters reset() {
    return SearchFilters();
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (format != null) params['format'] = format!;
    if (status != null) params['status'] = status!;
    if (yearFrom != null) params['yearFrom'] = yearFrom!.toString();
    if (yearTo != null) params['yearTo'] = yearTo!.toString();
    if (genres.isNotEmpty) params['genres'] = genres.join(',');
    params['sort'] = sortBy;
    if (ascending) params['order'] = 'asc';
    return params;
  }
}
