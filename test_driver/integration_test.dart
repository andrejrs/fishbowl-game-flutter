import 'package:integration_test/integration_test_driver.dart';

/// Driver entrypoint for `flutter drive`, which launches the real app
/// visibly on-device and drives it via the VM service - unlike
/// `flutter test integration_test/...`, which runs the app off-screen.
Future<void> main() => integrationDriver();
