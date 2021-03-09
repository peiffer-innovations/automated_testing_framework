import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class TapForm extends TestStepForm {
  const TapForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_tap;

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
            TestStepTranslations.atf_help_tap,
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
            if (minify != true) ...[
              SizedBox(height: 16.0),
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
