import 'package:flutter/material.dart';
import '../models/search_filters.dart';
import 'filter_chip.dart';

class FilterDrawer extends StatefulWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onApply;

  const FilterDrawer({
    required this.initialFilters,
    required this.onApply,
  });

  @override
  _FilterDrawerState createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late SearchFilters filters;

  @override
  void initState() {
    super.initState();
    filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFormatSection(),
                SizedBox(height: 20),
                _buildStatusSection(),
                SizedBox(height: 20),
                _buildYearSection(),
                SizedBox(height: 20),
                _buildGenreSection(),
                SizedBox(height: 20),
                _buildSortSection(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => filters = filters.reset());
                    },
                    child: Text('Reset'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(filters);
                      Navigator.pop(context);
                    },
                    child: Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    final formats = ['TV', 'Movie', 'OVA', 'Special', 'ONA'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Format', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats.map((format) {
            return FilterChip(
              label: format,
              selected: filters.format == format,
              onPressed: () {
                setState(() {
                  if (filters.format == format) {
                    filters = filters.copyWith(format: null);
                  } else {
                    filters = filters.copyWith(format: format);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    final statuses = ['Ongoing', 'Completed', 'Upcoming'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statuses.map((status) {
            return FilterChip(
              label: status,
              selected: filters.status == status,
              onPressed: () {
                setState(() {
                  if (filters.status == status) {
                    filters = filters.copyWith(status: null);
                  } else {
                    filters = filters.copyWith(status: status);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYearSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Release Year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'From',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: TextEditingController(
                  text: filters.yearFrom?.toString() ?? '',
                ),
                onChanged: (value) {
                  setState(() {
                    filters = filters.copyWith(
                      yearFrom: value.isEmpty ? null : int.tryParse(value),
                    );
                  });
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'To',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: TextEditingController(
                  text: filters.yearTo?.toString() ?? '',
                ),
                onChanged: (value) {
                  setState(() {
                    filters = filters.copyWith(
                      yearTo: value.isEmpty ? null : int.tryParse(value),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreSection() {
    final genres = ['Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror', 'Mystery', 'Romance', 'Sci-Fi', 'Slice of Life', 'Sports', 'Thriller'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Genres', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres.map((genre) {
            return FilterChip(
              label: genre,
              selected: filters.genres.contains(genre),
              onPressed: () {
                setState(() {
                  final newGenres = List<String>.from(filters.genres);
                  if (newGenres.contains(genre)) {
                    newGenres.remove(genre);
                  } else {
                    newGenres.add(genre);
                  }
                  filters = filters.copyWith(genres: newGenres);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    final sortOptions = [
      ('popularity', 'Popularity'),
      ('rating', 'Rating'),
      ('newest', 'Newest'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort By', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortOptions.map((option) {
            return FilterChip(
              label: option.$2,
              selected: filters.sortBy == option.$1,
              onPressed: () {
                setState(() {
                  filters = filters.copyWith(sortBy: option.$1);
                });
              },
            );
          }).toList(),
        ),
        SizedBox(height: 12),
        CheckboxListTile(
          title: Text('Ascending Order'),
          value: filters.ascending,
          onChanged: (value) {
            setState(() {
              filters = filters.copyWith(ascending: value ?? false);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
