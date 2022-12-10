import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:static_translations/static_translations.dart';

/// Page that can display a summarized result from a test suite run.
class TestSuiteReportPage extends StatefulWidget {
  TestSuiteReportPage({
    Key? key,
  })  : timestamp = DateTime.now(),
        super(key: key);

  final DateTime timestamp;

  @override
  _TestSuiteReportPageState createState() => _TestSuiteReportPageState();
}

class _TestSuiteReportPageState extends State<TestSuiteReportPage>
    with ResetNavigationStateMixin {
  @override
  Widget build(BuildContext context) {
    final report =
        ModalRoute.of(context)!.settings.arguments as TestSuiteReport?;
    final theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    final translator = Translator.of(context);
    final title = translator.translate(TestTranslations.atf_test_suite_results);
    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text('$title (${report!.deviceInfo?.buildNumber})'),
          ),
          body: SafeArea(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                Widget result;
                if (index == 0) {
                  result = Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 16.0),
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
                                    const AlwaysStoppedAnimation(Colors.green),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 160.0,
                              width: 160.0,
                              child: report.success == true
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 120.0,
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${report.numTestsPassed}',
                                            style: const TextStyle(
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
                                                  .bodyMedium!
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Material(
                          borderRadius: BorderRadius.circular(16.0),
                          elevation: 2.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              DateFormat("M/d '@' h:mmaa").format(
                                widget.timestamp,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  );
                } else {
                  index--;
                  result = TestSuiteResultWidget(
                    result: report.results[index]!,
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
