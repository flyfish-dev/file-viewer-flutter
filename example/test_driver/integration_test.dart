import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  timeout: const Duration(minutes: 4),
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    await writeResponseData(data);
    // A timed-out live test can reach teardown without a recorded failure in
    // Flutter's integration result channel. Require the end-of-test receipt;
    // an empty or partial response must never make this driver exit successfully.
    if (data?['completed'] != true) {
      throw StateError(
        'The native integration test did not complete all checks.',
      );
    }
  },
);
