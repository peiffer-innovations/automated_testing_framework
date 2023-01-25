import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

class TestStepPicker extends StatefulWidget {
  TestStepPicker({
    Key? key,
    required this.label,
    required this.onStepChanged,
    this.step,
  }) : super(key: key);

  final String label;
  final ValueChanged<TestStep?> onStepChanged;
  final TestStep? step;

  @override
  _TestStepPickerState createState() => _TestStepPickerState();
}

class _TestStepPickerState extends State<TestStepPicker> {
  TestRunnerState? _testRunner;
  TestStep? _step;

  @override
  void initState() {
    super.initState();

    _testRunner = TestRunner.of(context);
    _step = widget.step;
  }

  Future<void> _openTestStep({
    AvailableTestStep? aStep,
    required BuildContext context,
    ThemeData? theme,
  }) async {
    final values = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => Theme(
          data: theme!,
          child: TestableFormPage(
            form: aStep!.form,
            values: _step?.values ?? {},
          ),
        ),
      ),
    );

    if (values != null) {
      _step = TestStep(
        id: aStep!.id,
        values: values,
      );
    }

    if (mounted == true) {
      widget.onStepChanged(_step);
      Navigator.of(context).pop();
    }
  }

  Future<void> _showAvailableSteps(BuildContext context) async {
    final theme = _testRunner?.theme ?? Theme.of(context);
    final translator = Translator.of(context);
    final steps =
        (_testRunner?.controller?.registry ?? TestStepRegistry.instance)
            .availableSteps;

    await showDialog(
      context: context,
      builder: (BuildContext context) => Theme(
        data: theme,
        child: AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                widget.onStepChanged(null);
                setState(() => _step = null);
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(color: theme.colorScheme.error),
                ),
              ),
              child: Text(
                translator.translate(TestTranslations.atf_button_clear),
              ),
            ),
            TextButton(
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
    final translator = Translator.of(context);
    final theme = TestRunner.of(context)?.theme ?? Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.label,
          style: theme.textTheme.bodySmall,
        ),
        ListTile(
          onTap: () => _showAvailableSteps(context),
          subtitle: _step?.values?.containsKey('testableId') == true
              ? Text(_step!.values!['testableId'] ?? '')
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
