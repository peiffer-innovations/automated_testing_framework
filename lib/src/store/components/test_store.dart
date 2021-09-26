import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:static_translations/static_translations.dart';

/// Generic test store that provies no-op implementations of all the test
/// storage functions.
///
/// See also:
/// * [AssetTestStore]
/// * [ClipboardTestStore]
/// * [IoTestStore]
class TestStore {
  TestStore._();

  /// Creates a list of [Test] objects from a given dynamic object.  The dynamic
  /// object must be either a [List] of [Map] objects or an individual [Map]
  /// object that follow the structure defined in [Test.fromDynamic].
  ///
  /// The optional [ignoreImages] parameter can be used to save memory when a
  /// large number of tests are loaded.  By ignoring the images, the memory
  /// required to host those images is removed.
  ///
  /// This will never return `null`.  If no tests exists in the [object] then
  /// this will return an empty array.
  static List<PendingTest> createMemoryTests(
    dynamic object, {
    bool ignoreImages = true,
  }) {
    List<PendingTest>? tests;

    if (object is List) {
      var tempTests = JsonClass.fromDynamicList(
        object,
        (map) => Test.fromDynamic(map),
      )!;
      tempTests.removeWhere(
        (test) =>
            test.name?.isNotEmpty != true && test.steps.isNotEmpty != true,
      );

      tests = [];
      for (var t in tempTests) {
        tests.add(PendingTest.memory(t));
      }
    } else {
      var test = Test.fromDynamic(object);

      if (test.name?.isNotEmpty == true && test.steps.isNotEmpty == true) {
        tests = [PendingTest.memory(test)];
      }
    }

    return tests ?? <PendingTest>[];
  }

  /// Generic no-op function compatible with the [GoldenImageWriter] definition.
  static Future<void> goldenImageWriter(TestReport testReport) async => null;

  /// Generic no-op function compatible with the [TestImageReader] definition.
  static Future<Uint8List?> testImageReader({
    required TestDeviceInfo deviceInfo,
    required String imageId,
    String? suiteName,
    required String testName,
    int? testVersion,
  }) async =>
      null;

  /// Generic no-op function compatible with the [TestReader] definition.
  static Future<List<PendingTest>?> testReader(
    BuildContext? context, {
    String? suiteName,
  }) async {
    await _showNotSupported(context);
    return null;
  }

  /// Generic no-op function compatible with the [TestReporter] definition.
  static Future<bool> testReporter(TestReport report) async => false;

  /// Generic no-op function compatible with the [TestWriter] definition.
  static Future<bool> testWriter(
    BuildContext context,
    Test test,
  ) async {
    await _showNotSupported(context);
    return false;
  }

  static Future<void> _showNotSupported(BuildContext? context,
      [TranslationEntry? entry]) async {
    var translator = Translator.of(context);
    var snackBar = SnackBar(
      content: Text(
        translator.translate(
          entry ?? TestTranslations.atf_operation_not_supported,
        ),
      ),
    );

    if (context != null) {
      var controller = ScaffoldMessenger.of(context).showSnackBar(snackBar);
      await controller.closed;
    }
  }
}
