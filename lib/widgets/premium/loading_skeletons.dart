import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundDark,
      highlightColor: AppColors.surfaceDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Carousel card skeleton
class CarouselCardSkeleton extends StatelessWidget {
  const CarouselCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surfaceDark,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ShimmerLoading(
              width: double.infinity,
              height: 160,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            
            // Content placeholder
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre badge
                  ShimmerLoading(
                    width: 80,
                    height: 20,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Title
                  ShimmerLoading(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  ShimmerLoading(
                    width: 120,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating
                  ShimmerLoading(
                    width: 60,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// List item skeleton
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Thumbnail
          ShimmerLoading(
            width: 80,
            height: 120,
            borderRadius: BorderRadius.circular(8),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 20,
                  borderRadius: BorderRadius.circular(8),
                ),
                
                const SizedBox(height: 8),
                
                ShimmerLoading(
                  width: 200,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                
                const SizedBox(height: 8),
                
                ShimmerLoading(
                  width: 150,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                
                const SizedBox(height: 8),
                
                ShimmerLoading(
                  width: 100,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}