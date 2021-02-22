import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

import '../../flutter_test/flutter_test.dart' as test;

/// Step that will attempt to scroll another widget until it becomes visible.
class ScrollUntilVisibleStep extends TestRunnerStep {
  ScrollUntilVisibleStep({
    @required this.increment,
    this.scrollableId,
    @required this.testableId,
    this.timeout,
  }) : assert(testableId?.isNotEmpty == true);

  /// The increment in device-independent-pixels.  This may be a positive or
  /// negative number.  Positive to scroll "forward" and negative to scroll
  /// "backward".
  final String increment;

  /// The id of the [Scrollable] widget to perform the scrolling actions on.
  final String scrollableId;

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration timeout;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "increment": <number>,
  ///   "scrollableId": <String>,
  ///   "testableId": <String>,
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDouble]
  /// * [JsonClass.parseDurationFromSeconds]
  static ScrollUntilVisibleStep fromDynamic(dynamic map) {
    ScrollUntilVisibleStep result;

    if (map != null) {
      result = ScrollUntilVisibleStep(
        increment: map['increment'],
        scrollableId: map['scrollableId'],
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Executes the test step.  If the [scrollableId] is set then this will get
  /// that [Scrollable] instance and interact with it.  Otherwise, this will
  /// attempt to find the first [Scrollable] instance currently in the viewport
  /// and interact with that.
  ///
  /// For the most part, pages with a single [Scrollable] will work fine with
  /// omitting the [scrollableId].  However pages with multiple [Scrollables]
  /// (like a Netflix style stacked carousel) will require the [scrollableId] to
  /// be set in order to be able to find and interact with the inner
  /// [Scrollable] instances.
  ///
  /// The [timeout] defines how much time is allowed to pass while attempting to
  /// scroll and find the [Testable] identified by [testableId].
  @override
  Future<void> execute({
    @required CancelToken cancelToken,
    @required TestReport report,
    @required TestController tester,
  }) async {
    var increment =
        JsonClass.parseDouble(tester.resolveVariable(this.increment)) ?? 200;
    String scrollableId = tester.resolveVariable(this.scrollableId);
    String testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    var name =
        "scroll_until_visible('$testableId', '$scrollableId', '$increment')";
    var timeout = this.timeout ?? tester.delays.defaultTimeout;
    log(
      name,
      tester: tester,
    );

    test.Finder finder;

    if (scrollableId == null) {
      try {
        finder = find.byType(Scrollable)?.first;
      } catch (e) {
        // no-op, will be handled later
      }
    } else {
      finder = find
          .descendant(
            of: await waitFor(
              scrollableId,
              cancelToken: cancelToken,
              tester: tester,
            ),
            matching: find.byType(Scrollable),
          )
          ?.first;
    }

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }
    dynamic widget;
    try {
      widget = finder.evaluate().first.widget;
    } catch (e) {
      // no-op
    }
    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }

    if (widget == null) {
      throw Exception(
          'ScrollableId: $scrollableId -- Scrollable could not be found.');
    }

    Scrollable scrollable;
    if (widget is Scrollable) {
      scrollable = widget;
    } else {
      throw Exception(
          'ScrollableId: $scrollableId -- Widget is not a Scrollable.');
    }

    Offset offset;
    switch (scrollable.axisDirection) {
      case AxisDirection.down:
        offset = Offset(0.0, -1.0 * increment);
        break;
      case AxisDirection.left:
        offset = Offset(increment, 0.0);
        break;
      case AxisDirection.right:
        offset = Offset(-1.0 * increment, 0.0);
        break;
      case AxisDirection.up:
        offset = Offset(0.0, increment);
        break;
    }

    var scroller = (int count) async {
      await driver.drag(finder, offset);
    };

    var start = DateTime.now().millisecondsSinceEpoch;
    var end = start + timeout.inMilliseconds;

    var widgetFinder = find.byKey(Key(testableId));
    var count = 0;
    var found = widgetFinder.evaluate()?.isNotEmpty == true;
    while (found != true && DateTime.now().millisecondsSinceEpoch < end) {
      if (cancelToken.cancelled == true) {
        throw Exception('[CANCELLED]: step was cancelled by the test');
      }

      var diff = end - DateTime.now().millisecondsSinceEpoch;
      tester.sleep = ProgressValue(
        error: true,
        max: 100,
        value: ((1 - (diff / timeout.inMilliseconds)) * 100).toInt(),
      );

      await scroller(count);

      diff = end - DateTime.now().millisecondsSinceEpoch;
      tester.sleep = ProgressValue(
        error: true,
        max: 100,
        value: ((1 - (diff / timeout.inMilliseconds)) *
                tester.delays.scrollIncrement.inMilliseconds)
            .toInt(),
      );
      await Future.delayed(tester.delays.scrollIncrement);
      if (cancelToken.cancelled == true) {
        throw Exception('[CANCELLED]: step was cancelled by the test');
      }

      var widgetFinder = find.byKey(Key(testableId)).evaluate();

      count++;
      found = widgetFinder?.isNotEmpty == true;

      diff = end - DateTime.now().millisecondsSinceEpoch;
      tester.sleep = ProgressValue(
        error: true,
        max: 100,
        value: ((1 - (diff / timeout.inMilliseconds)) * 100).toInt(),
      );
    }
    tester.sleep = null;

    if (found == true) {
      var testableFinder = await waitFor(
        testableId,
        cancelToken: cancelToken,
        tester: tester,
      );

      var widgetFinder = find
          .descendant(
            of: testableFinder,
            matching: find.byType(Stack),
          )
          .evaluate();

      GlobalKey globalKey = widgetFinder.first.widget.key;
      if (cancelToken.cancelled == true) {
        throw Exception('[CANCELLED]: step was cancelled by the test');
      }

      await Scrollable.ensureVisible(globalKey.currentContext);
    } else {
      throw Exception(
        'testableId: [$testableId] -- time out trying to scroll widget to visible.',
      );
    }
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'increment': increment,
        'scrollableId': scrollableId,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
