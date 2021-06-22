import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

class TestSuiteResultWidget extends StatefulWidget {
  TestSuiteResultWidget({
    Key? key,
    required this.result,
  }) : super(key: key);

  final TestSuiteResult result;

  @override
  _TestSuiteResultWidgetState createState() => _TestSuiteResultWidgetState();
}

class _TestSuiteResultWidgetState extends State<TestSuiteResultWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        elevation: 2.0,
        child: InkWell(
          onTap: widget.result.steps.isNotEmpty == true
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    widget.result.success == true
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.result.name} (${widget.result.version})',
                            style: theme.textTheme.bodyText2!.copyWith(
                              fontSize: 18.0,
                            ),
                          ),
                          if (widget.result.suiteName?.isNotEmpty == true) ...[
                            Text(
                              widget.result.suiteName!,
                              style: theme.textTheme.subtitle2!.copyWith(
                                color: theme.textTheme.subtitle2!.color!
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '+${widget.result.numStepsPassed}',
                            style: TextStyle(color: Colors.green),
                          ),
                          TextSpan(
                            text: ' | ',
                            style: theme.textTheme.bodyText2!.copyWith(
                              fontFamily: 'Courier New',
                              fontFamilyFallback: ['monospace', 'Courier'],
                            ),
                          ),
                          TextSpan(
                            text: (widget.result.numStepsPassed -
                                    widget.result.numStepsTotal)
                                .toString(),
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_expanded == true) ...[
                  for (var step in widget.result.steps) ...[
                    Divider(),
                    TestReportStepWidget(
                      step: step,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
