import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:json_class/json_class.dart';
import 'package:static_translations/static_translations.dart';

abstract class TestStepForm {
  const TestStepForm();

  bool get supportsMinified;
  TranslationEntry get title;

  Widget buildForm(
    BuildContext context,
    Map<String, dynamic> values, {
    bool minify = false,
  });

  @protected
  Widget buildDropdown({
    @required BuildContext context,
    @required String id,
    String defaultValue,
    List<String> items,
    @required TranslationEntry label,
    List<ValueValidator> validators,
    @required Map<String, dynamic> values,
  }) {
    assert(context != null);
    assert(id?.isNotEmpty == true);
    assert(label != null);
    assert(values != null);

    if (values[id] == null && defaultValue != null) {
      values[id] = defaultValue;
    }

    var translator = Translator.of(context);
    return DropdownButtonFormField<String>(
      autovalidate: validators?.isNotEmpty == true,
      decoration: InputDecoration(
        labelText: translator.translate(label),
      ),
      items: [
        for (var item in items)
          DropdownMenuItem(
            value: item,
            child: Text(item),
          ),
      ],
      onChanged: (value) => values[id] = value,
      value: values[id],
      validator: (value) => validators?.isNotEmpty == true
          ? Validator(validators: validators).validate(
              context: context,
              label: translator.translate(label),
              value: value,
            )
          : null,
    );
  }

  @protected
  Widget buildEditText({
    @required BuildContext context,
    @required String id,
    String defaultValue,
    @required TranslationEntry label,
    List<ValueValidator> validators,
    @required Map<String, dynamic> values,
  }) {
    assert(context != null);
    assert(id?.isNotEmpty == true);
    assert(label != null);
    assert(values != null);

    if (values[id] == null && defaultValue != null) {
      values[id] = defaultValue;
    }

    var translator = Translator.of(context);
    return TextFormField(
      autovalidate: validators?.isNotEmpty == true,
      decoration: InputDecoration(
        labelText: translator.translate(label),
      ),
      initialValue: values[id]?.toString(),
      onChanged: (value) => values[id] = value,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      validator: (value) => validators?.isNotEmpty == true
          ? Validator(validators: validators).validate(
              context: context,
              label: translator.translate(label),
              value: value,
            )
          : null,
    );
  }

  @protected
  Widget buildHelpSection(
    BuildContext context,
    TranslationEntry helpText, {
    bool minify = false,
  }) {
    var theme = Theme.of(context);
    var translator = Translator.of(context);
    return Padding(
      padding: minify == true
          ? EdgeInsets.zero
          : EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              0.0,
            ),
      child: Material(
        borderRadius: minify == true ? null : BorderRadius.circular(16.0),
        elevation: minify == true ? 0.0 : 2.0,
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.help,
                color: theme.textTheme.bodyText2.color,
              ),
              SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: Text(
                  translator.translate(helpText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @protected
  Widget buildTimeoutSection({
    @required BuildContext context,
    Duration defaultTimeout,
    @required Map<String, dynamic> values,
  }) {
    assert(context != null);
    assert(values != null);

    const id = 'timeout';
    final label = TestTranslations.atf_timeout_seconds;

    defaultTimeout ??= TestController.of(context).delays.defaultTimeout;

    var translator = Translator.of(context);
    return TextFormField(
      autovalidate: true,
      decoration: InputDecoration(
        labelText: translator.translate(label),
      ),
      initialValue:
          JsonClass.parseDurationFromSeconds(values[id], defaultTimeout)
              .inSeconds
              .toString(),
      keyboardType: TextInputType.phone,
      onChanged: (value) => values[id] = value,
      validator: (value) => Validator(validators: [
        RequiredValidator(),
        NumberValidator(),
        MinNumberValidator(number: 1),
      ]).validate(
        context: context,
        label: translator.translate(label),
        value: value,
      ),
    );
  }

  @protected
  Widget buildValuesSection(
    BuildContext context,
    List<Widget> children, {
    bool minify = false,
  }) {
    return Padding(
      padding: minify == true
          ? EdgeInsets.zero
          : EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              0.0,
            ),
      child: Material(
        borderRadius: minify == true ? null : BorderRadius.circular(16.0),
        elevation: minify == true ? 0.0 : 2.0,
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: double.infinity,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}
