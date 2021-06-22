import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/cupertino.dart';

/// Step that attempts to execute a Back action against the current navigation
/// stack.
class GoBackStep extends TestRunnerStep {
  static const id = 'go_back';

  static final List<String> behaviorDrivenDescriptions = List.unmodifiable([
    'go back.',
  ]);

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  /// }
  /// ```
  static GoBackStep? fromDynamic(dynamic map) {
    GoBackStep? result;

    if (map != null) {
      result = GoBackStep();
    }

    return result;
  }

  /// Attempts to go back by finding the Flutter built in back button and
  /// tapping it.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    log(
      '$id',
      tester: tester,
    );

    var backButton = find.byTooltip('Back');
    var evaluated = backButton.evaluate().toList();
    if (evaluated.isEmpty == true) {
      backButton = find.byType(CupertinoNavigationBarBackButton);

      evaluated = backButton.evaluate().toList();
      if (evaluated.isEmpty == true) {
        throw Exception('Unable to locate Back button.');
      }
    }

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }

    if (evaluated.length > 1) {
      var error =
          '[ERROR]: found (${evaluated.length}) widgets; expected only one.';
      var index = 0;
      for (var w in evaluated) {
        error += '\n  ${++index}: ${w.widget.runtimeType} [${w.widget.key}]';
      }
      throw Exception(error);
    }

    await driver.tap(backButton);
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) =>
      behaviorDrivenDescriptions[0];

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {};
}
