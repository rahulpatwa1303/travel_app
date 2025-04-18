import 'dart:math';
import 'package:flutter/material.dart';

class FloatingHeartLikeButton extends StatefulWidget {
  final bool initialIsLiked;
  final ValueChanged<bool> onLikedChanged;
  final double size;
  final Color likedColor;
  final Color unlikedColor;
  final Duration animationDuration;

  const FloatingHeartLikeButton({
    super.key,
    required this.initialIsLiked,
    required this.onLikedChanged,
    this.size = 30.0, // Default icon size
    this.likedColor = Colors.redAccent, // Default liked color
    this.unlikedColor = Colors.grey, // Default unliked color
    this.animationDuration = const Duration(milliseconds: 800), // Duration for float/fade
  });

  @override
  State<FloatingHeartLikeButton> createState() => _FloatingHeartLikeButtonState();
}

class _FloatingHeartLikeButtonState extends State<FloatingHeartLikeButton>
    with TickerProviderStateMixin { // Use TickerProviderStateMixin for AnimationController

  late bool _isLiked;
  // List to hold controllers for potentially multiple simultaneous animations
  final List<_FloatingHeartController> _floatingHeartControllers = [];

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
  }

  // Ensure state updates if the parent widget changes the initialIsLiked prop
  @override
  void didUpdateWidget(covariant FloatingHeartLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsLiked != oldWidget.initialIsLiked) {
      setState(() {
        _isLiked = widget.initialIsLiked;
      });
    }
  }

  @override
  void dispose() {
    // Dispose all active animation controllers
    for (var controller in _floatingHeartControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap() {
    final bool newLikedState = !_isLiked;
    setState(() {
      _isLiked = newLikedState;
    });

    widget.onLikedChanged(newLikedState); // Notify parent

    if (newLikedState) {
      // Trigger the floating heart animation only when liking
      _addFloatingHeart();
    }
  }

  void _addFloatingHeart() {
    // Create a new controller for this specific heart animation
    final controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this, // Use the TickerProviderStateMixin
    );

    final floatingHeartController = _FloatingHeartController(controller);
    _floatingHeartControllers.add(floatingHeartController);

    // Listener to remove the controller when the animation completes
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Important: Use post frame callback to avoid modifying list during build/layout phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) { // Check if widget is still mounted
             setState(() {
               // Find and remove the specific controller instance
               final index = _floatingHeartControllers.indexOf(floatingHeartController);
               if (index != -1) {
                  _floatingHeartControllers.removeAt(index);
               }
             });
             floatingHeartController.dispose(); // Dispose the controller itself
           } else {
             // If not mounted, still try to dispose
              floatingHeartController.dispose();
           }
        });
      }
    });

    controller.forward(); // Start the animation
    setState(() {}); // Trigger rebuild to include the new floating heart
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow hearts to float outside the bounds
      alignment: Alignment.center,
      children: [
        // The base IconButton
        IconButton(
          iconSize: widget.size,
          splashRadius: widget.size, // Make splash radius fit icon
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? widget.likedColor : widget.unlikedColor,
          ),
          onPressed: _handleTap,
        ),

        // Render all active floating hearts
        // Use Positioned.fill to make the hearts originate from the center
        Positioned.fill(
          child: IgnorePointer( // Prevent stack items from intercepting taps
            child: Stack(
                alignment: Alignment.center,
                children: _floatingHeartControllers.map((controller) {
                return _FloatingHeart(
                    key: controller.key, // Use unique key
                    controller: controller.animationController,
                    color: widget.likedColor,
                    baseSize: widget.size);
                }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// Helper class to hold controller and a unique key
class _FloatingHeartController {
  final Key key = UniqueKey();
  final AnimationController animationController;

  _FloatingHeartController(this.animationController);

  void dispose() {
    animationController.dispose();
  }
}


// --- Widget responsible for rendering a single floating heart ---
class _FloatingHeart extends StatefulWidget {
  final AnimationController controller;
  final Color color;
  final double baseSize;

  const _FloatingHeart({
    super.key, // Key is passed from the controller holder
    required this.controller,
    required this.color,
    required this.baseSize,
  });

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart> {
  late Animation<double> _opacityAnimation;
  late Animation<double> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late double _randomHorizontalDrift;

  @override
  void initState() {
    super.initState();

    // Random horizontal drift for variety (-1.0 to 1.0 range roughly)
    _randomHorizontalDrift = (Random().nextDouble() * 2.0 - 1.0) * 0.5;

    // Opacity: Fade out completely in the last 60% of the animation
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn), // Start fading later
      ),
    );

    // Vertical Offset: Move upwards significantly
    _offsetAnimation = Tween<double>(begin: 0.0, end: -widget.baseSize * 3.0).animate( // Float up ~3x icon height
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeOut,
      ),
    );

     // Scale: Slightly increase then decrease (optional pop effect)
    // Scale: Slightly increase then decrease (pop effect defined by sequence)
    _scaleAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.2), weight: 30), // Grow
        TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 70), // Shrink back slightly
    ]).animate(CurvedAnimation(
        parent: widget.controller,
        // Use a curve that stays within [0.0, 1.0]
        curve: Curves.easeOut, // <--- FIXED CURVE (easeOut is often good for things leaving)
        // curve: Curves.easeInOut, // Another option
      )
    );

  }

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder for efficient animation updates
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return Transform.translate(
            // Apply vertical offset and slight random horizontal drift
            offset: Offset(
                _offsetAnimation.value * _randomHorizontalDrift, // Apply horizontal drift based on vertical progress
                _offsetAnimation.value, // Apply vertical animation
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child, // The heart icon defined below
              ),
            ),
          );
        },
        child: Icon(
          Icons.favorite,
          color: widget.color,
          size: widget.baseSize * _scaleAnimation.value, // Apply scale animation also to base size
        ),
      ),
    );
  }
}