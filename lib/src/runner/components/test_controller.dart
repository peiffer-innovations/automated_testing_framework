import 'dart:async';
import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

/// This represents the meat of the overall automated test framework.  Through
/// this controller, tests get loaded, saved, executed, and reported on.
class TestController {
  TestController({
    this.delays = const TestStepDelays(),
    this.maxCommonSearchDepth = 3,
    @required GlobalKey<NavigatorState> navigatorKey,
    @required this.onReset,
    @required TestStepRegistry registry,
    TestReader testReader = TestStore.testReader,
    TestReporter testReporter = TestStore.testReporter,
    TestWriter testWriter = TestStore.testWriter,
  })  : assert(maxCommonSearchDepth != null),
        assert(maxCommonSearchDepth >= 0),
        assert(navigatorKey != null),
        assert(onReset != null),
        assert(registry != null),
        assert(testReader != null),
        assert(testReporter != null),
        assert(testWriter != null),
        _navigatorKey = navigatorKey,
        _registry = registry,
        _testReader = testReader,
        _testReporter = testReporter,
        _testWriter = testWriter;

  static final Logger _logger = Logger('TestController');

  /// The delays that tests should wait for.
  final TestStepDelays delays;

  /// Defines how far down a widget tree a [Testable] widget should look for a
  /// supported widget for the purposes of getting or setting values and errors.
  final int maxCommonSearchDepth;

  /// Callback function that the application must register with the controller
  /// so that when a reset is requested by a test, the application properly
  /// resets to the initial state.
  final AsyncCallback onReset;

  final GlobalKey<NavigatorState> _navigatorKey;
  final TestStepRegistry _registry;
  final StreamController<CaptureContext> _screencapController =
      StreamController<CaptureContext>.broadcast();
  final StreamController<ProgressValue> _sleepController =
      StreamController<ProgressValue>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<ProgressValue> _stepController =
      StreamController<ProgressValue>.broadcast();
  final TestReader _testReader;
  final TestReporter _testReporter;
  final TestWriter _testWriter;

  /// The device pixel ratio to use when taking screencaptures.
  double devicePixelRatio = 4.0;

  Test _currentTest = Test();

  /// Returns the current from the controller.  This will never be [null].
  Test get currentTest => _currentTest;

  /// Returns the stream that will fire screep capture requests on.
  Stream<CaptureContext> get screencapStream => _screencapController.stream;

  /// Returns the stream that will fire updates as a test is sleeping / waiting.
  Stream<ProgressValue> get sleepStream => _sleepController.stream;

  /// Returns the stream that will fire updates when a test status changes.
  Stream<String> get statusStream => _statusController.stream;

  /// Returns the stream that will fire updates when a test moves from step to
  /// step.
  Stream<ProgressValue> get stepStream => _stepController.stream;

  /// Sets the current test.  If the given test is [null] then a blank test will
  /// be set instead.
  set currentTest(Test test) => _currentTest = test ?? Test();

  /// Informs the controller that a sleep status update has happened.
  set sleep(ProgressValue value) => _sleepController?.add(value);

  /// Informs the controller that a test status update has happened.
  set status(String value) => _statusController?.add(value);

  /// Informs the controller that a test step update has happened.
  set step(ProgressValue value) => _stepController?.add(value);

  /// Disposes the controller.
  void dispose() {
    _screencapController?.close();
    _sleepController?.close();
    _statusController?.close();
    _stepController?.close();
  }

  /// Returns the [TestController] provided by the widget tree.  This will never
  /// throw an exception but may return [null] if no controller is available on
  /// the widget tree.
  static TestController of(BuildContext context) {
    TestController result;

    try {
      var runner = TestRunner.of(context);
      result = runner?.controller;
      result?.devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    } catch (e) {
      // no-op
    }

    return result;
  }

  /// Executes a series of tests steps.  This accepts the [name] of the test
  /// which may be [null] or empty.  The [reset] defines if the controller
  /// should ask the application to perform a full reset before running or if it
  /// should attempt to run for the current state.
  ///
  /// The list of [steps] may not be [null] or empty and define the steps that
  /// the controller should execute.
  ///
  /// The [submitReport] value determines if the [testReporter] should be
  /// executed after all steps have been completed or not.  Generally this value
  /// will be [true] when running full tests and [false] when running debugging
  /// level tests.
  ///
  /// The [version] defines the overall test version.  This may be [null] or
  /// empty and should always be a value of 0 or higher when set.
  Future<void> execute({
    String name,
    bool reset = true,
    @required List<TestStep> steps,
    bool submitReport = true,
    int version,
  }) async {
    step = ProgressValue(max: steps.length, value: 0);

    if (reset == true) {
      await this.reset();
    }

    status = '<set up>';
    await Future.delayed(Duration(milliseconds: 100));

    TestReport testReport;
    if (reset == true || submitReport == true) {
      testReport = TestReport(
        name: name,
        version: version,
      );
    }
    try {
      var idx = 0;
      for (var step in steps) {
        var driverStep = _registry.getRunnerStep(
          id: step.id,
          values: step.values,
        );

        if (delays.preStep.inMilliseconds > 0) {
          await Future.delayed(delays.preStep);
        }

        testReport?.startStep(
          id: step.id,
          step: driverStep.toJson(),
        );
        String error;

        try {
          await driverStep.execute(
            report: testReport,
            tester: this,
          );
        } catch (e) {
          error = '$e';
        } finally {
          testReport?.endStep(error);
        }

        if (delays.preStep.inMilliseconds > 0) {
          await Future.delayed(delays.postStep);
        }

        idx++;
        this.step = ProgressValue(max: steps.length, value: idx);
      }
    } catch (e, stack) {
      testReport?.endStep('Runtime Error: $e');
      testReport?.exception('Exception in test', e, stack);
      _logger.severe('EXCEPTION IN TEST: ', e, stack);
    } finally {
      await _sleep(delays.testTearDown);
      step = null;
      testReport?.complete();

      if (testReport != null) {
        var futures = <Future>[];
        futures.add(
          _navigatorKey.currentState.push(
            MaterialPageRoute(
              builder: (BuildContext context) => TestReportPage(
                report: testReport,
              ),
            ),
          ),
        );
        if (submitReport == true) {
          futures.add(this.submitReport(testReport));
          await _sleep(delays.postSubmitReport);
          await this.reset();
        }

        await Future.wait(futures);
      }
    }
  }

  /// Attempts to export the current test via the [testWriter] value.  This will
  /// return [true] if and only if the current [testWriter] both returns [true]
  /// and no exceptions were thrown along the way.
  ///
  /// If there is no name for the current test, this will prompt for a name to
  /// submit with.  Should the user cancel that name, this will abort, not call
  /// the [testWriter] and return a value of [false].
  ///
  /// The [clear] value instructs the controller to clear the current test on a
  /// successful export or not.
  Future<bool> exportCurrentTest({
    bool clear = true,
    @required BuildContext context,
  }) async {
    var save = true;
    var exported = false;
    var theme = Theme.of(context);
    if (currentTest.name?.isNotEmpty != true) {
      var translator = Translator.of(context);

      var name = '';
      name = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => Theme(
          data: theme,
          child: AlertDialog(
            actions: [
              FlatButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  translator.translate(TestTranslations.atf_button_cancel),
                ),
              ),
              RaisedButton(
                onPressed: () => Navigator.of(context).pop(name),
                child: Text(
                  translator.translate(TestTranslations.atf_button_submit),
                ),
              ),
            ],
            content: TextFormField(
              decoration: InputDecoration(
                labelText: translator.translate(TestTranslations.atf_test_name),
              ),
              onChanged: (value) => name = value,
              validator: (value) =>
                  Validator(validators: [RequiredValidator()]).validate(
                context: context,
                label: translator.translate(TestTranslations.atf_test_name),
                value: value,
              ),
            ),
            title: Text(translator.translate(TestTranslations.atf_test_name)),
          ),
        ),
      );

      if (name?.isNotEmpty == true) {
        save = true;
        currentTest = currentTest.copyWith(name: name);
      } else {
        save = false;
      }
    }

    if (save == true) {
      exported = await _testWriter(context, currentTest);

      if (exported == true && clear == true) {
        currentTest = Test();
      }
    }

    return exported;
  }

  Future<List<Test>> loadTests(BuildContext context) => _testReader(context);

  Future<Uint8List> screencap() async {
    var captureContext = CaptureContext(
      devicePixelRatio: devicePixelRatio,
      image: [],
    );
    status = '<screenshot>';
    try {
      _screencapController.add(captureContext);

      await Future.delayed(Duration(seconds: 3));

      if (captureContext.image?.isNotEmpty != true) {
        captureContext = null;
      }
    } catch (e, stack) {
      _logger.severe(e, stack);
    }

    return captureContext == null
        ? null
        : Uint8List.fromList(captureContext?.image);
  }

  Future<void> reset() async {
    if (onReset != null) {
      await onReset();
    }
    // This covers the minimum animation time for Material animations to
    // complete.  This may or may not be enough time, which is why apps can add
    // to the time using the `testSetUp` value.
    await Future.delayed(Duration(seconds: 1));

    status = '<set up>';
    await _sleep(delays.testSetUp);
  }

  Future<void> runTests(List<Test> tests) async {
    for (var test in tests) {
      try {
        await reset();

        await execute(
          name: test.name,
          reset: false,
          steps: test.steps,
          submitReport: true,
          version: test.version,
        );
      } catch (e, stack) {
        _logger.severe(e, stack);
      }
    }
  }

  Future<bool> submitReport(TestReport report) => _testReporter(report);

  Future<void> _sleep(Duration duration) async =>
      await SleepStep(timeout: duration).execute(tester: this);
}
