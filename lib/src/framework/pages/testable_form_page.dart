import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Form that displays all the input options for an individual test step.
class TestableFormPage extends StatefulWidget {
  TestableFormPage({
    @required this.form,
    @required this.values,
    Key key,
  })  : assert(form != null),
        assert(values != null),
        super(key: key);

  final TestStepForm form;
  final Map<String, dynamic> values;

  @override
  _TestableFormPageState createState() => _TestableFormPageState();
}

class _TestableFormPageState extends State<TestableFormPage> {
  Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();

    _values = Map.from(widget.values);
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    var translator = Translator.of(context);
    var result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            textColor: theme.textTheme.bodyText2.color,
            child: Text(
              translator.translate(TestTranslations.atf_button_cancel),
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            textColor: Colors.red,
            child: Text(
              translator.translate(
                TestTranslations.atf_button_discard,
              ),
            ),
          ),
        ],
        backgroundColor: theme.canvasColor,
        contentTextStyle: theme.textTheme.bodyText2,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.warning,
              color: theme.textTheme.bodyText2.color,
              size: 54.0,
            ),
            SizedBox(
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
    var mq = MediaQuery.of(context);
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    var translator = Translator.of(context);
    var wide = mq.size.width >= 600.0;

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
                          constraints: BoxConstraints(
                            maxWidth: 600.0,
                          ),
                          child: widget.form.buildForm(context, _values),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: wide
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            flex: wide == true ? 0 : 1,
                            child: FlatButton(
                              onPressed: () async {
                                var result = await _showDiscardDialog(context);

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
                          SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                            flex: wide == true ? 0 : 1,
                            child: FlatButton(
                              onPressed: () {
                                var valid = Form.of(context).validate();
                                if (valid == true) {
                                  Navigator.of(context).pop(_values);
                                } else {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) => Theme(
                                      data: theme,
                                      child: AlertDialog(
                                        actions: [
                                          FlatButton(
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
                                                  .textTheme.bodyText2.color,
                                              size: 54,
                                            ),
                                            SizedBox(
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
