import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

class ClipboardTestStore {
  static final Logger _logger = Logger('ClipboardTestStore');

  static Future<List<PendingTest>> testReader(BuildContext context) async {
    List<PendingTest> tests;

    try {
      var data = await Clipboard.getData('text/plain');
      var text = data?.text;
      if (text?.isNotEmpty == true) {
        var parsed = json.decode(text);
        tests = TestStore.createMemoryTests(parsed);
      }
    } catch (e, stack) {
      _logger.severe('Error loading tests from clipboard', e, stack);
    }

    if (tests?.isEmpty == true) {
      tests = null;
    }
    return tests;
  }

  static Future<bool> testWriter(
    BuildContext context,
    Test test,
  ) async {
    var encoder = JsonEncoder.withIndent('  ');
    var encoded = encoder.convert(test.toJson());

    var translator = Translator.of(context);

    await Clipboard.setData(ClipboardData(text: encoded));

    var snackBar = SnackBar(
      content: Text(
        translator.translate(
          TestTranslations.atf_copied_to_clipboard,
        ),
      ),
    );
    var controller = Scaffold.of(context).showSnackBar(snackBar);
    await controller.closed;

    return true;
  }
}
