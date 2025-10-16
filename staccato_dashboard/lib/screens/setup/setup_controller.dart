part of 'setup_route.dart';

/// Controller for the [SetupRoute].
class SetupController extends State<SetupRoute> {
  @override
  void initState() {
    // Start the app setup process.
    _performSetup();

    super.initState();
  }

  /// Performs initialization of resources for the app.
  Future<void> _performSetup() async {
    // TODO(Toglefritz): Perform real app setup process. For now, add a delay to simulate the setup.
    await Future<void>.delayed(const Duration(seconds: 2));

    // Once setup is complete, navigate to the idle route.
    await _onSetupComplete();
  }

  /// Callback for when the app setup is complete.
  ///
  /// Once this controller finishes initializing the app, this method is called to start the main application user
  /// flow by navigating to the [IdleRoute].
  Future<void> _onSetupComplete() async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const IdleRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SetupView(this);
}
