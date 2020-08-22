import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class TestRunnerThemeData {
  const TestRunnerThemeData({
    this.runnerOverlayColor = Colors.black26,
    this.showRunnerStatus = kReleaseMode != true,
    this.showStepText = false,
    this.statusAlignment = TestStatusAlignment.bottom,
    this.statusBackgroundColor = Colors.black45,
    this.statusErrorColor = Colors.red,
    this.statusOpacity = 0.4,
    this.statusProgressColor = Colors.black,
    this.statusSuccessColor = Colors.green,
    this.statusTextColor = Colors.white,
  })  : assert(runnerOverlayColor != null),
        assert(showRunnerStatus != null),
        assert(showStepText != null),
        assert(statusAlignment != null),
        assert(statusBackgroundColor != null),
        assert(statusErrorColor != null),
        assert(statusOpacity != null),
        assert(statusOpacity >= 0.0 && statusOpacity <= 1.0),
        assert(statusProgressColor != null),
        assert(statusSuccessColor != null),
        assert(statusTextColor != null);

  factory TestRunnerThemeData.dark({
    Color runnerOverlayColor = Colors.white24,
    bool showRunnerStatus = kReleaseMode != true,
    bool showStepText = false,
    TestStatusAlignment statusAlignment = TestStatusAlignment.bottom,
    Color statusBackgroundColor = Colors.white54,
    Color statusErrorColor = const Color(0xFFE57373),
    double statusOpacity = 0.4,
    Color statusProgressColor = Colors.white,
    Color statusSuccessColor = const Color(0xFF81C784),
    Color statusTextColor = Colors.black,
  }) =>
      TestRunnerThemeData(
        runnerOverlayColor: runnerOverlayColor,
        showRunnerStatus: showRunnerStatus,
        showStepText: showStepText,
        statusAlignment: statusAlignment,
        statusBackgroundColor: statusBackgroundColor,
        statusErrorColor: statusErrorColor,
        statusOpacity: statusOpacity,
        statusProgressColor: statusProgressColor,
        statusSuccessColor: statusSuccessColor,
        statusTextColor: statusTextColor,
      );

  final Color runnerOverlayColor;
  final bool showRunnerStatus;
  final bool showStepText;
  final TestStatusAlignment statusAlignment;
  final Color statusBackgroundColor;
  final Color statusErrorColor;
  final double statusOpacity;
  final Color statusProgressColor;
  final Color statusSuccessColor;
  final Color statusTextColor;
}

enum TestStatusAlignment {
  bottom,
  bottomSafe,
  center,
  none,
  top,
  topSafe,
}
