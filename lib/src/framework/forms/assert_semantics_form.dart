import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class AssertSemanticsForm extends TestStepForm {
  const AssertSemanticsForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_assert_semantics;

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
            TestStepTranslations.atf_help_assert_semantics,
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
            SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              id: 'field',
              items: [
                'currentValueLength',
                'decreasedValue',
                'elevation',
                'hasImplicitScrolling',
                'hint',
                'increasedValue',
                'isButton',
                'isChecked',
                'isEnabled',
                'isFocusable',
                'isFocused',
                'isHeader',
                'isHidden',
                'isImage',
                'isInMutuallyExclusiveGroup',
                'isKeyboardKey',
                'isLink',
                'isMultiline',
                'isObscured',
                'isReadOnly',
                'isSelected',
                'isSlider',
                'isTextField',
                'isToggled',
                'label',
                'maxValueLength',
                'scrollChildCount',
                'scrollExtentMax',
                'scrollExtentMin',
                'scrollIndex',
                'scrollPosition',
                'thickness',
                'value',
              ],
              label: TestStepTranslations.atf_form_field,
              validators: [
                RequiredValidator(),
              ],
              values: values,
            ),
            SizedBox(height: 16.0),
            buildEditText(
              context: context,
              id: 'value',
              label: TestStepTranslations.atf_form_value,
              values: values,
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
