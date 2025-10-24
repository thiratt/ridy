import 'package:flutter/material.dart';

class CurrentLocationDot extends StatefulWidget {
  const CurrentLocationDot({
    super.key,
    this.size = 20,
    this.color = const Color(0xFF2F80ED),
  });

  final double size;
  final Color color;

  @override
  State<CurrentLocationDot> createState() => _CurrentLocationDotState();
}

class _CurrentLocationDotState extends State<CurrentLocationDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1 + _controller.value;
              final opacity = (1 - _controller.value).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.6 * opacity),
                  ),
                ),
              );
            },
          ),

          Container(
            width: widget.size * 1.4,
            height: widget.size * 1.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: widget.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),

          Container(
            width: widget.size * 0.7,
            height: widget.size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
