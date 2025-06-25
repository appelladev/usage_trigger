import 'dart:async';
import 'package:flutter/material.dart';
import 'package:usage_trigger/usage_trigger.dart';

/// A widget that periodically triggers an action based on usage conditions.
/// The trigger is executed every [checkInterval] until the widget is disposed.
class PeriodicTrigger extends StatefulWidget {
  /// Unique identifier for this trigger instance (used for pref keys).
  final String id;

  /// Duration to wait after first event before triggering.
  final Duration initialDelay;

  /// Minimum number of events (widget builds or manual triggers) before triggering.
  final int minEvents;

  /// Duration to wait after triggering before allowing the next trigger.
  final Duration frequency;

  /// Async callback invoked when conditions are due. Should return true on success.
  final Future<bool> Function() onTrigger;

  /// Interval at which to check if the trigger conditions are met.
  final Duration checkInterval;

  /// Optional child widget to display.
  final Widget? child;

  const PeriodicTrigger({
    super.key,
    required this.id,
    required this.initialDelay,
    required this.minEvents,
    required this.frequency,
    required this.onTrigger,
    this.checkInterval = const Duration(seconds: 10),
    this.child,
  });

  @override
  State<PeriodicTrigger> createState() => _PeriodicTriggerState();
}

class _PeriodicTriggerState extends State<PeriodicTrigger> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start periodic checking
    _startTriggerLoop();
  }

  void _startTriggerLoop() {
    // Call triggerWhenDue immediately and then periodically
    _callTrigger();
    _timer = Timer.periodic(widget.checkInterval, (_) {
      _callTrigger();
    });
  }

  Future<void> _callTrigger() async {
    await triggerWhenDue(
      id: widget.id,
      initialDelay: widget.initialDelay,
      minEvents: widget.minEvents,
      frequency: widget.frequency,
      onTrigger: widget.onTrigger,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
