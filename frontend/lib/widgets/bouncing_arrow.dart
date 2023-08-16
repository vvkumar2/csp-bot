import 'package:flutter/material.dart';

class BouncingArrow extends StatefulWidget {
  const BouncingArrow({super.key});

  @override
  State<BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<BouncingArrow> {
  late AnimationController _arrowAnimationController;

  @override
  Widget build(BuildContext context) {
    final Animation<double> arrowAnimation =
        Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    return AnimatedBuilder(
      animation: arrowAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(arrowAnimation.value, 0),
          child: child,
        );
      },
      child: const Icon(Icons.arrow_forward),
    );
  }
}
