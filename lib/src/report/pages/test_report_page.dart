import 'package:automated_testing_framework/automated_testing_framework.dart';

import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Page that can display a full test report.
class TestReportPage extends StatelessWidget {
  TestReportPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var report = ModalRoute.of(context).settings.arguments as TestReport;
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
              if (tester.currentTest?.steps?.isNotEmpty == true)
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () async {
                    await tester.execute(
                      name: tester.currentTest.name,
                      reset: true,
                      skipScreenshots: false,
                      steps: tester.currentTest.steps,
                      submitReport: false,
                      version: tester.currentTest.version,
                    );
                  },
                  tooltip:
                      translator.translate(TestTranslations.atf_button_rerun),
                ),
            ],
            title: Text('${report.name ?? unknown} (${report.version ?? 0})'),
          ),
          body: SafeArea(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                Widget result;
                if (index == 0) {
                  if (report.runtimeException?.isNotEmpty == true) {
                    result = Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.warning,
                            size: 64.0,
                            color: Theme.of(context).textTheme.bodyText2.color,
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            report.runtimeException,
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
                                  value: report.passedSteps.toDouble() /
                                      report.steps.length,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.green),
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
                                              text: '${report.passedSteps}',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 32.0,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' / ${report.steps.length}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
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
                        ],
                      ),
                    );
                  }
                } else if (index - 1 < report.steps.length) {
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
                    child: Material(
                      elevation: 2.0,
                      child: Image.memory(
                        report.images[index].image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }
                return result;
              },
              itemCount: report.steps.length + 1 + (report.images?.length ?? 0),
            ),
          ),
        ),
      ),
    );
  }
}
