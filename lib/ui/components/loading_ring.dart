import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show radians;

class LoadingRing extends StatefulWidget {
  const LoadingRing(
      {super.key, this.startDelay = const Duration(milliseconds: 0)});

  final Duration startDelay;

  @override
  createState() => _LoadingRingState();
}

class _LoadingRingState extends State<LoadingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 3000), vsync: this)
          ..addListener(() => controller.repeat());
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
    return RadialAnimation(controller: controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class RadialAnimation extends StatelessWidget {
  RadialAnimation({super.key, required this.controller})
      : translation = Tween<double>(
          begin: 70.0,
          end: 100.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        ),
        opacity = Tween<double>(
          begin: 1,
          end: 0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );

  final AnimationController controller;
  final Animation<double> opacity;
  final Animation<double> translation;
  static const int ringCount = 30;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, widget) {
          return Transform.rotate(
              angle: radians(0),
              child: Stack(alignment: Alignment.center, children: <Widget>[
                for (var i = 0; i < ringCount; i++)
                  _buildDot(360.0 / ringCount * i,
                      color: Theme.of(context).primaryColor),
              ]));
        });
  }

  _buildDot(double angle, {required Color color}) {
    final double rad = radians(angle);
    return Transform(
        transform: Matrix4.identity()
          ..translate(
              (translation.value) * cos(rad), (translation.value) * sin(rad)),
        child: Container(
            width: 10.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: Color.from(
                  red: color.r,
                  green: color.g,
                  blue: color.b,
                  alpha: opacity.value),
              shape: BoxShape.circle,
            )));
  }
}
