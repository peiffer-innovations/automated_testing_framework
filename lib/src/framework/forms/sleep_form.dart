import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class SleepForm extends TestStepForm {
  const SleepForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_sleep;

  @override
  Widget buildForm(
    BuildContext context,
    Map<String, dynamic>? values, {
    bool minify = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (minify != true)
          buildHelpSection(
            context,
            TestStepTranslations.atf_help_sleep,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              defaultValue: '5',
              id: 'timeout',
              label: TestStepTranslations.atf_form_seconds,
              validators: [
                RequiredValidator(),
                NumberValidator(),
                MinNumberValidator(number: 1),
              ],
              values: values!,
            ),
          ],
          minify: minify,
        ),
      ],
    );
  }
}
