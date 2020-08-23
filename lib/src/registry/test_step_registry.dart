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

  /// Default instance that will be provided unless
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

  /// Label that can be used to assist with debugging
  final String debugLabel;

  final Map<String, TestStepBuilder> _builtInSteps = {};
  final Map<String, TestStepBuilder> _customSteps = {};

  /// Returns the complete list of available tests.  This will first get the
  /// list of built in steps, then overlay on the custom steps assigned by the
  /// application.
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

  /// Returns the registery bound to the widget tree.  If no registry is bound
  /// to the widget tree, this will return the default instance.
  ///
  /// More often than not, developers will want to simply utilize the default
  /// instance, unless specific parts of an application require highly
  /// specialized test steps.
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

  /// Returns the test step that matches the given [id].  This will first look
  /// in the registered custom steps and then if no custom step with the given
  /// [id] exists, this will look in the built in steps.  If no step for the
  /// given [id] can be found, this will return [null].
  AvailableTestStep getAvailableTestStep(String id) =>
      _customSteps[id]?.availableTestStep ??
      _builtInSteps[id]?.availableTestStep;

  /// Returns the builder for the given [id].  This will first look in the
  /// registered custom steps and then if no custom step with the given [id]
  /// exists, this will look in the built in steps.  If no step for the given
  /// [id] can be found, this will return [null].
  TestStepBuilder getBuilder(String id) =>
      _customSteps[id] ?? _builtInSteps[id];

  /// Returns a [TestRunnerStep] for the given [id] and given set of [values].
  /// This will first look in the registered custom steps and then fall back to
  /// the built in steps.  If no step can be located for the given [id] then
  /// this will return [null].
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

  /// Registers a custom [step] with the registry.  If a custom step is already
  /// registered with the same ultimate id then it will be replaced with this.
  /// If a built in step is registered with the same ultimate id then this will
  /// shadow the built in step such that this step will now be used in place of
  /// the built in step.
  void registerCustomStep(TestStepBuilder step) {
    assert(step != null);
    _customSteps[step.availableTestStep.id] = step;
  }

  /// Simple convenience method that calls [registerCustomStep] for every entity
  /// in the given list.
  void registerCustomSteps(List<TestStepBuilder> steps) {
    if (steps != null) {
      for (var step in steps) {
        registerCustomStep(step);
      }
    }
  }

  /// Returns a string name for the registry for debugging.
  @override
  String toString() => 'TestStepRegistry{$debugLabel}';
}
