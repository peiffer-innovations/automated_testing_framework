import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

/// Describes a pending test.  The pending test should describe the name, number
/// of steps, version, and provide a loader to load the full test details.
@immutable
class PendingTest {
  /// Constructs the pending test.
  PendingTest({
    this.active = true,
    @required this.loader,
    @required this.name,
    @required this.numSteps,
    @required this.suiteName,
    @required this.version,
  })  : assert(active != null),
        assert(loader != null),
        assert(name?.isNotEmpty == true),
        assert(numSteps != null),
        assert(numSteps >= 0),
        assert(version != null),
        assert(version >= 0);

  /// Constructs the pending test from an already loaded in-memory test.  This
  /// is really just a metadata wrapper for the passed in test.
  factory PendingTest.memory(Test test) => PendingTest(
        active: test.active,
        loader: MemoryTestLoader(test: test),
        name: test.name,
        numSteps: test.steps.length,
        suiteName: test.suiteName,
        version: test.version,
      );

  /// Flag that states whether the test is active by default or not.
  final bool active;

  /// Loader that can load the full test details.
  final TestLoader loader;

  /// Name of the test to be loaded.
  final String name;

  /// Number of steps in the test that can be loaded.
  final int numSteps;

  /// Name of the test suite the test is a part of.
  final String suiteName;

  /// Version of the test to be loaded.
  final int version;

  /// Returns the id of the test which is a concatenation of the suite
  /// name and the test name.
  String get id =>
      (suiteName?.isNotEmpty == true ? '${suiteName}__' : '') + name;
}
