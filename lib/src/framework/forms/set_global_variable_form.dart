import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class SetGlobalVariableForm extends TestStepForm {
  const SetGlobalVariableForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title =>
      TestStepTranslations.atf_title_set_global_variable;

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
            TestStepTranslations.atf_help_set_global_variable,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              id: 'variableName',
              label: TestStepTranslations.atf_form_variable_name,
              validators: [
                RequiredValidator(),
              ],
              values: values!,
            ),
            const SizedBox(height: 16.0),
            buildEditText(
              context: context,
              id: 'value',
              label: TestStepTranslations.atf_form_value,
              validators: [RequiredValidator()],
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              defaultValue: 'String',
              id: 'type',
              items: [
                'bool',
                'double',
                'int',
                'String',
              ],
              label: TestStepTranslations.atf_form_type,
              values: values,
            ),
          ],
          minify: minify,
        ),
      ],
    );
  }
}
