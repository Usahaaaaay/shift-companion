// main.dart
//
// The application's entry point. Per docs/ARCHITECTURE.md, this file
// contains no logic beyond bootstrapping: it wraps the app in a
// ProviderScope (so every Riverpod provider used anywhere in the app has
// somewhere to live) and hands off to ShiftCompanionApp for everything else.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// Bootstraps and runs Shift Companion.
void main() {
  runApp(
    // ProviderScope must wrap the entire app so that any widget, on any
    // screen, can read any Riverpod provider — this is what makes Riverpod's
    // dependency injection work without passing objects down the widget
    // tree by hand (see decisions/0001-state-management-and-navigation.md).
    const ProviderScope(child: ShiftCompanionApp()),
  );
}
