import 'package:automated_testing_framework/automated_testing_framework.dart';

/// A summary of all the results from all the runs in a single test suite.
class TestSuiteReport {
  final List<TestSuiteResult> _results = [];

  /// Returns all the results from the list.
  List<TestSuiteResult> get results => List.unmodifiable(_results);

  /// Returns the number of tests that passed all steps.
  int get numTestsPassed {
    var passed = 0;
    for (var result in _results) {
      if (result.numStepsPassed == result.numStepsTotal) {
        passed++;
      }
    }

    return passed;
  }

  /// Returns the test device info from the test suite.  This assumes that the
  /// device hasn't changed during the entire run so it will return the first
  /// non-null instance from any of the results.
  TestDeviceInfo get deviceInfo {
    var infos = _results.where((result) => result.deviceInfo != null);
    var info = infos?.isNotEmpty == true ? infos.first.deviceInfo : null;

    return info;
  }

  /// Returns [true] if, and only if, all tests passed.
  bool get success => numTestsPassed == _results.length;

  /// Adds a [TestReport] to the overall summary.
  void addTestReport(TestReport report) =>
      _results.add(TestSuiteResult.fromTestReport(report));
}
