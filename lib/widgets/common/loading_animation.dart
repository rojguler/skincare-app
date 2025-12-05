import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PulseLoading extends StatefulWidget {
  final double size;
  final Color? color;

  const PulseLoading({super.key, this.size = 40, this.color});

  @override
  State<PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<PulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animation.value * 0.4),
          child: Opacity(
            opacity: 0.3 + (_animation.value * 0.7),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? AppColors.pink,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpinLoading extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const SpinLoading({
    super.key,
    this.size = 32,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  State<SpinLoading> createState() => _SpinLoadingState();
}

class _SpinLoadingState extends State<SpinLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: widget.strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.color ?? AppColors.pink,
          ),
        ),
      ),
    );
  }
}

class FadeLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<FadeLoading> createState() => _FadeLoadingState();
}

class _FadeLoadingState extends State<FadeLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
