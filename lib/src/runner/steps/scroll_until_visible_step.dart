import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as test;
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class ScrollUntilVisibleStep extends TestRunnerStep {
  ScrollUntilVisibleStep({
    @required this.increment,
    this.scrollableId,
    @required this.testableId,
    this.timeout,
  })  : assert(increment != null),
        assert(increment != 0),
        assert(testableId?.isNotEmpty == true);

  final double increment;
  final String scrollableId;
  final Duration timeout;
  final String testableId;

  static ScrollUntilVisibleStep fromDynamic(dynamic map) {
    ScrollUntilVisibleStep result;

    if (map != null) {
      result = ScrollUntilVisibleStep(
        increment: JsonClass.parseDouble(map['increment']),
        scrollableId: map['scrollableId'],
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    var name = "scrollUntilVisible('$testableId', '$scrollableId')";
    var timeout = this.timeout ?? tester.delays.defaultTimeout;
    log(
      name,
      tester: tester,
    );

    test.Finder finder;

    if (scrollableId == null) {
      finder = find.byType(Scrollable);
    } else {
      finder = find.descendant(
        of: await waitFor(
          scrollableId,
          tester: tester,
        ),
        matching: find.byType(Scrollable),
      );
    }

    dynamic widget;
    try {
      widget = finder.evaluate().first.widget;
    } catch (e) {
      // no-op
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

    var controller = widget?.controller;
    var scroller = (int count) async {
      await controller.animateTo(
        count * increment,
        duration: tester.delays.scrollIncrement,
        curve: Curves.ease,
      );
    };

    if (controller == null || controller is! ScrollController) {
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

      scroller = (int count) async {
        await driver.drag(finder, offset);
      };

      // throw Exception(
      //   'ScrollKey: $scrollableId -- No controller on child Scrollable; cannot scroll.',
      // );
    }
    var start = DateTime.now().millisecondsSinceEpoch;
    var end = start + timeout.inMilliseconds;

    var widgetFinder = find.byKey(Key(testableId));
    var count = 0;
    var found = widgetFinder.evaluate()?.isNotEmpty == true;
    while (found != true && DateTime.now().millisecondsSinceEpoch < end) {
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
      await waitFor(
        testableId,
        tester: tester,
      );

      var widgetFinder = find
          .descendant(
            of: find.byKey(Key(testableId)),
            matching: find.byType(Stack),
          )
          .evaluate();

      GlobalKey globalKey = widgetFinder.first.widget.key;

      await Scrollable.ensureVisible(globalKey.currentContext);
    } else {
      throw Exception(
        'testableId: [$testableId] -- time out trying to scroll widget to visible.',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'increment': increment,
        'scrollableId': scrollableId,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
