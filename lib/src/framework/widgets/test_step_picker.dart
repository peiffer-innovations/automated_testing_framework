import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

class TestStepPicker extends StatefulWidget {
  TestStepPicker({
    Key key,
    @required this.label,
    @required this.onStepChanged,
    this.step,
  })  : assert(label?.isNotEmpty == true),
        super(key: key);

  final String label;
  final ValueChanged<TestStep> onStepChanged;
  final TestStep step;

  @override
  _TestStepPickerState createState() => _TestStepPickerState();
}

class _TestStepPickerState extends State<TestStepPicker> {
  TestRunnerState _testRunner;
  TestStep _step;

  @override
  void initState() {
    super.initState();

    _testRunner = TestRunner.of(context);
    _step = widget.step;
  }

  Future<void> _openTestStep({
    AvailableTestStep aStep,
    BuildContext context,
    ThemeData theme,
  }) async {
    var values = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => Theme(
          data: theme,
          child: TestableFormPage(
            form: aStep.form,
            values: _step?.values ?? {},
          ),
        ),
      ),
    );

    if (values != null) {
      _step = TestStep(
        id: aStep.id,
        values: values,
      );
    }

    if (mounted == true) {
      widget.onStepChanged(_step);
      Navigator.of(context).pop();
    }
  }

  Future<void> _showAvailableSteps(BuildContext context) async {
    var theme = _testRunner?.theme ?? Theme.of(context);
    var translator = Translator.of(context);
    var steps = (_testRunner?.controller?.registry ?? TestStepRegistry.instance)
        .availableSteps
        .where((s) => s.form != null)
        .toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) => Theme(
        data: theme,
        child: AlertDialog(
          actions: [
            FlatButton(
              onPressed: () {
                widget.onStepChanged(null);
                setState(() => _step = null);
                Navigator.of(context).pop();
              },
              textColor: theme.errorColor,
              child: Text(
                translator.translate(TestTranslations.atf_button_clear),
              ),
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                translator.translate(TestTranslations.atf_button_cancel),
              ),
            ),
          ],
          content: SafeArea(
            child: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: steps.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) => ListTile(
                  onTap: () => _openTestStep(
                    aStep: steps[index],
                    context: context,
                    theme: theme,
                  ),
                  title: Text(translator.translate(steps[index].title)),
                ),
              ),
            ),
          ),
          title: Text(translator.translate(TestTranslations.atf_test_steps)),
        ),
      ),
    );

    if (mounted == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var translator = Translator.of(context);
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.label,
          style: theme.textTheme.caption,
        ),
        ListTile(
          onTap: () => _showAvailableSteps(context),
          subtitle: _step?.values?.containsKey('testableId') == true
              ? Text(_step.values['testableId'] ?? '')
              : null,
          title: Text(
            _step?.id ??
                translator.translate(TestTranslations.atf_no_test_step),
          ),
        ),
      ],
    );
  }
}
