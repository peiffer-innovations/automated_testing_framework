import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assert_error', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'assert_error',
    )!;

    expect(availStep.form.runtimeType, AssertErrorForm);
    expect(availStep.help, TestStepTranslations.atf_help_assert_error);
    expect(availStep.id, 'assert_error');
    expect(availStep.title, TestStepTranslations.atf_title_assert_error);
    expect(availStep.type, TestableType.error_requestable);
    expect(availStep.widgetless, false);
  });

  test('assert_value', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'assert_value',
    )!;

    expect(availStep.form.runtimeType, AssertValueForm);
    expect(availStep.help, TestStepTranslations.atf_help_assert_value);
    expect(availStep.id, 'assert_value');
    expect(availStep.title, TestStepTranslations.atf_title_assert_value);
    expect(availStep.type, TestableType.value_requestable);
    expect(availStep.widgetless, false);
  });

  test('comment', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'comment',
    )!;

    expect(availStep.form.runtimeType, CommentForm);
    expect(availStep.help, TestStepTranslations.atf_help_comment);
    expect(availStep.id, 'comment');
    expect(availStep.title, TestStepTranslations.atf_title_comment);
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('dismiss_keyboard', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'dismiss_keyboard',
    )!;

    expect(availStep.form.runtimeType, DismissKeyboardForm);
    expect(availStep.help, TestStepTranslations.atf_help_dismiss_keyboard);
    expect(availStep.id, 'dismiss_keyboard');
    expect(availStep.title, TestStepTranslations.atf_title_dismiss_keyboard);
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('double_tap', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'double_tap',
    )!;

    expect(availStep.form.runtimeType, DoubleTapForm);
    expect(availStep.help, TestStepTranslations.atf_help_double_tap);
    expect(availStep.id, 'double_tap');
    expect(availStep.title, TestStepTranslations.atf_title_double_tap);
    expect(availStep.type, null);
    expect(availStep.widgetless, false);
  });

  test('ensure_exists', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'ensure_exists',
    )!;

    expect(availStep.form.runtimeType, EnsureExistsForm);
    expect(availStep.help, TestStepTranslations.atf_help_ensure_exists);
    expect(availStep.id, 'ensure_exists');
    expect(availStep.title, TestStepTranslations.atf_title_ensure_exists);
    expect(availStep.type, null);
    expect(availStep.widgetless, false);
  });

  test('exit_app', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'exit_app',
    )!;

    expect(availStep.form.runtimeType, ExitAppForm);
    expect(availStep.help, TestStepTranslations.atf_help_exit_app);
    expect(availStep.id, 'exit_app');
    expect(availStep.title, TestStepTranslations.atf_title_exit_app);
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('go_back', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'go_back',
    )!;

    expect(availStep.form.runtimeType, GoBackForm);
    expect(availStep.help, TestStepTranslations.atf_help_go_back);
    expect(availStep.id, 'go_back');
    expect(availStep.title, TestStepTranslations.atf_title_go_back);
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('long_press', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'long_press',
    )!;

    expect(availStep.form.runtimeType, LongPressForm);
    expect(availStep.help, TestStepTranslations.atf_help_long_press);
    expect(availStep.id, 'long_press');
    expect(availStep.title, TestStepTranslations.atf_title_long_press);
    expect(availStep.type, TestableType.tappable);
    expect(availStep.widgetless, false);
  });

  test('screenshot', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'screenshot',
    )!;

    expect(availStep.form.runtimeType, ScreenshotForm);
    expect(availStep.help, TestStepTranslations.atf_help_screenshot);
    expect(availStep.id, 'screenshot');
    expect(availStep.title, TestStepTranslations.atf_title_screenshot);
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('scroll_until_visible', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'scroll_until_visible',
    )!;

    expect(availStep.form.runtimeType, ScrollUntilVisibleForm);
    expect(availStep.help, TestStepTranslations.atf_help_scroll_until_visible);
    expect(availStep.id, 'scroll_until_visible');
    expect(
      availStep.title,
      TestStepTranslations.atf_title_scroll_until_visible,
    );
    expect(availStep.type, TestableType.scrolled);
    expect(availStep.widgetless, false);
  });

  test('set_value', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'set_value',
    )!;

    expect(availStep.form.runtimeType, SetValueForm);
    expect(availStep.help, TestStepTranslations.atf_help_set_value);
    expect(availStep.id, 'set_value');
    expect(availStep.title, TestStepTranslations.atf_title_set_value);
    expect(availStep.type, TestableType.value_settable);
    expect(availStep.widgetless, false);
  });

  test('set_variable', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'set_variable',
    )!;

    expect(availStep.form.runtimeType, SetVariableForm);
    expect(availStep.help, TestStepTranslations.atf_help_set_variable);
    expect(availStep.id, 'set_variable');
    expect(availStep.title, TestStepTranslations.atf_title_set_variable);
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('sleep', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'sleep',
    )!;

    expect(availStep.form.runtimeType, SleepForm);
    expect(availStep.help, TestStepTranslations.atf_help_sleep);
    expect(availStep.id, 'sleep');
    expect(availStep.title, TestStepTranslations.atf_title_sleep);
    expect(availStep.type, null);
    expect(availStep.widgetless, true);
  });

  test('tap', () {
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'tap',
    )!;

    expect(availStep.form.runtimeType, TapForm);
    expect(availStep.help, TestStepTranslations.atf_help_tap);
    expect(availStep.id, 'tap');
    expect(availStep.title, TestStepTranslations.atf_title_tap);
    expect(availStep.type, TestableType.tappable);
    expect(availStep.widgetless, false);
  });
}
