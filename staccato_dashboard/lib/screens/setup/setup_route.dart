/// Library for the [SetupRoute] with components and models used in the screen.
library;

import 'package:flutter/material.dart';

import '../../components/loaders/wave_loader.dart';

// Parts
part 'setup_controller.dart';
part 'setup_view.dart';

/// Performs the setup necessary to proceed to the next route.
class SetupRoute extends StatefulWidget {
  /// Creates an instance of [SetupRoute].
  const SetupRoute({super.key});

  @override
  State<SetupRoute> createState() => SetupController();
}
