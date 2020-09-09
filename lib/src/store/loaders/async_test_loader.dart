import 'package:automated_testing_framework/automated_testing_framework.dart';

/// Loader that loads the test from an async callback.
class AsyncTestLoader extends TestLoader {
  /// Constructs the loader with the callback to use.
  AsyncTestLoader(
    this.callback,
  ) : assert(callback != null);

  /// The callback to execute to get the test.
  final Future<Test> Function() callback;

  /// Returns the in test by executing the callback;
  @override
  Future<Test> load({bool ignoreImages = false}) => callback();
}
