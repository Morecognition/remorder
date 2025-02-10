
import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  const RecordButton(
      {super.key,
      this.recording = false,
      this.duration = 3000,
      this.circleCount = 3,
      this.color = const Color(0xFFF9534F),
      this.onRecordPressed,
      this.onStopPressed});

  final bool recording;
  final int circleCount;
  final int duration;
  final Color color;
  final VoidCallback? onRecordPressed;
  final VoidCallback? onStopPressed;

  @override
  Widget build(BuildContext context) {
    if (recording) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ExpandingCircle(startDelay: Duration(milliseconds: 0)),
          ExpandingCircle(startDelay: Duration(milliseconds: 2000)),
          ExpandingCircle(startDelay: Duration(milliseconds: 4000)),
          IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onStopPressed,
              icon: Image.asset("assets/stop_button_noborder.png"))
        ],
      );
    } else {
      return Stack(alignment: Alignment.center, children: [
        Transform.translate(
          offset: Offset(0, -28),
          child: Text("Tap to record",
              style: TextStyle(
                  color: Color(0xFF2B3A51), fontSize: 15.adaptedFontSize)),
        ),
        IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: onRecordPressed,
            icon: Image.asset("assets/record_button.png"))
      ]);
    }
  }
}

class ExpandingCircle extends StatefulWidget {
  const ExpandingCircle(
      {super.key,
      this.startDelay = const Duration(milliseconds: 0),
      this.duration = const Duration(seconds: 6),
      this.color = const Color(0xFFF9534F)});

  final Duration startDelay;
  final Duration duration;
  final Color color;

  @override
  createState() => _ExpandingCircleState();
}

class _ExpandingCircleState extends State<ExpandingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this)
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
    return RecordingCircle(controller: controller, color: widget.color);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class RecordingCircle extends StatelessWidget {
  RecordingCircle({super.key, required this.controller, required this.color})
      : scale = Tween<double>(
          begin: 1,
          end: 2,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        ),
        opacity = Tween<double>(
          begin: 1,
          end: 0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );

  final Color color;
  final AnimationController controller;
  final Animation<double> opacity;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, widget) {
          return Transform.scale(
            scale: scale.value,
            child: _buildCircle(color: color),
          );
        });
  }

  _buildCircle({required Color color}) {
    return Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
                color: Color.from(
                    red: color.r,
                    green: color.g,
                    blue: color.b,
                    alpha: opacity.value))));
  }
}
