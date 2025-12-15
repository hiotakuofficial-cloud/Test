import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String)? onCategorySelected;

  const CategoryGrid({
    Key? key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'No categories available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        children: categories.map((category) {
          return CategoryChip(
            label: category,
            isSelected: selectedCategory == category,
            onTap: () => onCategorySelected?.call(category),
          );
        }).toList(),
      ),
    );
  }
}