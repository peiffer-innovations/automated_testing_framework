import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

/// Test store that can be used to read and write tests from / to the clipboard.
/// The clipboard may contain one or more tests when attempting to load from the
/// clipboard.
///
/// This particular store is mostly helpful for building or loading tests on an
/// emulator where the clipboard is shared with the host computer.
/// Specifically, it provides the ability to create tests, export them to the
/// clipboard for the host computer to save it for later use.
///
/// The [ClipboardTestStore] only supports the read and write operations but not
/// the report operation.
class ClipboardTestStore {
  static final Logger _logger = Logger('ClipboardTestStore');

  /// Reads the tests from the clipboard.  There can be one or more tests in the
  /// clipboard.  This ignores the [context] that is passed in.  This will
  /// never throw an error or return `null` and will instead return an empty
  /// array if it encounters issues loading the tests.
  ///
  /// If the [suiteName] is not-null, this will exclude any tests that are not
  /// same test suite.
  static Future<List<PendingTest>> testReader(
    BuildContext context, {
    String? suiteName,
  }) async {
    var tests = <PendingTest>[];

    try {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text?.isNotEmpty == true) {
        final parsed = json.decode(text!);
        tests = TestStore.createMemoryTests(parsed);
      }

      tests.removeWhere(
        (test) => suiteName?.isNotEmpty == true && suiteName != test.suiteName,
      );
    } catch (e, stack) {
      _logger.severe('Error in ClipboardTestStore.testReader', e, stack);
    }

    return tests;
  }

  /// Saves the [test] to the clipboard.
  static Future<bool> testWriter(
    BuildContext context,
    Test test,
  ) async {
    final encoder = const JsonEncoder.withIndent('  ');
    final encoded = encoder.convert(test.toJson());

    final translator = Translator.of(context);

    await Clipboard.setData(ClipboardData(text: encoded));

    final snackBar = SnackBar(
      content: Text(
        translator.translate(
          TestTranslations.atf_copied_to_clipboard,
        ),
      ),
    );

    try {
      final controller = ScaffoldMessenger.of(context).showSnackBar(snackBar);
      await controller.closed;
    } catch (e) {
      // no-op
    }

    return true;
  }
}
