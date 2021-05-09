import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Tab that shows the test steps in the full list view.
class TestStepListFullTab extends StatefulWidget {
  TestStepListFullTab({
    this.fromDialog,
    Key? key,
  }) : super(key: key);

  final bool? fromDialog;

  @override
  _TestStepListFullTabState createState() => _TestStepListFullTabState();
}

class _TestStepListFullTabState extends State<TestStepListFullTab> {
  late TestController _testController;

  @override
  void initState() {
    super.initState();

    _testController = TestController.of(context)!;
  }

  Future<void> _onEditStep({
    required TestStep step,
    required ThemeData theme,
    required Translator translator,
  }) async {
    var steps = List<TestStep>.from(
      _testController.currentTest.steps,
    );

    var values = step.values ?? <String, dynamic>{};
    var idx = steps.indexOf(step);
    var availableStep = TestStepRegistry.of(context).getAvailableTestStep(
      step.id,
    );

    if (availableStep != null) {
      var newValues = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => TestableFormPage(
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
        _testController.currentTest = _testController.currentTest.copyWith(
          steps: steps,
        );

        if (mounted == true) {
          setState(() {});
        }
      }
    } else {
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => Theme(
          data: theme,
          child: AlertDialog(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  translator.translate(
                    TestTranslations.atf_button_cancel,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    TextStyle(color: theme.errorColor),
                  ),
                ),
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
                  color: theme.textTheme.bodyText2!.color,
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
    }
  }

  Widget _buildFullStep(
    BuildContext context, {
    required int index,
    required TestStep step,
  }) {
    var tester = TestController.of(context);
    var translator = Translator.of(context);
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    return Padding(
      key: ValueKey(step.key),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        elevation: 2.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
                    step.image!,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Divider(),
              ],
              Container(
                width: double.infinity,
                child: Text(
                  '${index + 1}) ${step.id}',
                  style: theme.textTheme.headline6,
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
                    message: translator.translate(
                      TestTranslations.atf_tooltip_move_up,
                    ),
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
                    message: translator.translate(
                      TestTranslations.atf_tooltip_move_down,
                    ),
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
                      onPressed: () => _onEditStep(
                        step: step,
                        theme: theme,
                        translator: translator,
                      ),
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
                          await tester!.execute(
                            reset: false,
                            steps: [step],
                            submitReport: false,
                            version: 0,
                          );
                        } catch (e) {
                          tester!.sleep = null;
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
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
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
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      children: <Widget>[
        for (var i = 0; i < _testController.currentTest.steps.length; i++)
          _buildFullStep(
            context,
            index: i,
            step: _testController.currentTest.steps[i],
          ),
      ],
    );
  }
}
