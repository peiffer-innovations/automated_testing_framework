import 'package:automated_testing_framework/automated_testing_framework.dart';

import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Page that can display a summarized result from a test suite run.
class TestSuiteReportPage extends StatelessWidget {
  TestSuiteReportPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var report = ModalRoute.of(context).settings.arguments as TestSuiteReport;
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    var translator = Translator.of(context);
    var title = translator.translate(TestTranslations.atf_test_suite_results);
    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: SafeArea(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                Widget result;
                if (index == 0) {
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
                                value: report.numTestsPassed.toDouble() /
                                    report.results.length,
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
                                            text: '${report.numTestsPassed}',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 32.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' / ${report.results.length}',
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
                } else {
                  index--;
                  result = TestSuiteResultWidget(
                    result: report.results[index],
                  );
                }
                return result;
              },
              itemCount: report.results.length + 1,
            ),
          ),
        ),
      ),
    );
  }
}
