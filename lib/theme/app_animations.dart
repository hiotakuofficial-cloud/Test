import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppAnimations {
  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Custom curves for premium feel
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve elasticInOut = Curves.elasticInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve easeOutBack = Curves.easeOutBack;
  
  // Custom spring curve for more realistic physics
  static final Curve springCurve = CustomSpringCurve();
  
  // Screen transition animations
  static Route<T> slideUpRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeOutCubic,
        ));
        
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: normal,
    );
  }
  
  static Route<T> slideRightRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeOutCubic,
        ));
        
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: normal,
    );
  }
  
  static Route<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: fast,
    );
  }
  
  // Card animations
  static Animation<double> cardScaleAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: springCurve,
    ));
  }
  
  static Animation<Offset> cardSlideAnimation(Animation<double> parent, {double distance = 50}) {
    return Tween<Offset>(
      begin: Offset(0, distance / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: easeOutCubic,
    ));
  }
  
  // Hero animations
  static Animation<double> heroScaleAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 1.1,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: easeOutCubic,
    ));
  }
  
  static Animation<double> heroFadeAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: easeOutCubic,
    ));
  }
  
  // Floating action button animations
  static Animation<double> fabScaleAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: springCurve,
    ));
  }
  
  // Loading animations
  static Animation<double> rotateAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: Curves.linear,
    ));
  }
  
  // Ripple animation for buttons
  static Animation<double> rippleAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: easeOutCubic,
    ));
  }
  
  // Parallax animation
  static Animation<double> parallaxAnimation(ScrollController controller, double extent) {
    return Tween<double>(
      begin: 0.0,
      end: -extent,
    ).animate(
      CurvedAnimation(
        parent: controller.animation!,
        curve: Curves.linear,
      ),
    );
  }
  
  // Shimmer animation
  static Animation<double> shimmerAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: Curves.easeInOutSine,
    ));
  }
  
  // Badge pulse animation
  static Animation<double> badgePulseAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: springCurve,
    ));
  }
  
  // Gradient shift animation
  static Animation<double> gradientShiftAnimation(Animation<double> parent) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: Curves.easeInOutSine,
    ));
  }
}

// Custom spring curve for realistic physics
class CustomSpringCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.5) {
      double x = 2 * t;
      return 0.5 * x * x * x * x * x + 0.5;
    } else {
      double x = 2 * (t - 1);
      return 0.5 * (x * x * x * x * x + 2);
    }
  }
}

// Scroll physics with elastic bouncing
class ElasticScrollPhysics extends ScrollPhysics {
  const ElasticScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  ElasticScrollPhysics applyTo(ScrollPhysics ancestor) {
    return ElasticScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.5,
        stiffness: 100.0,
        damping: 8.0,
      );

  @override
  double adjustPositionForNewBounds(
    ScrollPosition oldPosition,
    ScrollPosition newPosition,
    bool isNewScroll,
  ) {
    return super.adjustPositionForNewBounds(
      oldPosition,
      newPosition,
      isNewScroll,
    );
  }
}

// Staggered animation builders
class StaggeredAnimations {
  // Card entrance animation with stagger
  static List<Widget> staggeredCardAnimation(List<Widget> children) {
    return children
        .map((child) => AnimatedBuilder(
              animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: const AlwaysStoppedAnimation<double>(0.0),
                  curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
                ),
              ),
              builder: (context, animation) {
                return Transform.translate(
                  offset: Offset(0, (1 - animation.value) * 30),
                  child: Opacity(
                    opacity: animation.value,
                    child: Transform.scale(
                      scale: 0.95 + (animation.value * 0.05),
                      child: child,
                    ),
                  ),
                );
              },
            ))
        .toList();
  }

  // Section header animation
  static Animation<Offset> sectionHeaderAnimation(Animation<double> animation) {
    return Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));
  }
}