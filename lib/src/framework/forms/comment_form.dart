import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class CommentForm extends TestStepForm {
  const CommentForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title => TestStepTranslations.atf_title_comment;

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
            TestStepTranslations.atf_help_comment,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              id: 'comment',
              label: TestStepTranslations.atf_form_comment,
              maxLines: null,
              minLines: 5,
              validators: [
                RequiredValidator(),
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
