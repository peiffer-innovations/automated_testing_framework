import 'package:automated_testing_framework/automated_testing_framework.dart';

/// Writer to save the given test report as golden images for the test.
typedef GoldenImageWriter = Future<void> Function(TestReport report);
