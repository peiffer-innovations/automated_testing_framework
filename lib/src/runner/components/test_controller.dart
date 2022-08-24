import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

/// Controller that allows for the creation, loading, saving, and running of
/// automated tests.
class TestController {
  /// A controller for a [TestRunner] that can create, run, load, and save
  /// automated tests.
  ///
  /// When a new test is about to start, this will fire an event on the
  /// [resetStream].  Applications can listen to those events to reset
  /// themselves to a "known good state".
  ///
  /// The [navigatorKey] is used to allow for the navigation to the
  /// [TestReportsPage].  If passed in, it must be attached to a [MaterialApp]
  /// or [WidgetsApp].
  ///
  /// The [testReportBuilder] allows the overriding of the page to display the
  /// report from a test run.  If omitted, the built in [TestReportPage] will be
  /// used.  If set then the [TestReport] will be passed via the [ModalRoute]'s
  /// arguments.
  ///
  /// The [delays] is used to determina the various wait times and timeouts for
  /// the various test steps.
  ///
  /// The [maxCommonSearchDepth] informs the [Testable] how far it should walk
  /// down the descendant tree to find a widget it knows how to wrap.  To
  /// disable this auto-search for supported widgets, set this value to zero.
  ///
  /// The [registry] is used for finding the both available test steps for
  /// building tests as well as running test steps.  In general, the default
  /// [TestStepRegistry] is sufficient.
  ///
  /// If provided, the [variableResolvers] will be used to resolve all variables
  /// before the default internal resolver will be consulted.
  ///
  /// The [testImageReader] will be used when golden images are requested from a
  /// data store.  The default [testImageReader] is a no-op that will always
  /// return `null` for all image requests.
  ///
  /// This expects a [testReader] to be able to load tests into the platform for
  /// editing and / or execution.  The default [testReader] is a no-op that will
  /// never return any tests.
  ///
  /// A [testWriter] is used to be able to save / export tests that were created
  /// within the application.  The default [testWriter] is a no-op that will
  /// do nothing with the given test.
  ///
  /// Finally, a [testReporter] is used to submit test reports from tests
  /// executed within the application.  The default [testReporter] is a no-op
  /// that will do nothing with any given report.  The [testReportLogLevel]
  /// defines the level to capture in the [TestReport]s that are submitted.
  ///
  /// See also:
  /// * [AssetTestStore]
  /// * [ClipboardTestStore]
  /// * [UnknownVariableException]
  /// * [VariableResolver]
  TestController({
    Map<String, PageRoute>? customRoutes,
    this.delays = const TestStepDelays(),
    this.goldenImageWriter = TestStore.goldenImageWriter,
    this.maxCommonSearchDepth = 3,
    GlobalKey<NavigatorState>? navigatorKey,
    this.onReset,
    this.screenshotOnFail = false,
    this.selectedSuiteName,
    this.stopOnFirstFail = false,
    TestStepRegistry? registry,
    this.testImageReader = TestStore.testImageReader,
    TestReader testReader = TestStore.testReader,
    WidgetBuilder? testReportBuilder,
    Level testReportLogLevel = Level.INFO,
    TestReporter testReporter = TestStore.testReporter,
    WidgetBuilder? testSuiteReportBuilder,
    TestWriter testWriter = TestStore.testWriter,
    List<VariableResolver>? variableResolvers,
    Map<String, dynamic>? variables,
  })  : _navigatorKey = navigatorKey,
        _registry = registry ?? TestStepRegistry.instance,
        _testReader = testReader,
        _testReportBuilder = testReportBuilder,
        _testReportLogLevel = testReportLogLevel,
        _testReporter = testReporter,
        _testSuiteReportBuilder = testSuiteReportBuilder,
        _testWriter = testWriter,
        _variableResolvers = variableResolvers ?? <VariableResolver>[] {
    _customRoutes.addAll(customRoutes ?? {});
    _globalVariables.addAll(variables ?? {});
  }

  static const Duration _kSuiteStartTimeout = Duration(minutes: 2);

  static final Logger _logger = Logger('TestController');

  /// The delays that tests should wait for.
  final TestStepDelays delays;

  /// Writer that saves golden images for a particular device.
  final GoldenImageWriter goldenImageWriter;

  /// Defines how far down a widget tree a [Testable] widget should look for a
  /// supported widget for the purposes of getting or setting values and errors.
  final int maxCommonSearchDepth;

  /// Callback function that the application must register with the controller
  /// so that when a reset is requested by a test, the application properly
  /// resets to the initial state.
  @Deprecated('Deprecated in 3.2.0: listen to the [resetStream] instead')
  final AsyncCallback? onReset;

  /// Defines whether the framework should take a screenshot automatically
  /// whenever a failure is detected or not.
  final bool screenshotOnFail;

  /// Defines whether or not the framework should stop on the first failed step
  /// or keep going and executing subsequent steps.
  final bool stopOnFirstFail;

  /// The image reader to read images for golden image comparisons.
  final TestImageReader testImageReader;

  final StreamController<void> _cancelController =
      StreamController<void>.broadcast();
  final Map<String, PageRoute> _customRoutes = SplayTreeMap();
  final Map<String, dynamic> _globalVariables = {};
  final GlobalKey<NavigatorState>? _navigatorKey;
  final TestStepRegistry _registry;
  final StreamController<void> _resetController =
      StreamController<void>.broadcast();
  final StreamController<CaptureContext> _screencapController =
      StreamController<CaptureContext>.broadcast();
  final StreamController<ProgressValue?> _sleepController =
      StreamController<ProgressValue?>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<ProgressValue?> _stepController =
      StreamController<ProgressValue?>.broadcast();
  final TestControllerState _testControllerState = TestControllerState();
  final TestReader _testReader;
  final WidgetBuilder? _testReportBuilder;
  final Level _testReportLogLevel;
  final TestReporter _testReporter;
  final WidgetBuilder? _testSuiteReportBuilder;
  final Map<String, dynamic> _testVariables = {};
  final TestWriter _testWriter;
  final List<VariableResolver> _variableResolvers;

  /// The currently selected test suite name.
  String? selectedSuiteName;

  Test _currentTest = Test();

  /// Returns the current from the controller.  This will never be `null`.
  Test get currentTest => _currentTest;

  /// Returns the custom routes, sorted by the display name.
  Map<String, PageRoute> get customRoutes => Map.unmodifiable(_customRoutes);

  /// Returns the registry that is being used by the controller.
  TestStepRegistry get registry => _registry;

  /// Returns the stream that receives an event whenever a reset is called.
  Stream<void> get resetStream => _resetController.stream;

  /// Returns whether or not the controller is actively running a test now or
  /// not.
  bool get runningTest =>
      _testControllerState.runningTest == true ||
      _testControllerState.runningSuite == true;

  /// Returns the stream that will fire screep capture requests on.
  Stream<CaptureContext> get screencapStream => _screencapController.stream;

  /// Returns the stream that will fire updates as a test is sleeping / waiting.
  Stream<ProgressValue?> get sleepStream => _sleepController.stream;

  /// Returns the current state for the test controller.
  TestControllerState get state => _testControllerState;

  /// Returns the stream that will fire updates when a test status changes.
  Stream<String> get statusStream => _statusController.stream;

  /// Returns the stream that will fire updates when a test moves from step to
  /// step.
  Stream<ProgressValue?> get stepStream => _stepController.stream;

  /// Returns an unmodifiable map of all the currently set variables.
  Map<String, dynamic> get variables =>
      Map<String, dynamic>.unmodifiable(<String, dynamic>{}
        ..addAll(_globalVariables)
        ..addAll(_testVariables));

  /// Sets the current test.  If the given test is `null` then a blank test will
  /// be set instead.
  set currentTest(Test? test) => _currentTest = test ?? Test();

  /// Informs the controller that a sleep status update has happened.
  set sleep(ProgressValue? value) => _sleepController.add(value);

  /// Informs the controller that a test status update has happened.
  set status(String value) => _statusController.add(value);

  /// Informs the controller that a test step update has happened.
  set step(ProgressValue? value) => _stepController.add(value);

  /// Returns the [TestController] provided by the widget tree.  This will never
  /// throw an exception but may return `null` if no controller is available on
  /// the widget tree.
  static TestController? of(BuildContext context) {
    TestController? result;

    try {
      var runner = TestRunner.of(context);
      result = runner?.controller;
    } catch (e) {
      // no-op
    }

    return result;
  }

  /// Canceles any currently running test.  The current step will be the last to
  /// execute, but this may still take a while as the current second could be a
  /// long running step.
  ///
  /// If no test is currently running, this does nothing.
  Future<void> cancelRunningTests([
    Duration timeout = const Duration(minutes: 5),
  ]) async {
    _cancelController.add(null);

    var startTime = DateTime.now();
    while (_testControllerState.runningTest == true) {
      await Future.delayed(Duration(seconds: 1));
      if (DateTime.now().millisecondsSinceEpoch -
              startTime.millisecondsSinceEpoch >=
          timeout.inMilliseconds) {
        throw Exception(
            '[TIMEOUT]: A timeout has occurred while waiting for the tests to complete.');
      }
    }
  }

  /// Clears all the custom routes.
  void clearCustomRoutes() => _customRoutes.clear();

  /// Clears all the variables.
  @Deprecated('Deprecated in 3.1.0: use [clearGlobalVariables] instead')
  void clearVariables() => clearGlobalVariables();

  /// Clears all the currently set global variables.
  void clearGlobalVariables() => _globalVariables.clear();

  /// Clears all the currently set test variables.
  void clearTestVariables() => _testVariables.clear();

  /// Disposes the controller.  Once disposed, a controller can not be reused.
  void dispose() {
    _cancelController.close();
    _resetController.close();
    _screencapController.close();
    _sleepController.close();
    _statusController.close();
    _stepController.close();
  }

  /// Executes a series of tests steps.  This accepts the [name] of the test
  /// which may be `null` or empty.  The [reset] defines if the controller
  /// should ask the application to perform a full reset before running or if it
  /// should attempt to run for the current state.
  ///
  /// The list of [steps] may not be `null` or empty and define the steps that
  /// the controller should execute.
  ///
  /// The [submitReport] value determines if the [testReporter] should be
  /// executed after all steps have been completed or not.  Generally this value
  /// will be [true] when running full tests and [false] when running debugging
  /// level tests.
  ///
  /// The [version] defines the overall test version.  This may be `null` or
  /// empty and should always be a value of 0 or higher when set.
  Future<TestReport> execute({
    String? name,
    TestReport? report,
    bool reset = true,
    Duration? stepTimeout,
    required List<TestStep> steps,
    bool submitReport = true,
    String? suiteName,
    TestSuiteReport? testSuiteReport,
    Duration? testTimeout,
    required int version,
  }) async {
    if (_testControllerState.runningTest == true) {
      await cancelRunningTests();
    }

    var settings = TestAppSettings.settings;

    stepTimeout ??= settings.stepTimeout;
    testTimeout ??= settings.testTimeout;

    var cancelToken = CancelToken(timeout: testTimeout);
    var cancelSubscription = _cancelController.stream.listen(
      (_) => cancelToken.cancel(),
    );
    _testControllerState.currentTest = name;
    _testControllerState.progress = 0.0;
    _testControllerState.runningTest = true;

    try {
      _testControllerState.passing = true;
      step = ProgressValue(max: steps.length, value: 0);

      if (reset == true) {
        await this.reset();
      }

      status = '<set up>';
      await Future.delayed(Duration(milliseconds: 100));

      report ??= TestReport(
        name: name,
        suiteName: suiteName,
        version: version,
      );
      var logSubscription = Logger.root.onRecord.listen((record) {
        if (_testReportLogLevel <= record.level) {
          report!.appendLog(
            '${record.level.name}: ${record.time}: ${record.message}',
          );
          if (record.error != null) {
            report.appendLog('${record.error}');
          }
          if (record.stackTrace != null) {
            report.appendLog('${record.stackTrace}');
          }
        }
      });

      try {
        setGlobalVariable(
          value: _testControllerState.passing,
          variableName: '_passing',
        );
        var idx = 0;
        for (var step in steps) {
          if (cancelToken.cancelled == true) {
            break;
          }

          Timer? timeoutTimer;
          if (stepTimeout != null) {
            timeoutTimer = Timer(stepTimeout, () => cancelToken.cancel());
          }

          try {
            _testControllerState.passing = await executeStep(
                  cancelToken: cancelToken,
                  report: report,
                  step: step,
                  subStep: false,
                ) &&
                _testControllerState.passing;
          } finally {
            timeoutTimer?.cancel();
          }

          idx++;
          var progress = ProgressValue(max: steps.length, value: idx);
          this.step = progress;
          _testControllerState.progress = progress.progress;

          if (stopOnFirstFail == true && _testControllerState.passing != true) {
            break;
          }
        }
      } catch (e, stack) {
        report.exception('Exception in test', e, stack);
        _logger.severe('EXCEPTION IN TEST: ', e, stack);
      } finally {
        await logSubscription.cancel();

        await _sleep(delays.testTearDown);
        step = null;
        report.complete();
        _testControllerState.runningTest = false;

        if (cancelToken.cancelled == false &&
            (reset == true || submitReport == true)) {
          _testControllerState.runningTest = false;
          testSuiteReport?.addTestReport(report);
          var futures = <Future>[];
          futures.add(
            _navigatorKey?.currentState?.push(
                  MaterialPageRoute(
                    builder: _testReportBuilder ??
                        ((BuildContext context) => TestReportPage()),
                    settings: RouteSettings(
                      name: '/atf/test-report',
                      arguments: report,
                    ),
                  ),
                ) ??
                Future.delayed(
                  const Duration(seconds: 1),
                ),
          );
          if (submitReport == true) {
            futures.add(this.submitReport(report));
            await _sleep(delays.postSubmitReport);
            await this.reset();
          }

          await Future.wait(futures);
        }
      }

      return report;
    } finally {
      await cancelSubscription.cancel();
      await cancelToken.complete();
    }
  }

  /// Executes a single [step] and attaches the execution information to the
  /// [testReport].  The [cancelToken] allows the step to be cancelled.
  /// Whenever a step has a loop or a long running task, it should listen to the
  /// stream from the token or read the flag from the token.
  Future<bool> executeStep({
    required CancelToken cancelToken,
    required TestReport report,
    required TestStep step,
    bool subStep = true,
  }) async {
    var passed = true;
    var runnerStep = _registry.getRunnerStep(
      id: step.id,
      values: step.values,
    )!;

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was canceled by the test');
    }

    if (delays.preStep.inMilliseconds > 0) {
      await runnerStep.preStepSleep(delays.preStep);
    }

    report.startStep(
      step,
      subStep: subStep,
    );
    String? error;
    try {
      if (cancelToken.cancelled == true) {
        throw Exception('[CANCELLED]: step was cancelled by the test');
      }
      _testControllerState.currentStep = step.id;
      await runnerStep.execute(
        cancelToken: cancelToken,
        report: report,
        tester: this,
      );
    } catch (e, stack) {
      if (cancelToken.cancelled == true) {
        rethrow;
      }
      if (screenshotOnFail == true) {
        try {
          var imageNum = report.images.length + 1;
          await ScreenshotStep(
            goldenCompatible: false,
            imageId: 'failure_${step.id}_${imageNum}',
          ).execute(
            cancelToken: cancelToken,
            report: report,
            tester: this,
          );
        } catch (e2, stack2) {
          _logger.severe(
            'Error taking failure screenshot: ${step.id}',
            e2,
            stack2,
          );
        }
      }

      _logger.severe('Error running test step: ${step.id}', e, stack);
      error = '$e';
      passed = false;
    } finally {
      _testControllerState.currentStep = null;
      report.endStep(step, error);
    }

    if (cancelToken.cancelled == true) {
      throw Exception('[CANCELLED]: step was cancelled by the test');
    }
    if (delays.postStep.inMilliseconds > 0) {
      await runnerStep.postStepSleep(delays.preStep);
    }

    return passed;
  }

  /// Executes a single [test].  This will reset the application and submit the
  /// report.  If the [report] is set it will be used, otherwise a net-new
  /// [TestReport] will be created and returned.
  Future<TestReport> executeTest({
    required Test test,
    TestReport? report,
  }) async {
    return await execute(
      name: test.name,
      report: report,
      reset: true,
      steps: test.steps,
      submitReport: true,
      suiteName: test.suiteName,
      version: test.version,
    );
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
    required BuildContext context,
  }) async {
    var save = true;
    var exported = false;
    var theme = Theme.of(context);
    if (currentTest.name?.isNotEmpty != true) {
      var translator = Translator.of(context);

      String? name = '';
      var suiteName = currentTest.suiteName ?? '';
      name = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => Theme(
          data: theme,
          child: AlertDialog(
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  translator.translate(TestTranslations.atf_button_cancel),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(name),
                child: Text(
                  translator.translate(TestTranslations.atf_button_submit),
                ),
              ),
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  autocorrect: false,
                  autofocus: true,
                  autovalidateMode: AutovalidateMode.always,
                  decoration: InputDecoration(
                    labelText: translator.translate(
                      TestTranslations.atf_test_name,
                    ),
                  ),
                  initialValue: name,
                  onChanged: (value) => name = value,
                  validator: (value) =>
                      Validator(validators: [RequiredValidator()]).validate(
                    context: context,
                    label: translator.translate(
                      TestTranslations.atf_test_name,
                    ),
                    value: value,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  autocorrect: false,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: translator.translate(
                      TestTranslations.atf_suite_name,
                    ),
                  ),
                  initialValue: suiteName,
                  onChanged: (value) => suiteName = value,
                ),
              ],
            ),
            title: Text(translator.translate(TestTranslations.atf_test_name)),
          ),
        ),
      );

      if (name?.isNotEmpty == true) {
        save = true;
        currentTest = currentTest.copyWith(
          name: name,
          suiteName: suiteName.isNotEmpty == true ? suiteName : null,
        );
        selectedSuiteName = suiteName;
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

  /// Returns the variable from the controller.  This will first iterate through
  /// each [VariableResolver] given to the controller and will return the value
  /// from the first resolver that did not throw an [UnknownVariableException].
  ///
  /// If there are no resolvers on the controller, or all resolvers throw an
  /// [UnknownVariableException], then this will next check the reserved
  /// variable names and the associated values.
  ///
  /// Finally, if neither check resolves the variable, this will return the
  /// value from the variables map that has been set, and will return `null` if
  /// no value had been set for [variableName].
  dynamic getVariable(String variableName) {
    var resolved = false;
    dynamic result;

    for (var resolver in _variableResolvers) {
      try {
        result = resolver(variableName);
        resolved = true;
      } catch (e) {
        if (e is UnknownVariableException) {
          // no-op
        } else {
          rethrow;
        }
      }
    }

    if (resolved != true) {
      switch (variableName) {
        case '_now':
          result = DateTime.now().toUtc();
          break;
        case '_platform':
          if (kIsWeb) {
            result = 'web';
          } else if (Platform.isAndroid) {
            result = 'android';
          } else if (Platform.isFuchsia) {
            result = 'fuchsia';
          } else if (Platform.isIOS) {
            result = 'ios';
          } else if (Platform.isMacOS) {
            result = 'macos';
          } else if (Platform.isWindows) {
            result = 'windows';
          } else {
            result = 'unknown';
          }
          break;
        default:
          result = _testVariables.containsKey(variableName)
              ? _testVariables[variableName]
              : _globalVariables[variableName];
      }
    }

    return result;
  }

  /// Loads the list of tests from the assigned [TestReader].  This accepts the
  /// [BuildContext] to allow the reader to provide visual feedback to the user
  /// in case the load takes a while.
  Future<List<PendingTest>?> loadTests(
    BuildContext? context, {
    String? suiteName,
  }) =>
      _testReader(
        context,
        suiteName: suiteName,
      );

  /// Registers a custom [route] with the framework.  These routes will be
  /// displayed on the [TestStepsDialog] and [TestStepsPage].  The [display] is
  /// the string to display in a [ListTile]'s title to trigger navigation to the
  /// [route].  If the route is `null`, this will remove any route registered to
  /// the [display].  If the [display] is already registered, it will be
  /// replaced with the new [route]
  void registerCustomRoute(String display, PageRoute? route) => route == null
      ? _customRoutes.remove(display)
      : _customRoutes[display] = route;

  /// Removes the value for [variableName] globally.
  void removeGlobalVariable({required String variableName}) =>
      _globalVariables.remove(variableName);

  /// Removes the value for [variableName] for the current test.
  void removeTestVariable({required String variableName}) =>
      _testVariables.remove(variableName);

  /// Requests the application to perform a reset.
  Future<void> reset() async {
    clearTestVariables();

    _resetController.add(null);

    // ignore: deprecated_member_use_from_same_package
    if (onReset != null) {
      // ignore: deprecated_member_use_from_same_package
      await onReset!();
    }
    // This covers the minimum animation time for Material animations to
    // complete.  This may or may not be enough time, which is why apps can add
    // to the time using the [testSetUp] value.
    await Future.delayed(Duration(seconds: 1));

    status = '<set up>';
    await _sleep(delays.testSetUp);
  }

  /// Resolves the given input with any potential variable on the controller.
  /// Variable values use the mustache format and must begin with `{{` and end
  /// with `}}`.  If the input is not marked as a variable or there is no
  /// variable with the matching key registered then the input will be return
  /// unaltered.
  dynamic resolveVariable(dynamic input) {
    dynamic result = input;
    if (input is String && input.contains('{{') && input.contains('}}')) {
      var regex = RegExp(r'\{\{[^(})]*}}]*');

      var matches = regex.allMatches(input);
      if (matches.isNotEmpty == true) {
        if (matches.length == 1 &&
            input.startsWith('{{') &&
            input.endsWith('}}')) {
          var match = matches.first;
          var variableName =
              result.substring(match.start + 2, match.end - 2).trim();
          var value = getVariable(variableName);
          if (value != null ||
              _testVariables.containsKey(variableName) == true ||
              _globalVariables.containsKey(variableName) == true) {
            result = value;
          }
        } else {
          matches = matches.toList().reversed;

          for (var match in matches) {
            var variableName =
                result.substring(match.start + 2, match.end - 2).trim();

            var value = getVariable(variableName);
            if (value != null ||
                _testVariables.containsKey(variableName) == true ||
                _globalVariables.containsKey(variableName) == true) {
              result = value == null
                  ? null
                  : '${result.substring(0, match.start)}$value${result.substring(match.end, result.length)}';
            }
          }
        }
      }
    }

    return result;
  }

  /// Runs a series of [tests].  For full runs, this is more memory efficient as
  /// it will only load the tests as needed.
  ///
  Future<TestSuiteReport> runPendingTests(
    List<PendingTest> tests, [
    Duration waitTimeout = _kSuiteStartTimeout,
  ]) async {
    var startTime = DateTime.now();
    while (_testControllerState.runningSuite == true) {
      if (DateTime.now().millisecondsSinceEpoch -
              startTime.millisecondsSinceEpoch >=
          waitTimeout.inMilliseconds) {
        throw Exception(
          '[TIMEOUT]: Could not start tests, suite is still running.',
        );
      }
      await Future.delayed(Duration(milliseconds: 100));
    }

    var testSuiteReport = TestSuiteReport();
    _testControllerState.runningSuite = true;
    if (tests.isNotEmpty == true) {
      try {
        for (var pendingTest in tests) {
          if (pendingTest.active == true) {
            try {
              var test = await pendingTest.loader.load(ignoreImages: true);
              await reset();

              await execute(
                name: test.name,
                reset: false,
                steps: test.steps,
                submitReport: true,
                suiteName: test.suiteName,
                testSuiteReport: testSuiteReport,
                version: test.version,
              );
            } catch (e, stack) {
              _logger.severe(e, stack);
            }
          }
        }
      } finally {
        _testControllerState.runningSuite = false;
      }
      await _navigatorKey?.currentState?.push(
        MaterialPageRoute(
          builder: _testSuiteReportBuilder ??
              ((BuildContext context) => TestSuiteReportPage()),
          settings: RouteSettings(
            arguments: testSuiteReport,
          ),
        ),
      );
    }
    return testSuiteReport;
  }

  /// Runs a series of [tests].  This is useful for smaller numbers of in-memory
  /// tests but the [runPendingTests] should be prefered for full application
  /// runs or for CI/CD pipelines as that only loads the bare minimum data up
  /// front and then loads the full test data on an as needed basis.
  Future<TestSuiteReport> runTests(
    List<Test> tests, {
    Duration? stepTimeout,
    Duration waitTimeout = _kSuiteStartTimeout,
  }) async {
    var startTime = DateTime.now();
    while (_testControllerState.runningSuite == true) {
      if (DateTime.now().millisecondsSinceEpoch -
              startTime.millisecondsSinceEpoch >=
          waitTimeout.inMilliseconds) {
        throw Exception(
          '[TIMEOUT]: Could not start tests, suite is still running.',
        );
      }
      await Future.delayed(Duration(milliseconds: 100));
    }

    var testSuiteReport = TestSuiteReport();
    _testControllerState.runningSuite = true;
    if (tests.isNotEmpty == true) {
      try {
        for (var test in tests) {
          try {
            await reset();

            await execute(
              name: test.name,
              reset: false,
              stepTimeout: stepTimeout,
              steps: test.steps,
              submitReport: true,
              suiteName: test.suiteName,
              testSuiteReport: testSuiteReport,
              version: test.version,
            );
          } catch (e, stack) {
            _logger.severe(e, stack);
          }
        }
      } finally {
        _testControllerState.runningSuite = false;
      }
      await _navigatorKey?.currentState?.push(
        MaterialPageRoute(
          builder: _testSuiteReportBuilder ??
              ((BuildContext context) => TestSuiteReportPage()),
          settings: RouteSettings(
            arguments: testSuiteReport,
          ),
        ),
      );
    }

    return testSuiteReport;
  }

  /// Executes a screen capture for the application.  As a note, depending on
  /// the device this may take several seconds.  The screenshot call is fully
  /// async so this will wait until up to [TestStepDelays.screenshot] for the
  /// response.
  ///
  /// This will never trigger a failure, but it will return `null` if the device
  /// does not respond before the timeout.
  Future<Uint8List?> screencap() async {
    Uint8List? image;

    if (!kIsWeb) {
      var captureContext = CaptureContext(
        image: [],
      );
      status = '<screenshot>';
      try {
        _screencapController.add(captureContext);

        var now = DateTime.now().millisecondsSinceEpoch;
        while (captureContext.image.isNotEmpty != true &&
            now + delays.screenshot.inMilliseconds >
                DateTime.now().millisecondsSinceEpoch) {
          await Future.delayed(Duration(milliseconds: 100));
        }
      } catch (e, stack) {
        _logger.severe(e, stack);
      }

      image = captureContext.image.isNotEmpty != true
          ? null
          : Uint8List.fromList(captureContext.image);
    }

    return image;
  }

  /// Sets the variable with the [variableName] to the [value] to be accessible
  /// by all running tests.
  ///
  /// To set a variable so that it clears before the next test begins, use
  /// [setTestVariable].
  void setGlobalVariable({
    required dynamic value,
    required String variableName,
  }) =>
      _globalVariables[variableName] = value;

  /// Sets the variable with the [variableName] to the [value] to be accessible
  /// by the currently running test.
  ///
  /// To set a variable so that it is accessible by all tests, use
  /// [setGlobalVariable].
  void setTestVariable({
    required dynamic value,
    required String variableName,
  }) =>
      _testVariables[variableName] = value;

  /// Submits the test report through the [TestReporter].
  Future<bool> submitReport(TestReport report) => _testReporter(report);

  String toBehaviorDrivenDescription(Test test) {
    var result =
        '## As a test named `${test.name}`${test.suiteName == null ? '' : ' in the `${test.suiteName}` suite'}\n';

    var first = true;
    for (var step in test.steps) {
      var runnerStep = _registry.getRunnerStep(
        id: step.id,
        values: step.values,
      )!;
      result +=
          ' * ${first == true ? 'First,' : 'And then'} I will ${runnerStep.getBehaviorDrivenDescription(this)}\n';
      first = false;
    }

    return result;
  }

  /// Sleeps for the given duration.
  Future<void> _sleep(Duration duration) async =>
      await SleepStep(timeout: duration).execute(tester: this);
}
