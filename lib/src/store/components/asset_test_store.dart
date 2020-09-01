import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Test store that can be used to read tests from asset files.  Each asset file
/// may contain one or more tests.
///
/// In order to use the [AssetTestStore] to read from assets, you must first
/// update the static [testAssets] list with the full asset name / path to
/// retrieve the asset data from.
///
/// The [AssetTestStore] only supports the read operation and not the write or
/// report operation.
class AssetTestStore {
  static final Logger _logger = Logger('AssetTestStore');

  /// Set this to the list of asset files to use when loading the tests before
  /// calling [testReader].
  static List<String> testAssets;

  /// Reads and returns zero or more tests from the assets defined by
  /// [testAssets].  This ignores the [context] that is passed in.  This will
  /// never throw an error or return [null] and will instead return an empty
  /// array if it encounters issues loading the tests.
  static Future<List<PendingTest>> testReader(BuildContext context) async {
    var tests = <PendingTest>[];

    if (testAssets?.isNotEmpty == true) {
      for (var asset in testAssets) {
        try {
          var text = await rootBundle.loadString(asset);
          if (text?.isNotEmpty == true) {
            var parsed = json.decode(text);

            tests.addAll(TestStore.createMemoryTests(parsed));
          }
        } catch (e, stack) {
          _logger.severe('Error in AssetTestStore.testReader', e, stack);
        }
      }
    }

    return tests ?? <PendingTest>[];
  }
}
