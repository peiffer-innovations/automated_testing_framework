import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class ScrollUntilVisibleForm extends TestStepForm {
  const ScrollUntilVisibleForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title =>
      TestStepTranslations.atf_title_scroll_until_visible;

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
            TestStepTranslations.atf_help_scroll_until_visible,
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
              id: 'scrollableId',
              label: TestStepTranslations.atf_form_scrollable_id,
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildEditText(
              context: context,
              defaultValue: '200',
              id: 'increment',
              label: TestStepTranslations.atf_form_scroll_increment,
              validators: [
                RequiredValidator(),
                NumberValidator(),
              ],
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
