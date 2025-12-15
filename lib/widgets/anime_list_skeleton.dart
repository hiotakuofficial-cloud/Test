import 'package:flutter/material.dart';
import '../theme.dart';
import 'shimmer_placeholder.dart';

class AnimeListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer(child: ShimmerBox(width: 50, height: 75)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Shimmer(child: ShimmerBox(width: double.infinity, height: 16)),
                    SizedBox(height: 8),
                    Shimmer(child: ShimmerBox(width: 150, height: 14)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
