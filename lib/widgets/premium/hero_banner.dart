import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_animations.dart';

class HeroBanner extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onPlay;
  final VoidCallback? onMoreInfo;

  const HeroBanner({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onPlay,
    this.onMoreInfo,
  }) : super(key: key);

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.verySlow,
      vsync: this,
    );
    
    _scaleAnimation = AppAnimations.heroScaleAnimation(_controller);
    _fadeAnimation = AppAnimations.heroFadeAnimation(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image with parallax effect
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              gradient: AppColors.heroGradient,
            ),
          ),
        ),
        
        // Content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: AppAnimations.verySlow,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  // Featured badge
                  _buildFeaturedBadge(),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassmorphicButton(
                          label: 'Play',
                          icon: Icons.play_arrow,
                          onTap: widget.onPlay,
                          isPrimary: true,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: _buildGlassmorphicButton(
                          label: 'More Info',
                          icon: Icons.info_outline,
                          onTap: widget.onMoreInfo,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentPink, Color(0xFFFF6B9D)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: AppColors.textPrimary,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            'Featured',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.elevatedShadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPrimary)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                    )
                  else
                    Icon(
                      icon,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  
                  const SizedBox(width: 8),
                  
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}