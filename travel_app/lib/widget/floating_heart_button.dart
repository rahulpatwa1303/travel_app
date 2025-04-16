import 'dart:math';
import 'package:flutter/material.dart';

class FloatingHearts extends StatefulWidget {
  final bool isLiked; // Accept isLiked as a parameter
  final ValueChanged<bool> onLikedChanged; // Callback to notify the parent

  const FloatingHearts({
    super.key,
    required this.isLiked,
    required this.onLikedChanged, // Callback to update parent state
  });

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts> {
  final List<Widget> _hearts = [];

  void _addHeart() {
    final random = Random();

    final size = 24.0 + random.nextDouble() * 16; // size: 24 - 40
    final horizontalOffset = -30 + random.nextDouble() * 60; // left/right random

    final key = UniqueKey();

    final heart = Positioned(
      bottom: 40,
      left: MediaQuery.of(context).size.width / 2 + horizontalOffset,
      child: HeartAnimation(
        key: key,
        size: size,
        onComplete: () {
          setState(() {
            _hearts.removeWhere((element) => element.key == key);
          });
        },
      ),
    );

    setState(() {
      _hearts.add(heart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ..._hearts,
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: IconButton(
              icon: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 32,
              ),
              onPressed: () {
                // Toggle the like state and notify the parent
                widget.onLikedChanged(!widget.isLiked);
                if (!widget.isLiked) {
                  _addHeart(); // Only trigger the heart animation when liked
                }
              },
              color: widget.isLiked ? Colors.pinkAccent : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class HeartAnimation extends StatefulWidget {
  final double size;
  final VoidCallback onComplete;

  const HeartAnimation({
    super.key,
    required this.size,
    required this.onComplete,
  });

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _moveUp;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _moveUp = Tween<double>(begin: 0, end: -150).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().whenComplete(() => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _moveUp.value),
          child: Opacity(
            opacity: _fadeOut.value,
            child: Icon(
              Icons.favorite,
              size: widget.size,
              color: Colors.pinkAccent,
            ),
          ),
        );
      },
    );
  }
}
