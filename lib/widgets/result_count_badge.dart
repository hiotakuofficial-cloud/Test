import 'package:flutter/material.dart';

class ResultCountBadge extends StatelessWidget {
  final int count;
  final bool hasFilters;

  const ResultCountBadge({
    required this.count,
    this.hasFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasFilters ? Colors.orange[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasFilters ? Colors.orange[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: hasFilters ? Colors.orange[700] : Colors.grey[700],
          ),
          SizedBox(width: 6),
          Text(
            '$count result${count == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasFilters ? Colors.orange[700] : Colors.grey[700],
            ),
          ),
          if (hasFilters) ...[
            SizedBox(width: 6),
            Icon(
              Icons.filter_list,
              size: 14,
              color: Colors.orange[700],
            ),
          ],
        ],
      ),
    );
  }
}
