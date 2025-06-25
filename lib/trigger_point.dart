import 'package:flutter/material.dart';
import 'package:usage_trigger/usage_trigger.dart';

class TriggerPoint extends StatefulWidget {
  final Widget child;
  final String id;
  final Duration initialDelay;
  final int minEvents;
  final Duration frequency;
  final Future<bool> Function() onTrigger;

  const TriggerPoint({
    super.key,
    required this.child,
    required this.id,
    required this.initialDelay,
    required this.minEvents,
    required this.frequency,
    required this.onTrigger,
  });

  @override
  State<TriggerPoint> createState() => _TriggerPointState();
}

class _TriggerPointState extends State<TriggerPoint> {
  @override
  void initState() {
    super.initState();
    triggerWhenDue(
      id: widget.id,
      initialDelay: widget.initialDelay,
      minEvents: widget.minEvents,
      frequency: widget.frequency,
      onTrigger: widget.onTrigger,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
