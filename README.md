# usage_trigger

A Flutter package that triggers actions based on usage patterns with configurable delays and event counts.

## Parameters

- id: Unique identifier for this trigger instance

- initialDelay: Duration to wait after first event before triggering

- minEvents: Minimum number of events before triggering

- frequency: Minimum duration between successful triggers

- onTrigger: Async callback that returns true on success
-
## Features

- Trigger async callbacks based on usage conditions

- Configurable initial delay before first trigger

- Minimum event count requirement

- Frequency control between triggers

- Thread-safe using synchronized locks

- Persists state using shared_preferences

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage
Using the triggerWhenDue function
```dart
import 'package:usage_trigger/usage_trigger.dart';

void example() async {
  await triggerWhenDue(
    id: 'my_feature',
    initialDelay: Duration(days: 1),
    minEvents: 5,
    frequency: Duration(hours: 24),
    onTrigger: () async {
      // Your action here
      print('Trigger activated!');
      return true; // Return true on success
    },
  );
}
```
Using the TriggerPoint
```dart
import 'package:flutter/material.dart';
import 'package:usage_trigger/usage_trigger.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TriggerPoint(
            id: 'text_trigger',
            initialDelay: const Duration(seconds: 5),
            minEvents: 3,
            frequency: const Duration(hours: 1),
            onTrigger: () async {
              print('Triggered!');
              return true;
            },
            child: const Text('Child'),
          ),
        ),
      ),
    );
  }
}
```

## Additional information

- The package uses shared_preferences to persist trigger state

- Thread-safe implementation using synchronized

- Failed triggers will retry on the next call when conditions are met

- Each trigger instance is independent based on the provided ID
