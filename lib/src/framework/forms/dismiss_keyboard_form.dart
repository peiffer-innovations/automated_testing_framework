import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

class DismissKeyboardForm extends TestStepForm {
  const DismissKeyboardForm();

  @override
  bool get supportsMinified => false;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_dismiss_keyboard;

  @override
  Widget buildForm(
    BuildContext context,
    Map<String, dynamic>? values, {
    bool minify = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildHelpSection(
          context,
          TestStepTranslations.atf_help_dismiss_keyboard,
          minify: minify,
        ),
      ],
    );
  }
}
