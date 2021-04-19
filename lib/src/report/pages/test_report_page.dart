import 'package:automated_testing_framework/automated_testing_framework.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

/// Page that can display a full test report.
class TestReportPage extends StatefulWidget {
  TestReportPage({
    Key? key,
  }) : super(key: key);

  @override
  _TestReportPageState createState() => _TestReportPageState();
}

class _TestReportPageState extends State<TestReportPage> {
  static final _logger = Logger('_TestReportPageState');
  bool _saving = false;

  Future<void> _saveGoldenImages(
    BuildContext context, {
    required TestReport report,
    required TestController tester,
  }) async {
    var translator = Translator.of(context);

    _saving = true;
    if (mounted == true) {
      setState(() {});
    }

    var success = true;
    try {
      await tester.goldenImageWriter(report);
    } catch (e, stack) {
      success = false;
      _logger.severe('Error uploading golden images', e, stack);
    }

    if (success == true) {
      var snackBar = SnackBar(
        content: Text(
          translator.translate(TestTranslations.atf_export_successful),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      var snackBar = SnackBar(
        content: Text(
          translator.translate(TestTranslations.atf_error_has_occurred),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    _saving = false;
    if (mounted == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var report = ModalRoute.of(context)!.settings.arguments as TestReport?;
    var tester = TestController.of(context);
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    var translator = Translator.of(context);
    var unknown = translator.translate(TestTranslations.atf_unnamed_test);
    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            actions: [
              if (tester!.currentTest.steps.isNotEmpty == true)
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () async {
                    await tester.execute(
                      name: tester.currentTest.name,
                      reset: true,
                      steps: tester.currentTest.steps,
                      submitReport: false,
                      suiteName: tester.currentTest.suiteName,
                      version: tester.currentTest.version,
                    );
                  },
                  tooltip:
                      translator.translate(TestTranslations.atf_button_rerun),
                ),
            ],
            title: Text(
              translator.translate(TestTranslations.atf_test_results),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                IgnorePointer(
                  ignoring: _saving == true,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            Widget result;
                            if (index == 0) {
                              if (report!.runtimeException?.isNotEmpty ==
                                  true) {
                                result = Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.warning,
                                        size: 64.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .color,
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        report.runtimeException!,
                                        maxLines: 5,
                                      ),
                                      SizedBox(
                                        height: 16.0,
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                );
                              } else {
                                result = Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(height: 16.0),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Positioned.fill(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.red,
                                              strokeWidth: 16.0,
                                              value: report.passedSteps
                                                      .toDouble() /
                                                  report.steps.length,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.green),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            height: 160.0,
                                            width: 160.0,
                                            child: report.success == true
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 120.0,
                                                  )
                                                : RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${report.passedSteps}',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 32.0,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              ' / ${report.steps.length}',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2!
                                                                .color,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.0),
                                      Material(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        elevation: 2.0,
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      translator.translate(
                                                        TestTranslations
                                                            .atf_test_name,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 16.0,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      report.name ?? unknown,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'monospaced',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (report
                                                      .suiteName?.isNotEmpty ==
                                                  true) ...[
                                                Divider(),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        translator.translate(
                                                          TestTranslations
                                                              .atf_suite_name,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 16.0,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        report.suiteName!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'monospaced',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              Divider(),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      translator.translate(
                                                        TestTranslations
                                                            .atf_version,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 16.0,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      '${report.version}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'monospaced',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else if (index - 1 < report!.steps.length) {
                              index--;
                              result = Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: Material(
                                  borderRadius: BorderRadius.circular(16.0),
                                  elevation: 2.0,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: TestReportStepWidget(
                                      step: report.steps[index],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              index -= 1 + report.steps.length;

                              result = Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      report.images[index].id,
                                      textAlign: TextAlign.center,
                                    ),
                                    Material(
                                      elevation: 2.0,
                                      child: Image.memory(
                                        report.images[index].image!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return result;
                          },
                          itemCount:
                              report!.steps.length + 1 + report.images.length,
                        ),
                      ),
                      if (report.images.isNotEmpty == true &&
                          report.name?.isNotEmpty == true &&
                          tester.goldenImageWriter !=
                              TestStore.goldenImageWriter)
                        Builder(
                          builder: (BuildContext context) => Center(
                            child: TextButton(
                              onPressed: () => _saveGoldenImages(
                                context,
                                report: report,
                                tester: tester,
                              ),
                              child: Text(
                                translator.translate(
                                  TestTranslations
                                      .atf_button_export_golden_images,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_saving == true) ...[
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
        ),
      ),
    );
  }
}
