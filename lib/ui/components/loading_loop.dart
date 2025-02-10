
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show radians;

class LoadingLoop extends StatefulWidget {
  const LoadingLoop(
      {super.key, this.startDelay = const Duration(milliseconds: 0)});

  final Duration startDelay;

  @override
  createState() => _LoadingLoopState();
}

class _LoadingLoopState extends State<LoadingLoop>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> rotation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: Duration(milliseconds: 3000), vsync: this)
          ..addListener(() => controller.repeat());

    rotation = Tween<double>(begin: 0.0, end: 360.0 * 4,)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));
  }

  @override
  Widget build(BuildContext context) {
    controller.value = controller.upperBound;
    Future.delayed(Duration(milliseconds: widget.startDelay.inMilliseconds),
        () {
      if (mounted) {
        controller.forward(from: 0);
      }
    });
    return AnimatedBuilder(
        animation: controller,
        builder: (context, widget) {
          return Transform.rotate(
              angle: radians(rotation.value),
              child: Image.asset("assets/loading_dots.png"));
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
