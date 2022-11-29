import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Dialog for test forms.  This is used for the quick dialog version of adding
/// a test step.
class TestableFormDialog extends StatefulWidget {
  TestableFormDialog({
    required this.form,
    required this.values,
    Key? key,
  }) : super(key: key);

  /// The form for the dialog.  The form will render with [minify] set to
  /// [true].
  final TestStepForm form;

  /// The current values that exist.
  final Map<String, dynamic> values;

  @override
  _TestableFormDialogState createState() => _TestableFormDialogState();
}

class _TestableFormDialogState extends State<TestableFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _values;

  @override
  void initState() {
    super.initState();

    _values = Map.from(widget.values);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var translator = Translator.of(context);

    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            translator.translate(
              TestTranslations.atf_button_cancel,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            var valid = _formKey.currentState!.validate();
            if (valid == true) {
              Navigator.of(context).pop(_values);
            } else {
              showDialog<bool>(
                context: context,
                builder: (BuildContext context) => Theme(
                  data: theme,
                  child: AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          translator.translate(
                            TestTranslations.atf_button_ok,
                          ),
                        ),
                      ),
                    ],
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.warning,
                          color: theme.textTheme.bodyMedium!.color,
                          size: 54,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          translator.translate(
                            TestTranslations.atf_correct_errors,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
          child: Text(
            translator.translate(
              TestTranslations.atf_button_submit,
            ),
          ),
        ),
      ],
      content: Form(
        key: _formKey,
        child: Builder(
          builder: (BuildContext context) => Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 600.0,
                ),
                child: widget.form.buildForm(
                  context,
                  _values,
                  minify: true,
                ),
              ),
            ),
          ),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
      title: Text(translator.translate(widget.form.title)),
    );
  }
}
