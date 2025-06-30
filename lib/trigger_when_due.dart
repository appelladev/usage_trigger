import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

// Map to hold locks per trigger ID to avoid race conditions
final Map<String, Lock> _triggerLocks = {};

/// Represents a condition that depends on another trigger's execution state.
/// Used to enforce dependencies between triggers, ensuring that a trigger only
/// executes if the dependent trigger has either succeeded or not succeeded within
/// a specified cooldown period.
class DependencyCondition {
  /// The unique identifier of the trigger this condition depends on.
  final String dependentTriggerId;

  /// The duration that must have passed since the dependent trigger's last
  /// successful execution for this condition to be met.
  final Duration cooldownPeriod;

  /// If true, the dependent trigger must have succeeded at least once and the
  /// cooldown period must have elapsed. If false, the dependent trigger must not
  /// have succeeded recently (or never) within the cooldown period.
  final bool mustHaveSucceeded;

  DependencyCondition({
    required this.dependentTriggerId,
    required this.cooldownPeriod,
    required this.mustHaveSucceeded,
  });
}

/// Triggers the provided async callback when usage conditions are due to be met:
/// - initialDelay: wait at least this duration since first use/event
/// - minEvents: require this many calls to this function
/// - frequency: wait this duration after last successful trigger
/// - dependencyConditions: require other triggers to have (or not have) run
Future<void> triggerWhenDue({
  /// Unique identifier for this trigger instance (used for pref keys).
  required String id,

  /// Duration to wait after first event before triggering.
  required Duration initialDelay,

  /// Minimum number of events (function calls) before triggering.
  required int minEvents,

  /// Duration to wait after triggering before allowing the next trigger.
  required Duration frequency,

  /// A list of conditions specifying dependencies on other triggers,
  /// defining whether and when those triggers must have succeeded (or not)
  /// to allow this trigger to execute.
  required List<DependencyCondition> dependencyConditions,

  /// Async callback invoked when conditions are due. Should return true on success.
  required Future<bool> Function() onTrigger,
}) async {
  // Acquire or create a lock for this ID
  final lock = _triggerLocks.putIfAbsent(id, () => Lock());

  await lock.synchronized(() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final keyFirst = 'usage_trigger_${id}_first_event';
    final keyCount = 'usage_trigger_${id}_event_count';
    final keyLastTime = 'usage_trigger_${id}_last_trigger';

    // 1) Store first event timestamp if not present
    if (!prefs.containsKey(keyFirst)) {
      await prefs.setInt(keyFirst, now.millisecondsSinceEpoch);
    }

    // 2) Increment event count
    final newCount = (prefs.getInt(keyCount) ?? 0) + 1;
    await prefs.setInt(keyCount, newCount);

    // 3) Check initial delay and minimum events
    final firstEvent = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(keyFirst)!,
    );
    if (now.difference(firstEvent) < initialDelay) return;
    if (newCount < minEvents) return;

    // 4) Check frequency since last trigger
    if (prefs.containsKey(keyLastTime)) {
      final last = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt(keyLastTime)!,
      );
      if (now.difference(last) < frequency) return;
    }

    // 5) Enforce dependency conditions
    for (final cond in dependencyConditions) {
      final depKey = 'usage_trigger_${cond.dependentTriggerId}_last_trigger';

      if (cond.mustHaveSucceeded) {
        // dependent trigger must have succeeded at least once
        if (!prefs.containsKey(depKey)) return;
        final depLast = DateTime.fromMillisecondsSinceEpoch(
          prefs.getInt(depKey)!,
        );
        // and it must be at least cooldownPeriod ago
        if (now.difference(depLast) < cond.cooldownPeriod) return;
      } else {
        // dependent trigger must NOT have succeeded recently (or never)
        if (prefs.containsKey(depKey)) {
          final depLast = DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt(depKey)!,
          );
          // if it did succeed, ensure it was cooldownPeriod ago
          if (now.difference(depLast) < cond.cooldownPeriod) return;
        }
      }
    }

    // 6) Conditions met: attempt trigger
    bool success = false;
    try {
      success = await onTrigger();
    } catch (_) {
      success = false;
    }

    // 7) Persist last trigger time only on success
    if (success) {
      await prefs.setInt(keyLastTime, now.millisecondsSinceEpoch);
    }
  });
}
