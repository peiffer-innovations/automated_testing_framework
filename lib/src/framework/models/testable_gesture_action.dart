import 'package:meta/meta.dart';

/// Built-in actions that are available to be set either by-default or by-widget
/// on [Testable] widgets.
@immutable
class TestableGestureAction {
  const TestableGestureAction._(this.code) : assert(code != null);

  /// Action that will result in the simplified test step dialog being displayed
  /// to the end user.
  static const TestableGestureAction open_test_actions_dialog =
      TestableGestureAction._('open_test_actions_dialog');

  /// Action that will result in the full test step page being displayed to the
  /// end user.
  static const TestableGestureAction open_test_actions_page =
      TestableGestureAction._('open_test_actions_page');

  /// Action that will result in the global (all [Testable]) overlay being
  /// turned on or off.  This can be useful when a user knows where a single
  /// [Testable] may exist but said user may want to see indicators for all
  /// [Testable] widgets within a page / application.
  static const TestableGestureAction toggle_global_overlay =
      TestableGestureAction._('toggle_global_overlay');

  /// Action that will result in the individual overlay for a single [Testable]
  /// will be activated or deactivated.
  static const TestableGestureAction toggle_overlay =
      TestableGestureAction._('toggle_overlay');

  final String code;
}
