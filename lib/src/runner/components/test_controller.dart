import 'dart:async';
import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

const kTestDefaultTimeout = Duration(seconds: 20);

class TestController {
  TestController({
    this.delays = const TestStepDelays(),
    this.maxCommonSearchDepth = 3,
    @required GlobalKey<NavigatorState> navigatorKey,
    @required TestStepRegistry registry,
    TestReader testReader = TestStore.testReader,
    TestReporter testReporter = TestStore.testReporter,
    TestWriter testWriter = TestStore.testWriter,
  })  : assert(maxCommonSearchDepth != null),
        assert(maxCommonSearchDepth >= 0),
        assert(navigatorKey != null),
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

  final TestStepDelays delays;
  final int maxCommonSearchDepth;

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

  double devicePixelRatio = 4.0;
  AsyncCallback onReset;

  Test _currentTest = Test();

  Test get currentTest => _currentTest;
  Stream<CaptureContext> get screencapStream => _screencapController.stream;
  Stream<ProgressValue> get sleepStream => _sleepController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<ProgressValue> get stepStream => _stepController.stream;

  set currentTest(Test test) => _currentTest = test ?? Test();
  set sleep(ProgressValue value) => _sleepController?.add(value);
  set status(String value) => _statusController?.add(value);
  set step(ProgressValue value) => _stepController?.add(value);

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

  bool isReal() => true;

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
