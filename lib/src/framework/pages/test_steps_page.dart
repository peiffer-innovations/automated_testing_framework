import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

/// Page that shows all the test steps and their values for a current test.
class TestStepsPage extends StatefulWidget {
  TestStepsPage({
    this.fromDialog,
    Key key,
  }) : super(key: key);

  final bool fromDialog;

  @override
  _TestStepsPageState createState() => _TestStepsPageState();
}

class _TestStepsPageState extends State<TestStepsPage> {
  static const _kClearTabIndex = 0;
  static const _kExportTabIndex = 1;
  static const _kRunAllTabIndex = 2;

  final Logger _logger = Logger('TestStepsPageState');

  bool _exporting = false;
  TestController _testController;

  @override
  void initState() {
    super.initState();

    _testController = TestController.of(context);
  }

  Widget _buildStep(
    BuildContext context, {
    @required int index,
    @required TestStep step,
  }) {
    var tester = TestController.of(context);
    var translator = Translator.of(context);
    var theme = Theme.of(context);
    return Padding(
      key: ValueKey(step.key),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        elevation: 2.0,
        child: Padding(
          padding: EdgeInsets.all(
            16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (step.image != null) ...[
                Container(
                  alignment: Alignment.center,
                  color: Colors.black12,
                  height: 200.0,
                  padding: EdgeInsets.all(16.0),
                  child: Image.memory(
                    step.image,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Divider(),
              ],
              Container(
                width: double.infinity,
                child: Text(
                  step.id,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              for (var entry in (step.values ?? {}).entries)
                _buildValueEntry(context, entry),
              Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Tooltip(
                    message: 'Move Up',
                    child: IconButton(
                      color: theme.iconTheme.color,
                      icon: Icon(Icons.arrow_upward),
                      onPressed: index == 0
                          ? null
                          : () {
                              var steps = List<TestStep>.from(
                                _testController.currentTest.steps,
                              );

                              steps.removeAt(index);
                              steps.insert(index - 1, step);

                              _testController.currentTest = _testController
                                  .currentTest
                                  .copyWith(steps: steps);
                              if (mounted == true) {
                                setState(() {});
                              }
                            },
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Tooltip(
                    message: 'Move Down',
                    child: IconButton(
                      color: theme.iconTheme.color,
                      icon: Icon(Icons.arrow_downward),
                      onPressed:
                          index == _testController.currentTest.steps.length - 1
                              ? null
                              : () {
                                  var steps = List<TestStep>.from(
                                    _testController.currentTest.steps,
                                  );

                                  steps.removeAt(index);
                                  steps.insert(index + 1, step);

                                  _testController.currentTest =
                                      _testController.currentTest.copyWith(
                                    steps: steps,
                                  );
                                  if (mounted == true) {
                                    setState(() {});
                                  }
                                },
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Tooltip(
                    message: translator.translate(
                      TestTranslations.atf_button_delete,
                    ),
                    child: IconButton(
                      color: theme.errorColor,
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        var steps = List<TestStep>.from(
                          _testController.currentTest.steps,
                        );

                        steps.remove(step);
                        _testController.currentTest =
                            _testController.currentTest.copyWith(
                          steps: steps,
                        );
                        if (mounted == true) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Tooltip(
                    message: translator.translate(
                      TestTranslations.atf_button_edit,
                    ),
                    child: IconButton(
                      color: theme.iconTheme.color,
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        var steps = List<TestStep>.from(
                          _testController.currentTest.steps,
                        );

                        var values = step?.values;
                        var idx = steps.indexOf(step);
                        var availableStep =
                            TestStepRegistry.of(context).getAvailableTestStep(
                          step?.id,
                        );

                        if (availableStep != null) {
                          var newValues = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  TestableFormPage(
                                form: availableStep.form,
                                values: values,
                              ),
                            ),
                          );

                          if (newValues != null) {
                            steps.removeAt(idx);
                            steps.insert(
                              idx,
                              step.copyWith(
                                values: newValues,
                              ),
                            );
                            _testController.currentTest =
                                _testController.currentTest.copyWith(
                              steps: steps,
                            );

                            if (mounted == true) {
                              setState(() {});
                            }
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Tooltip(
                    message: translator.translate(
                      TestTranslations.atf_button_run,
                    ),
                    child: IconButton(
                      color: theme.iconTheme.color,
                      icon: Icon(Icons.play_arrow),
                      onPressed: () async {
                        if (widget.fromDialog != true) {
                          Navigator.of(context).pop();
                        }
                        Navigator.of(context).pop();

                        try {
                          await tester.execute(
                            reset: false,
                            steps: [step],
                            submitReport: false,
                          );
                        } catch (e) {
                          tester.sleep = null;
                          tester.step = null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueEntry(
    BuildContext context,
    MapEntry<String, dynamic> entry,
  ) {
    var theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Divider(),
        Text(
          entry.key,
          style: theme.textTheme.bodyText1,
        ),
        Text(
          entry.value?.toString() ?? '',
          style: theme.textTheme.subtitle1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var tester = TestController.of(context);
    var theme = Theme.of(context);
    var translator = Translator.of(context);
    var testController = TestController.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              var label = translator.translate(TestTranslations.atf_test_name);
              var testName = tester.currentTest.name ?? '';
              var endTestName = await showDialog<String>(
                context: context,
                builder: (BuildContext context) => Form(
                  autovalidate: true,
                  child: Builder(
                    builder: (BuildContext context) => AlertDialog(
                      actions: [
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          child: Text(
                            translator.translate(
                              TestTranslations.atf_button_cancel,
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            var valid = Form.of(context).validate();
                            if (valid == true) {
                              Navigator.of(context).pop(testName);
                            }
                          },
                          child: Text(
                            translator.translate(
                              TestTranslations.atf_button_ok,
                            ),
                          ),
                        ),
                      ],
                      content: TextFormField(
                        autocorrect: false,
                        autofocus: true,
                        autovalidate: true,
                        decoration: InputDecoration(
                          labelText: label,
                        ),
                        initialValue: testName,
                        onChanged: (value) => testName = value,
                        validator: (value) =>
                            Validator(validators: [RequiredValidator()])
                                .validate(
                          context: context,
                          label: label,
                          value: value,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              if (endTestName?.isNotEmpty == true) {
                _testController.currentTest =
                    _testController.currentTest.copyWith(
                  name: endTestName,
                );
                if (mounted == true) {
                  setState(() {});
                }
              }
            },
            tooltip: translator.translate(TestTranslations.atf_button_edit),
          ),
        ],
        title: Text(
          _testController.currentTest.name ??
              translator.translate(
                TestTranslations.atf_unnamed_test,
              ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _exporting == true,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  children: <Widget>[
                    for (var i = 0;
                        i < testController.currentTest.steps.length;
                        i++)
                      _buildStep(
                        context,
                        index: i,
                        step: testController.currentTest.steps[i],
                      ),
                  ],
                ),
              ),
            ),
            if (_exporting == true) ...[
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: LinearProgressIndicator(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: IgnorePointer(
        ignoring: _exporting == true,
        child: Builder(
          builder: (BuildContext context) => BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.clear,
                  color: theme.errorColor,
                ),
                title: Text(
                  translator.translate(
                    TestTranslations.atf_button_clear,
                  ),
                  style: TextStyle(color: theme.errorColor),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.save,
                  color: theme.iconTheme.color,
                ),
                title: Text(
                  translator.translate(
                    TestTranslations.atf_button_export,
                  ),
                  style: TextStyle(color: theme.iconTheme.color),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.play_circle_filled,
                  color: theme.iconTheme.color,
                ),
                title: Text(
                  translator.translate(
                    TestTranslations.atf_button_run_all,
                  ),
                  style: TextStyle(color: theme.iconTheme.color),
                ),
              ),
            ],
            onTap: (int index) async {
              switch (index) {
                case _kClearTabIndex:
                  var clear = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) => Theme(
                      data: theme,
                      child: AlertDialog(
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              translator.translate(
                                TestTranslations.atf_button_cancel,
                              ),
                            ),
                          ),
                          FlatButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            textColor: theme.errorColor,
                            child: Text(
                              translator.translate(
                                TestTranslations.atf_button_clear,
                              ),
                            ),
                          ),
                        ],
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.warning,
                              color: theme.primaryTextTheme.bodyText2.color,
                              size: 54.0,
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              translator.translate(
                                TestTranslations.atf_clear_confirmation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );

                  if (clear == true) {
                    testController.currentTest = Test();
                    await Navigator.of(context).pop();
                  }
                  break;
                case _kExportTabIndex:
                  _exporting = true;
                  if (mounted == true) {
                    setState(() {});
                  }
                  try {
                    if (await testController.exportCurrentTest(
                          context: context,
                        ) ==
                        true) {
                      await Navigator.of(context).pop();
                    }
                  } finally {
                    _exporting = false;
                    if (mounted == true) {
                      setState(() {});
                    }
                  }

                  break;

                case _kRunAllTabIndex:
                  var controller = TestableRenderController.of(context);
                  controller.showGlobalOverlay = false;
                  var tester = TestController.of(context);
                  try {
                    await tester.execute(
                      steps: _testController.currentTest.steps,
                      submitReport: false,
                      reset: true,
                    );
                  } catch (e, stack) {
                    _logger.severe(e, stack);
                  }
                  break;

                default:
                  throw FlutterError('Unknown tab index encountered');
              }
            },
          ),
        ),
      ),
    );
  }
}
