import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

/// Step that attempts to execute a Back action against the current navigation
/// stack.
class GoBackStep extends TestRunnerStep {
  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  /// }
  /// ```
  static GoBackStep fromDynamic(dynamic map) {
    GoBackStep result;

    if (map != null) {
      result = GoBackStep();
    }

    return result;
  }

  /// Attempts to go back by finding the Flutter built in back button and
  /// tapping it.
  @override
  Future<void> execute({
    @required CancelToken cancelToken,
    @required TestReport report,
    @required TestController tester,
  }) async {
    log(
      'go_back',
      tester: tester,
    );

    var backButton = find.byTooltip('Back');
    if (backButton.evaluate().isEmpty == true) {
      backButton = find.byType(CupertinoNavigationBarBackButton);

      if (backButton.evaluate().isEmpty == true) {
        throw Exception('Unable to locate Back button.');
      }
    }

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }

    await driver.tap(backButton);
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {};
}
