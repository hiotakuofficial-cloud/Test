import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_animations.dart';

class PremiumBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const PremiumBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  State<PremiumBottomNavigationBar> createState() => _PremiumBottomNavigationBarState();
}

class _PremiumBottomNavigationBarState extends State<PremiumBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.springCurve,
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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.surfaceDark,
            AppColors.surfaceElevated,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.borderSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.elevatedShadowColor,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.items.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isActive = widget.currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap(index);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? _scaleAnimation.value : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          AppColors.primaryPurple.withOpacity(0.2),
                          AppColors.secondaryBlue.withOpacity(0.2),
                        ],
                      )
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient effect
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.items[index].icon.icon,
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else
                    Icon(
                      widget.items[index].icon.icon,
                      size: 24,
                      color: AppColors.textSecondary,
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Label
                  Text(
                    widget.items[index].label ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppColors.primaryPurple
                          : AppColors.textSecondary,
                    ),
                  ),
                  
                  // Active indicator
                  if (isActive)
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    )
                  else
                    const SizedBox(
                      height: 4,
                      width: 4,
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

// Custom bottom navigation bar item
class PremiumBottomNavigationBarItem extends BottomNavigationBarItem {
  final Color? activeColor;
  final Color? inactiveColor;

  const PremiumBottomNavigationBarItem({
    required Icon icon,
    String? label,
    Widget? activeIcon,
    this.activeColor,
    this.inactiveColor,
  }) : super(
          icon: icon,
          label: label,
          activeIcon: activeIcon ?? icon,
        );
}