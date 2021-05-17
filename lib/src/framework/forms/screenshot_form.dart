import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';
import 'package:uuid/uuid.dart';

class ScreenshotForm extends TestStepForm {
  const ScreenshotForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_screenshot;

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
            TestStepTranslations.atf_help_screenshot,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              defaultValue: Uuid().v4(),
              id: 'imageId',
              label: TestStepTranslations.atf_form_image_id,
              validators: [RequiredValidator()],
              values: values!,
            ),
            SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              defaultValue: 'true',
              id: 'goldenCompatible',
              items: [
                'true',
                'false',
              ],
              label: TestStepTranslations.atf_form_golden_compatible,
              values: values,
            ),
          ],
          minify: minify,
        ),
      ],
    );
  }
}
