import 'package:flutter/material.dart';
import 'idle_controller.dart';

/// Route widget for the idle screen.
///
/// Following MVC patterns, this route serves only as the entry point and delegates all logic to the [IdleController]
/// through `createState()`.
class IdleRoute extends StatefulWidget {
  /// Creates the idle route widget.
  const IdleRoute({super.key});

  @override
  State<IdleRoute> createState() => IdleController();
}
