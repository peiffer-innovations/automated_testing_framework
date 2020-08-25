import 'package:automated_testing_framework/automated_testing_framework.dart';

/// Interface for loading tests
abstract class TestLoader {
  /// Loads an individual test on-demand.
  ///
  /// Set [ignoreImages] to [true] to request the loader to ignore the images
  /// from the test to save bandwidth and / or memory.
  ///
  /// The [ignoreImages] parameter should be thought of as a suggestion to the
  /// loader.  A loader may choose to always, or never, return include the
  /// images with the returned test or it may respect the set value.
  Future<Test> load({bool ignoreImages = false});
}
