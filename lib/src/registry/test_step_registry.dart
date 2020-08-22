import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Registry that allows for the binding of custom test steps.  There exists a
/// default instance that will always be used when a custom instance is not
/// available.
///
/// More often than not, applications will simply want to add the custom steps
/// to the default instance, but if an application needs different steps for
/// different modes of the application, then this provides that capability by
/// allowing an application to register the custom steps to a specific instance
/// and then provide that instance using the [Provider.value].
class TestStepRegistry {
  TestStepRegistry({
    this.debugLabel,
    List<TestStepBuilder> steps,
  }) {
    registerCustomSteps(steps);
    for (var builder in _all) {
      _builtInSteps[builder.id] = builder;
    }
  }

  static final TestStepRegistry instance = TestStepRegistry(
    debugLabel: 'default',
  );

  static final List<TestStepBuilder> _all = [
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: AssertErrorForm(),
        help: TestStepTranslations.atf_help_assert_error,
        id: 'assert_error',
        keys: const {'equals', 'error', 'timeout', 'testableId'},
        quickAddValues: const {'equals': 'true'},
        title: TestStepTranslations.atf_title_assert_error,
        type: TestableType.error_requestable,
        widgetless: false,
      ),
      testRunnerStepBuilder: AssertErrorStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: AssertValueForm(),
        help: TestStepTranslations.atf_help_assert_value,
        id: 'assert_value',
        keys: const {'equals', 'timeout', 'testableId', 'value'},
        quickAddValues: const {'equals': 'true'},
        title: TestStepTranslations.atf_title_assert_value,
        type: TestableType.value_requestable,
        widgetless: false,
      ),
      testRunnerStepBuilder: AssertValueStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: EnsureExistsForm(),
        help: TestStepTranslations.atf_help_ensure_exists,
        id: 'ensure_exists',
        keys: const {'testableId'},
        quickAddValues: const {},
        title: TestStepTranslations.atf_title_ensure_exists,
        widgetless: false,
      ),
      testRunnerStepBuilder: DismissKeyboardStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: DismissKeyboardForm(),
        help: TestStepTranslations.atf_help_dismiss_keyboard,
        id: 'dismiss_keyboard',
        keys: const {'timeout'},
        quickAddValues: const {},
        title: TestStepTranslations.atf_title_dismiss_keyboard,
        widgetless: true,
      ),
      testRunnerStepBuilder: DismissKeyboardStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: GoBackForm(),
        help: TestStepTranslations.atf_help_go_back,
        id: 'go_back',
        quickAddValues: const {},
        title: TestStepTranslations.atf_title_go_back,
        widgetless: true,
      ),
      testRunnerStepBuilder: GoBackStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: ScreenshotForm(),
        help: TestStepTranslations.atf_help_screenshot,
        id: 'screenshot',
        quickAddValues: const {},
        title: TestStepTranslations.atf_title_screenshot,
        widgetless: true,
      ),
      testRunnerStepBuilder: ScreenshotStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: ScrollUntilVisibleForm(),
        help: TestStepTranslations.atf_help_scroll_until_visible,
        id: 'scroll_until_visible',
        keys: const {'increment', 'scrollableId', 'testableId', 'timeout'},
        quickAddValues: const {'increment': '200'},
        title: TestStepTranslations.atf_title_scroll_until_visible,
        type: TestableType.scrolled,
        widgetless: false,
      ),
      testRunnerStepBuilder: ScrollUntilVisibleStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: SetValueForm(),
        help: TestStepTranslations.atf_help_set_value,
        id: 'set_value',
        keys: const {'testableId', 'timeout', 'type', 'value'},
        title: TestStepTranslations.atf_title_set_value,
        type: TestableType.value_settable,
        widgetless: false,
      ),
      testRunnerStepBuilder: SetValueStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: SleepForm(),
        help: TestStepTranslations.atf_help_sleep,
        id: 'sleep',
        keys: const {'timeout'},
        quickAddValues: const {'timeout': '5'},
        title: TestStepTranslations.atf_title_sleep,
        widgetless: true,
      ),
      testRunnerStepBuilder: SleepStep.fromDynamic,
    ),
    TestStepBuilder(
      availableTestStep: AvailableTestStep(
        form: TapForm(),
        help: TestStepTranslations.atf_help_tap,
        id: 'tap',
        keys: const {'testableId', 'timeout'},
        quickAddValues: const {},
        title: TestStepTranslations.atf_title_tap,
        type: TestableType.tappable,
        widgetless: false,
      ),
      testRunnerStepBuilder: TapStep.fromDynamic,
    ),
  ];

  final String debugLabel;
  final Map<String, TestStepBuilder> _builtInSteps = {};
  final Map<String, TestStepBuilder> _customSteps = {};

  List<AvailableTestStep> get availableSteps {
    var steps = <String, TestStepBuilder>{};

    steps.addAll(_builtInSteps);
    steps.addAll(_customSteps);

    var result = <AvailableTestStep>[];
    steps.forEach((_, value) => result.add(value.availableTestStep));

    // This will attempt to sort them alphabetically.  However, in fairness,
    // that depends on the translation value so if other languages (or even
    // other custom English language strings) have different string values vs
    // the keys then this could appear out of order.
    result.sort((a, b) => a.id.compareTo(b.id));

    return result;
  }

  static TestStepRegistry of(BuildContext context) {
    TestStepRegistry result;

    try {
      result = Provider.of<TestStepRegistry>(
        context,
        listen: false,
      );
    } catch (e) {
      // no-op
    }

    return result ?? instance;
  }

  AvailableTestStep getAvailableTestStep(String id) =>
      _customSteps[id]?.availableTestStep ??
      _builtInSteps[id]?.availableTestStep;

  TestStepBuilder getBuilder(String id) =>
      _customSteps[id] ?? _builtInSteps[id];

  TestRunnerStep getRunnerStep({
    @required String id,
    @required dynamic values,
  }) {
    TestRunnerStep result;
    var builder = getBuilder(id);

    if (builder != null) {
      result = builder.testRunnerStepBuilder(values ?? {});
    }

    return result;
  }

  void registerCustomStep(TestStepBuilder step) {
    assert(step != null);
    _customSteps[step.availableTestStep.id] = step;
  }

  void registerCustomSteps(List<TestStepBuilder> steps) {
    if (steps != null) {
      for (var step in steps) {
        registerCustomStep(step);
      }
    }
  }

  @override
  String toString() => 'TestStepRegistry{$debugLabel}';
}
