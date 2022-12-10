import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_class/json_class.dart';

/// Widget for rendering a test step from a test report.
class TestReportStepWidget extends StatelessWidget {
  TestReportStepWidget({
    Key? key,
    required this.step,
  }) : super(key: key);

  final TestReportStep step;

  Widget _buildStepDetail({
    required BuildContext context,
    required TestReportStep step,
    required ThemeData theme,
  }) {
    Widget? result;

    final values = JsonClass.removeNull(step.step);
    if (values is Map && values.isNotEmpty == true) {
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var entry in values.entries)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: entry.key,
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: ': ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: entry.value?.toString() ?? '<null>',
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontFamily: 'Courier New',
                      fontFamilyFallback: ['monospace', 'Courier'],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return result ?? const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        step.error?.isNotEmpty == true
            ? const Icon(
                Icons.clear,
                color: Colors.red,
              )
            : const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      step.id,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    NumberFormat('#,##0ms').format(
                      step.endTime!.millisecondsSinceEpoch -
                          step.startTime.millisecondsSinceEpoch,
                    ),
                  ),
                ],
              ),
              _buildStepDetail(
                context: context,
                step: step,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
