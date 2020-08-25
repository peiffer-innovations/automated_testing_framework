import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

/// Loader that loads the test from an in-memory object.
class MemoryTestLoader extends TestLoader {
  /// Constructs the loader with the test to use.
  MemoryTestLoader({
    @required this.test,
  });

  /// The in-memory test
  final Test test;

  /// Returns the in memory test immediately.
  @override
  Future<Test> load({bool ignoreImages = false}) async => test;
}
