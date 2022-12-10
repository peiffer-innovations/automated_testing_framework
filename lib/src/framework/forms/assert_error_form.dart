import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class AssertErrorForm extends TestStepForm {
  const AssertErrorForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_assert_error;

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
            TestStepTranslations.atf_help_assert_error,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              id: 'testableId',
              label: TestStepTranslations.atf_form_widget_id,
              validators: [
                RequiredValidator(),
              ],
              values: values!,
            ),
            const SizedBox(height: 16.0),
            buildEditText(
              context: context,
              id: 'error',
              label: TestStepTranslations.atf_form_error,
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              defaultValue: 'true',
              id: 'equals',
              items: [
                'true',
                'false',
              ],
              label: TestStepTranslations.atf_form_equals,
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              defaultValue: 'true',
              id: 'caseSensitive',
              items: [
                'true',
                'false',
              ],
              label: TestStepTranslations.atf_form_case_sensitive,
              values: values,
            ),
            if (minify != true) ...[
              const SizedBox(height: 16.0),
              buildTimeoutSection(
                context: context,
                values: values,
              ),
            ],
          ],
          minify: minify,
        ),
      ],
    );
  }
}
