import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

class ScreenshotForm extends TestStepForm {
  const ScreenshotForm();

  @override
  bool get supportsMinified => false;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_screenshot;

  @override
  Widget buildForm(
    BuildContext context,
    Map<String, dynamic> values, {
    bool minify = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildHelpSection(
          context,
          TestStepTranslations.atf_help_screenshot,
          minify: minify,
        ),
      ],
    );
  }
}
