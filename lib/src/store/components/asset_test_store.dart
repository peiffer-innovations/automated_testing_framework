import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Test store that can be used to read tests from asset files.  Each asset file
/// may contain one or more tests.
///
/// In order to use the [AssetTestStore] to read from assets, you must set
/// either the static [testAssetIndex] or the [testAssets] list (but not both)
/// with the full asset name / path to retrieve the asset data from.
///
/// The [AssetTestStore] only supports the read operation and not the write or
/// report operation.
class AssetTestStore {
  AssetTestStore({
    this.testAssetIndex,
    this.testAssets,
  })  : assert(testAssetIndex?.isNotEmpty == true ||
            testAssets?.isNotEmpty == true),
        assert(testAssetIndex?.isNotEmpty != true ||
            testAssets?.isNotEmpty != true);

  static final Logger _logger = Logger('AssetTestStore');

  /// Set this to the path of an asset file containing an array with the list of
  /// other JSON files to load.
  String? testAssetIndex;

  /// Set this to the list of asset files to use when loading the tests before
  /// calling [testReader].
  List<String>? testAssets;

  /// Reads and returns zero or more tests from the assets defined by
  /// [testAssets].  This ignores the [context] that is passed in.  This will
  /// never throw an error or return `null` and will instead return an empty
  /// array if it encounters issues loading the tests.
  ///
  /// If the [suiteName] is not-null, this will exclude any tests that are not
  /// same test suite.
  Future<List<PendingTest>> testReader(
    BuildContext? context, {
    String? suiteName,
  }) async {
    List<String>? files = <String>[];

    if (testAssetIndex?.isNotEmpty == true) {
      try {
        final indexData = await rootBundle.loadString(testAssetIndex!);
        files = List<String>.from(json.decode(indexData));
      } catch (e, stack) {
        _logger.severe('Error in AssetTestStore.testReader', e, stack);
      }
    } else {
      files = testAssets;
    }

    final tests = <PendingTest>[];

    if (files?.isNotEmpty == true) {
      for (var asset in files!) {
        try {
          final text = await rootBundle.loadString(asset);
          if (text.isNotEmpty == true) {
            final parsed = json.decode(text);

            tests.addAll(TestStore.createMemoryTests(parsed));
          }
        } catch (e, stack) {
          _logger.severe('Error in AssetTestStore.testReader', e, stack);
        }
      }

      tests.removeWhere(
        (test) => suiteName?.isNotEmpty == true && suiteName != test.suiteName,
      );
    }

    return tests;
  }
}
