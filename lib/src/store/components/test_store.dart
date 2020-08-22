import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:static_translations/static_translations.dart';

class TestStore {
  TestStore._();

  /// Creates a list of [Test] objects from a given dynamic object.  The dynamic
  /// object must be either a [List] of [Map] objects or an individual [Map]
  /// object that follow the structure defined in [Test.fromDynamic].
  ///
  /// This will never return [null].  If no tests exists in the [object] then
  /// this will return an empty array.
  static List<Test> createTests(dynamic object) {
    List<Test> tests;

    if (object is List) {
      tests = JsonClass.fromDynamicList(
        object,
        (map) => Test.fromDynamic(map),
      );
      tests.removeWhere(
        (test) =>
            test.name?.isNotEmpty != true && test.steps?.isNotEmpty != true,
      );
    } else {
      var test = Test.fromDynamic(object);

      if (test.name?.isNotEmpty == true && test.steps?.isNotEmpty == true) {
        tests = [test];
      }
    }

    return tests ?? <Test>[];
  }

  static Future<List<Test>> testReader(BuildContext context) async {
    await _showNotSupported(context);
    return null;
  }

  static Future<bool> testReporter(TestReport report) async => false;

  static Future<bool> testWriter(
    BuildContext context,
    Test test,
  ) async {
    await _showNotSupported(context);
    return false;
  }

  static Future<void> _showNotSupported(BuildContext context,
      [TranslationEntry entry]) async {
    var translator = Translator.of(context);
    var snackBar = SnackBar(
      content: Text(
        translator.translate(
          entry ?? TestTranslations.atf_operation_not_supported,
        ),
      ),
    );
    var controller = Scaffold.of(context).showSnackBar(snackBar);
    await controller.closed;
  }
}
