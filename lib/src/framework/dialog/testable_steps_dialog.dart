import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Dialog that displays the test steps in a quick access / minified form.
class TestableStepsDialog extends StatefulWidget {
  TestableStepsDialog({
    this.error,
    this.image,
    Key key,
    this.scrollableId,
    this.testableId,
    this.types,
    this.value,
  }) : super(key: key);

  final String error;
  final Uint8List image;
  final String scrollableId;
  final String testableId;
  final List<TestableType> types;
  final dynamic value;

  @override
  _TestableStepsDialogState createState() => _TestableStepsDialogState();
}

class _TestableStepsDialogState extends State<TestableStepsDialog> {
  final List<AvailableTestStep> _widgetSteps = [];

  @override
  void initState() {
    super.initState();

    var registry = TestStepRegistry.of(context);
    var availSteps = registry.availableSteps;

    availSteps.where((step) => step.widgetless == false).forEach((step) {
      if (step.supports(widget.types)) {
        _widgetSteps.add(step);
      }
    });
  }

  Map<String, dynamic> _createValues(AvailableTestStep step) => step.minify({
        'error': widget.error,
        'testableId': widget.testableId,
        'scrollableId': widget.scrollableId,
        'value': widget.value,
      });

  Future<bool> _fireForm({
    @required BuildContext context,
    @required AvailableTestStep step,
    bool executeImmediate = false,
  }) async {
    var added = false;
    var testController = TestController.of(context);
    var values = await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) => TestableFormDialog(
        form: step.form,
        values: _createValues(step),
      ),
    );

    TestStep testStep;
    if (values != null) {
      testStep = TestStep(
        id: step.id,
        image: step.widgetless == true ? null : widget.image,
        values: step.minify(values),
      );
      testController.currentTest.addTestStep(testStep);
      added = true;
    }

    if (executeImmediate == true && testStep != null) {
      await Navigator.of(context).pop();

      await TestController.of(context)?.execute(
        steps: [testStep],
        submitReport: false,
        reset: false,
      );
    }

    return added;
  }

  Future<void> _fireQuickAdd({
    @required BuildContext context,
    @required AvailableTestStep step,
    bool executeImmediate = false,
  }) async {
    var testController = TestController.of(context);
    var values = <String, dynamic>{}
      ..addAll(_createValues(step))
      ..addAll(step.quickAddValues);

    var testStep = TestStep(
      id: step.id,
      image: step.widgetless == true ? null : widget.image,
      values: step.minify(values),
    );
    testController.currentTest.addTestStep(testStep);

    if (executeImmediate == true) {
      await Navigator.of(context).pop();

      await TestController.of(context)?.execute(
        steps: [testStep],
        submitReport: false,
        reset: false,
      );
    }
  }

  Widget _buildTestAction(
    BuildContext context,
    AvailableTestStep step,
  ) {
    var translator = Translator.of(context);

    return ListTile(
      onLongPress: () async {
        var added = false;
        if (step.form.supportsMinified == true) {
          added = await _fireForm(context: context, step: step);
        } else {
          added = true;
          await _fireQuickAdd(context: context, step: step);
        }
        if (added == true) {
          var message = translator.translate(
            TestTranslations.atf_added_step_action,
            {
              'step': translator.translate(step.title),
            },
          );
          Navigator.of(context).pop(message);
        }
      },
      onTap: () async {
        var added = false;
        if (step.quickAddValues == null) {
          added = await _fireForm(context: context, step: step);
        } else {
          added = true;
          await _fireQuickAdd(context: context, step: step);
        }

        if (added == true) {
          var message = translator.translate(
            TestTranslations.atf_added_step_action,
            {
              'step': translator.translate(step.title),
            },
          );
          Navigator.of(context).pop(message);
        }
      },
      title: Text(translator.translate(step.title)),
      trailing: IconButton(
        icon: Icon(Icons.play_circle_filled),
        onPressed: () async {
          if (step.quickAddValues == null) {
            await _fireForm(
              context: context,
              step: step,
              executeImmediate: true,
            );
          } else {
            await _fireQuickAdd(
              context: context,
              step: step,
              executeImmediate: true,
            );
          }
        },
        tooltip: translator.translate(TestTranslations.atf_tooltip_add_and_run),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var translator = Translator.of(context);
    var numSteps = TestController.of(context).currentTest.steps.length;

    return AlertDialog(
      actions: [
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            translator.translate(TestTranslations.atf_button_cancel),
          ),
        ),
        FlatButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => TestStepsPage(
                  fromDialog: true,
                ),
              ),
            );
            if (mounted == true) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            translator.translate(
              TestTranslations.atf_button_view_test_steps,
              {
                'count': numSteps,
              },
            ),
          ),
        ),
      ],
      content: Builder(
        builder: (BuildContext context) => SafeArea(
          child: Container(
            width: double.maxFinite,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: <Widget>[
                if (widget.testableId?.isNotEmpty == true) ...[
                  for (var step in _widgetSteps)
                    _buildTestAction(
                      context,
                      step,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
      title: Text(
        translator.translate(TestTranslations.atf_selected_widget_steps),
      ),
    );
  }
}
