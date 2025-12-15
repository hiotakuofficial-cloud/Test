import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAllPressed;
  final bool showSeeAll;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.onSeeAllPressed,
    this.showSeeAll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          if (showSeeAll && onSeeAllPressed != null)
            TextButton(
              onPressed: onSeeAllPressed,
              child: Text('See All', style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }
}