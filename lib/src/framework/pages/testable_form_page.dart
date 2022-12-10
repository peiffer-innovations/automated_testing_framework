import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Form that displays all the input options for an individual test step.
class TestableFormPage extends StatefulWidget {
  TestableFormPage({
    required this.form,
    required this.values,
    Key? key,
  }) : super(key: key);

  final TestStepForm form;
  final Map<String, dynamic> values;

  @override
  _TestableFormPageState createState() => _TestableFormPageState();
}

class _TestableFormPageState extends State<TestableFormPage>
    with ResetNavigationStateMixin {
  Map<String, dynamic>? _values;

  @override
  void initState() {
    super.initState();

    _values = Map.from(widget.values);
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    final theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    final translator = Translator.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                TextStyle(color: theme.textTheme.bodyMedium!.color),
              ),
            ),
            child: Text(
              translator.translate(TestTranslations.atf_button_cancel),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                TextStyle(color: theme.colorScheme.error),
              ),
            ),
            child: Text(
              translator.translate(
                TestTranslations.atf_button_discard,
              ),
            ),
          ),
        ],
        backgroundColor: theme.canvasColor,
        contentTextStyle: theme.textTheme.bodyMedium,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.warning,
              color: theme.textTheme.bodyMedium!.color,
              size: 54.0,
            ),
            const SizedBox(
              height: 16.0,
            ),
            Text(
              translator.translate(
                TestTranslations.atf_discard_changes,
              ),
            ),
          ],
        ),
      ),
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    final translator = Translator.of(context);
    final wide = mq.size.width >= 600.0;

    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () => _showDiscardDialog(context),
          child: Scaffold(
            appBar: AppBar(
              title: Text(translator.translate(widget.form.title)),
            ),
            body: Form(
              child: Builder(
                builder: (BuildContext context) => Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 600.0,
                          ),
                          child: widget.form.buildForm(context, _values),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: wide
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            flex: wide == true ? 0 : 1,
                            child: TextButton(
                              onPressed: () async {
                                final result =
                                    await _showDiscardDialog(context);

                                if (mounted == true && result == true) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(
                                translator.translate(
                                  TestTranslations.atf_button_cancel,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                            flex: wide == true ? 0 : 1,
                            child: TextButton(
                              onPressed: () {
                                final valid = Form.of(context).validate();
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
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
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
                                              color: theme
                                                  .textTheme.bodyMedium!.color,
                                              size: 54,
                                            ),
                                            const SizedBox(
                                              height: 16.0,
                                            ),
                                            Text(
                                              translator.translate(
                                                TestTranslations
                                                    .atf_correct_errors,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
