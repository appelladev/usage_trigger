# usage_trigger

A Flutter package that enables triggering asynchronous actions based on usage conditions,
such as initial delay, minimum event count, and frequency.
It provides the UsageTrigger widget for seamless integration into Flutter
UIs and the triggerWhenDue function for flexible trigger logic.

## Getting started

Requirements

    Flutter SDK: >= 3.0.0
    Dart: >= 2.17.0
    Dependencies: shared_preferences, synchronized

API Overview

    UsageTrigger: A StatefulWidget that renders a child widget and calls triggerWhenDue on initialization.
    triggerWhenDue: Triggers asynchronous actions based on usage conditions (initial delay, minimum events, frequency).

## Usage

Using the triggerWhenDue function

```dart
import 'package:usage_trigger/trigger_when_due.dart';

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

Using the UsageTrigger

```dart
import 'package:flutter/material.dart';
import 'package:usage_trigger/trigger_when_due.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TriggerPoint(
          id: 'example_trigger',
          initialDelay: Duration(seconds: 5),
          minEvents: 3,
          frequency: Duration(minutes: 2),
          onTrigger: () async {
            print('Action triggered!');
            return true;
          },
          child: Center(child: Text('Hello, World!')),
        ),
      ),
    );
  }
}
```

## License

MIT License. See LICENSE for details.

## Contributing

Contributions are welcome! Please open an issue or pull request on GitHub.

## Contact

For questions or issues, open an issue on GitHub.
