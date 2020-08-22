import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:meta/meta.dart';

/// Set of gestures that [Testable] widgets will respond to when the
/// [TestRunner] is enabled.  Applications can (should) set the gestures based
/// on their typical usage patterns such that the gestures have a minimal
/// amount of conflict with application based gestures.
///
/// The default set of gestures ensures all available [Testable] gestures are
/// available within an application, but this may or may not be appropriate for
/// your specific application.
///
/// Given that the default set goes wide, it is recommended that applications
/// explicitly set values to [null] for any gestures that should not be used.
@immutable
class TestableGestures {
  TestableGestures({
    this.overlayDoubleTap = TestableGestureAction.toggle_overlay,
    this.overlayLongPress = TestableGestureAction.toggle_global_overlay,
    this.overlayTap = TestableGestureAction.open_test_actions_page,
    this.widgetDoubleTap = TestableGestureAction.toggle_overlay,
    this.widgetForcePressEnd,
    this.widgetForcePressStart,
    this.widgetLongPress = TestableGestureAction.open_test_actions_dialog,
    this.widgetTap,
  });

  /// Action that will execute when an individual [Testable] overlay is double
  /// tapped.
  final TestableGestureAction overlayDoubleTap;

  /// Action that will execute when an individual [Testable] overlay is long
  /// pressed.
  final TestableGestureAction overlayLongPress;

  /// Action that will execute when an individual [Testable] overlay is tapped.
  final TestableGestureAction overlayTap;

  /// Action that will execute when a [Testable] widget with the overlay hidden
  /// is double tapped.
  final TestableGestureAction widgetDoubleTap;

  /// Action that will execute when a [Testable] widget with the overlay hidden
  /// receives a force press end event.
  final TestableGestureAction widgetForcePressEnd;

  /// Action that will execute when a [Testable] widget with the overlay hidden
  /// receives a force press start event.
  final TestableGestureAction widgetForcePressStart;

  /// Action that will execute when a [Testable] widget with the overlay hidden
  /// is long pressed.
  final TestableGestureAction widgetLongPress;

  /// Action that will execute when a [Testable] widget with the overlay hidden
  /// is tapped.
  final TestableGestureAction widgetTap;
}
