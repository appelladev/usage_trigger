import 'package:flutter/material.dart';
import 'package:usage_trigger/trigger_when_due.dart';

/// A Flutter widget that wraps a child widget and triggers an async callback
/// when specified usage conditions are met, using the [triggerWhenDue] function.
/// The conditions include an initial delay since first use, a minimum number of
/// events, a frequency for subsequent triggers, and dependencies on other triggers.
///
/// This widget is stateless in its UI, passing through the provided [child] widget,
/// but manages state to initialize the trigger logic in [initState].
class UsageTrigger extends StatefulWidget {
  /// The widget to be displayed as the content of this [UsageTrigger].
  final Widget child;

  /// Unique identifier for this trigger instance (used for preference keys).
  final String id;

  /// Duration to wait after the first event before allowing a trigger.
  final Duration initialDelay;

  /// Minimum number of events (calls to [triggerWhenDue]) required before triggering.
  final int minEvents;

  /// Duration to wait after a successful trigger before allowing the next trigger.
  final Duration frequency;

  /// Async callback invoked when usage conditions are met. Should return `true` on success.
  final Future<bool> Function() onTrigger;

  /// A list of conditions specifying dependencies on other triggers,
  /// defining whether and when those triggers must have succeeded (or not)
  /// to allow this trigger to execute.
  final List<DependencyCondition> dependencyCondition;

  const UsageTrigger({
    super.key,
    required this.child,
    required this.id,
    required this.initialDelay,
    required this.minEvents,
    required this.frequency,
    required this.onTrigger,
    required this.dependencyCondition,
  });

  @override
  State<UsageTrigger> createState() => _UsageTriggerState();
}

/// The state class for [UsageTrigger], responsible for initializing the trigger logic.
class _UsageTriggerState extends State<UsageTrigger> {
  @override
  void initState() {
    super.initState();

    /// Initializes the trigger logic by calling [triggerWhenDue] with the widget's properties.
    triggerWhenDue(
      id: widget.id,
      initialDelay: widget.initialDelay,
      minEvents: widget.minEvents,
      frequency: widget.frequency,
      onTrigger: widget.onTrigger,
      dependencyConditions: widget.dependencyCondition,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Returns the [child] widget, rendering it without modification.
    return widget.child;
  }
}
