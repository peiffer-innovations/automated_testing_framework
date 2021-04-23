import 'dart:async';
import 'dart:math';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../../flutter_test/flutter_test.dart' as test;
import '../overrides/override_widget_tester.dart';

/// Abstract step that all other test steps must extend.
@immutable
abstract class TestRunnerStep extends JsonClass {
  static final Logger _logger = Logger('TestRunnerStep');

  static final OverrideWidgetTester _driver =
      OverrideWidgetTester(WidgetsBinding.instance!);

  /// Returns the function to call when logging is required
  static void _console(Object? message, [Level level = Level.INFO]) =>
      _logger.log(level, message);

  /// Returns the default timeout for the step.  Steps that should respond
  /// quickly should use a relatively low value and steps that may take a long
  /// time should return an appropriately longer time.  Defaults [null] which
  ///
  Duration get defaultStepTimeout => Duration(minutes: 1);

  /// Returns the test driver that can be used to interact with widgets.
  OverrideWidgetTester get driver => _driver;

  /// Returns the finder that can be used to locate widgets.
  test.CommonFinders get find => test.find;

  /// Function that is called when the step needs to execute.
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  });

  /// Logs a message and posts it as a status update to the [TestRunner].
  @protected
  void log(
    String message, {
    required TestController tester,
  }) {
    _console(message);
    tester.status = message;
  }

  /// Gives the test step an opportunity to sleep after the step has been
  /// executed.  Steps that do not interact with the application may choose to
  /// override this and reduce or elimate the delay.
  Future<void> postStepSleep(Duration duration) async =>
      await Future.delayed(duration);

  /// Gives the test step an opportunity to sleep before the step has been
  /// executed.  Steps that do not interact with the application may choose to
  /// override this and reduce or elimate the delay.
  Future<void> preStepSleep(Duration duration) async =>
      await Future.delayed(duration);

  /// Sleeps for the defined [Duration].  This accept an optional [cancelStream]
  /// which can be used to cancel the sleep.  The [error] flag informs the
  /// sleeper about whether the duration is a standard duration or an error
  /// based timeout.
  ///
  /// The optional [message] can be used to provide more details to the sleep
  /// step.
  @protected
  Future<void> sleep(
    Duration duration, {
    required Stream<void>? cancelStream,
    bool error = false,
    String? message,
    required TestController tester,
  }) async {
    if (duration.inMilliseconds > 0) {
      // Let's reduce the number of log entries to 1 per 100ms or 10 per second.
      var calcSteps = duration.inMilliseconds / 100;

      // However, let's put sanity limits.  At lest 10 events and no more than
      // 50.
      var steps = max(5, min(50, calcSteps)).toInt();

      tester.sleep = ProgressValue(max: steps, value: 0);
      var sleepMillis = duration.inMilliseconds ~/ steps;
      var canceled = false;

      var cancelListener = cancelStream?.listen((_) {
        canceled = true;
      });
      try {
        String buildString(int count) {
          var str = '[';
          for (var i = 0; i < count; i++) {
            str += String.fromCharCode(0x2588);
          }
          for (var i = count; i < steps; i++) {
            str += '_';
          }

          str += ']';
          return str;
        }

        if (message?.isNotEmpty == true) {
          _console(message, Level.FINEST);
        } else {
          _console(
            'Sleeping for ${duration.inMilliseconds} millis...',
            Level.FINEST,
          );
        }

        for (var i = 0; i < steps; i++) {
          _console(buildString(i), Level.FINEST);
          tester.sleep = ProgressValue(
            error: error,
            max: steps,
            value: i,
          );
          await Future.delayed(Duration(milliseconds: sleepMillis));

          if (canceled == true) {
            break;
          }
        }
        _console(buildString(steps), Level.FINEST);
      } finally {
        tester.sleep = ProgressValue(
          error: error,
          max: steps,
          value: steps,
        );
        await Future.delayed(Duration(milliseconds: 100));
        tester.sleep = null;
        await cancelListener?.cancel();
      }
    }
  }

  /// Waits for a widget with a key that has [testableId] as the value.
  @protected
  Future<test.Finder> waitFor(
    dynamic testableId, {
    required CancelToken cancelToken,
    required TestController tester,
    Duration? timeout,
  }) async {
    timeout ??= tester.delays.defaultTimeout;

    var controller = StreamController<void>.broadcast();
    var name = "waitFor('$testableId')";
    try {
      var waiter = () async {
        var end =
            DateTime.now().millisecondsSinceEpoch + timeout!.inMilliseconds;
        test.Finder? finder;
        var found = false;
        while (found != true && DateTime.now().millisecondsSinceEpoch < end) {
          try {
            finder = test.find.byKey(ValueKey<String?>(testableId));
            finder.evaluate().first;
            found = true;
          } catch (e) {
            if (cancelToken.cancelled == true) {
              throw Exception('[CANCELLED]: step was cancelled by the test');
            }

            await Future.delayed(Duration(milliseconds: 100));
          }
        }

        if (found != true) {
          throw Exception('testableId: [$testableId] -- Timeout exceeded.');
        }
        return finder!;
      };

      var sleeper = sleep(
        timeout,
        cancelStream: controller.stream,
        error: true,
        message: '[$name]: ${timeout.inSeconds} seconds',
        tester: tester,
      );

      var result = await waiter();
      if (cancelToken.cancelled == true) {
        throw Exception('[CANCELLED]: step was cancelled by the test');
      }

      controller.add(null);
      await sleeper;
      if (cancelToken.cancelled == true) {
        throw Exception('[CANCELLED]: step was cancelled by the test');
      }

      try {
        var finder = result.evaluate().first;
        if (finder.widget is Testable) {
          var element = finder as StatefulElement;
          var state = element.state;
          if (state is TestableState) {
            _console('flash: [$testableId]', Level.FINEST);
            await state.flash();
            _console('flash complete: [$testableId]', Level.FINEST);
          }
        }
      } catch (e) {
        // no-op
      }

      return result;
    } catch (e) {
      log(
        'ERROR: [$name] -- $e',
        tester: tester,
      );
      rethrow;
    } finally {
      await controller.close();
    }
  }
}
