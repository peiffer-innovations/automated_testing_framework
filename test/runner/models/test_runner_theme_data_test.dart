import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TestRunnerThemeData', () {
    var data = TestRunnerThemeData(
      runnerOverlayColor: Color(0xff111111),
      showRunnerStatus: true,
      showStepText: true,
      statusAlignment: TestStatusAlignment.bottom,
      statusBackgroundColor: Color(0xff222222),
      statusErrorColor: Color(0xff333333),
      statusOpacity: 0.5,
      statusProgressColor: Color(0xff444444),
      statusSuccessColor: Color(0xff555555),
      statusTextColor: Color(0xff666666),
    );

    var encoded = data.toJson();
    var decoded = TestRunnerThemeData.fromDynamic(encoded);

    expect(encoded, {
      'runnerOverlayColor': '#ff111111',
      'showRunnerStatus': true,
      'showStepText': true,
      'statusAlignment': 'bottom',
      'statusBackgroundColor': '#ff222222',
      'statusErrorColor': '#ff333333',
      'statusOpacity': 0.5,
      'statusProgressColor': '#ff444444',
      'statusSuccessColor': '#ff555555',
      'statusTextColor': '#ff666666',
    });

    expect(decoded, data);
  });
}
