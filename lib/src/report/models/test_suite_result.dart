import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

/// Represents a the summarized results from a single test run within a larger
/// test suite.
class TestSuiteResult {
  TestSuiteResult({
    @required this.name,
    @required this.numStepsPassed,
    @required this.numStepsTotal,
    @required this.steps,
    this.suiteName,
    @required this.version,
  })  : assert(name?.isNotEmpty == true),
        assert(version != null),
        assert(numStepsPassed != null),
        assert(numStepsTotal != null),
        assert(numStepsTotal >= numStepsPassed);

  /// The name of the test
  final String name;

  /// The number of steps that passed
  final int numStepsPassed;

  /// The number of steps that passed
  final int numStepsTotal;

  /// The test step details from the report
  final List<TestReportStep> steps;

  /// The test suite name
  final String suiteName;

  /// The version of the test
  final int version;

  /// Returns [true] if, and only if, all steps in the test passed
  bool get success => numStepsPassed == numStepsTotal;

  /// Creates the summarized [TestSuiteResult] from a larger / more detailed
  /// [TestReport].
  static TestSuiteResult fromTestReport(TestReport report) => TestSuiteResult(
        name: report.name ?? '<unknown>',
        numStepsPassed: report.passedSteps,
        numStepsTotal: report.steps.length,
        steps: report.steps,
        suiteName: report.suiteName,
        version: report.version ?? 0,
      );
}
