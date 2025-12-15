import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[300]!,
              Colors.grey[200]!,
              Colors.grey[300]!,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

class SkeletonCarousel extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double itemWidth;

  const SkeletonCarousel({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 200,
    this.itemWidth = 130,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: itemHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            margin: EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: itemHeight * 0.7,
                  width: itemWidth,
                  borderRadius: BorderRadius.circular(8),
                ),
                SizedBox(height: 8),
                SkeletonLoader(height: 12, width: itemWidth * 0.8),
                SizedBox(height: 4),
                SkeletonLoader(height: 10, width: itemWidth * 0.6),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SkeletonHeroBanner extends StatelessWidget {
  final double height;

  const SkeletonHeroBanner({
    Key? key,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          SkeletonLoader(
            height: height,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 20, width: 60),
                SizedBox(height: 12),
                SkeletonLoader(height: 18, width: double.infinity),
                SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 120),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonLoader(height: 10, width: 50),
                    SizedBox(width: 12),
                    SkeletonLoader(height: 10, width: 60),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}