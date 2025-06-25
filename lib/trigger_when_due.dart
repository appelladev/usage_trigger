import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

// Map to hold locks per trigger ID to avoid race conditions
final Map<String, Lock> _triggerLocks = {};

/// Triggers the provided async callback when usage conditions are due to be met:
/// - initialDelay: wait at least this duration since first use/event
/// - minEvents: require this many calls to this function
/// - frequency: wait this duration after last successful trigger
/// The callback is invoked but its result is not returned; on success the last trigger timestamp is updated,
/// on failure it will retry on next check.
Future<void> triggerWhenDue({
  /// Unique identifier for this trigger instance (used for pref keys).
  required String id,

  /// Duration to wait after first event before triggering.
  required Duration initialDelay,

  /// Minimum number of events (function calls) before triggering.
  required int minEvents,

  /// Duration to wait after triggering before allowing the next trigger.
  required Duration frequency,

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

    // 5) Conditions met: attempt trigger
    bool success = false;
    try {
      success = await onTrigger();
    } catch (_) {
      success = false;
    }

    // 6) Persist last trigger time only on success
    if (success) {
      await prefs.setInt(keyLastTime, now.millisecondsSinceEpoch);
    }
  });
}
