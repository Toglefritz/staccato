import 'dart:io';

/// The IP address of the development machine running the Firebase emulator suite. This IP is used in debug builds to
/// run Firebase services locally, rather than in the cloud.
// Use "localhost" if running the emulator suite on the same machine as the app and without any external devices (such
// as a Brine device). Otherwise, and this will be the case in most situations, use the IP address of the machine
// running the emulator suite. The emulator suite can be started with the command `firebase emulators:start`.
final String devMachineIP = Platform.isMacOS ? 'localhost' : '192.168.86.39';
