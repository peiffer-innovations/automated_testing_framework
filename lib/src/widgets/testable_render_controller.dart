import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tinycolor/tinycolor.dart';

/// Builder function that renders the [Testable] overlay when it is active.
typedef WidgetOverlayBuilder = Function({
  BuildContext context,
  Testable testable,
});

/// Controller that is used to provide information for the [Testable].  This
/// includes information such as what gestures to respond to as well as how to
/// render the global and / or individual overlays.
class TestableRenderController {
  TestableRenderController({
    this.debugLabel = 'custom',
    Color flashColor = const Color(0x88FFEB3B),
    int flashCount = 3,
    Duration flashDuration = const Duration(milliseconds: 100),
    TestableGestures gestures,
    WidgetBuilder globalOverlayBuilder,
    Color overlayColor,
    bool showGlobalOverlay = false,
    bool testWidgetsEnabled = kDebugMode == true,
    WidgetOverlayBuilder widgetOverlayBuilder,
  })  : assert(flashCount == 0 || flashColor != null),
        assert(flashCount != null),
        assert(flashCount >= 0),
        assert(showGlobalOverlay != null),
        assert(testWidgetsEnabled != null),
        _flashColor = flashColor,
        _flashCount = flashCount,
        _flashDuration = flashDuration,
        _gestures = gestures ?? TestableGestures(),
        _globalOverlayBuilder = globalOverlayBuilder ?? fullGlobalOverlay(),
        _overlayColor = overlayColor ?? Colors.red.shade300,
        _showGlobalOverlay = showGlobalOverlay,
        _testWidgetsEnabled = testWidgetsEnabled,
        _widgetOverlayBuilder = widgetOverlayBuilder ?? iconWidgetOverlay();

  static final TestableRenderController _defaultInstance =
      TestableRenderController(debugLabel: 'default');
  static final Logger _logger = Logger('TestableRenderController');

  final String debugLabel;

  final Color _flashColor;
  final int _flashCount;
  final Duration _flashDuration;

  StreamController<void> _controller = StreamController<void>.broadcast();
  TestableGestures _gestures;
  WidgetBuilder _globalOverlayBuilder;
  Color _overlayColor;
  bool _showGlobalOverlay;
  bool _testWidgetsEnabled;
  WidgetOverlayBuilder _widgetOverlayBuilder;

  Color get flashColor => _flashColor;
  int get flashCount => _flashCount;
  Duration get flashDuration => _flashDuration;
  TestableGestures get gestures => _gestures;
  WidgetBuilder get globalOverlayBuilder => _globalOverlayBuilder;
  Color get overlayColor => _overlayColor;
  bool get showGlobalOverlay => _showGlobalOverlay;
  Stream<void> get stream => _controller?.stream;
  bool get testWidgetsEnabled => _testWidgetsEnabled;
  WidgetOverlayBuilder get widgetOverlayBuilder => _widgetOverlayBuilder;

  set gestures(TestableGestures gestures) {
    assert(gestures != null);

    _gestures = gestures;
    _controller?.add(null);
  }

  set globalOverlayBuilder(WidgetBuilder globalOverlayBuilder) {
    assert(globalOverlayBuilder != null);

    _globalOverlayBuilder = globalOverlayBuilder;
    _controller?.add(null);
  }

  set overlayColor(Color overlayColor) {
    _overlayColor = overlayColor;
    _controller?.add(null);
  }

  set showGlobalOverlay(bool showGlobalOverlay) {
    assert(showGlobalOverlay != null);

    _showGlobalOverlay = showGlobalOverlay;
    _controller?.add(null);
  }

  set testWidgetsEnabled(bool testWidgetsEnabled) {
    assert(testWidgetsEnabled != null);

    _testWidgetsEnabled = testWidgetsEnabled;
    _controller?.add(null);
  }

  set widgetOverlayBuilder(WidgetOverlayBuilder widgetOverlayBuilder) {
    assert(widgetOverlayBuilder != null);

    _widgetOverlayBuilder = widgetOverlayBuilder;
    _controller?.add(null);
  }

  /// Returns either the [TestableRenderController] from an ancestor
  /// [TestRunner] instance, or this will return the default controller if no
  /// [TestRunner] is available.
  static TestableRenderController of(BuildContext context) {
    TestableRenderController result;

    try {
      var runner = TestRunner.of(context);
      result = runner.testableRenderController;
    } catch (e, stack) {
      _logger.severe('Error getting the controller from the context', e, stack);
    }
    result ??= _defaultInstance;

    return result;
  }

  /// A global overlay that renders with a thin border around the entire
  /// [Testable] widget using the given [color] and border [radius].
  static WidgetBuilder borderGlobalOverlay({
    Color color,
    double radius = 4.0,
  }) =>
      (BuildContext context) => Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: TestableRenderController.of(context)?.overlayColor ??
                        color ??
                        Theme.of(context).errorColor,
                  ),
                ),
              ),
            ),
          );

  /// A global overlay that renders with a solid [color] with a given [opacity]
  /// over the  entire [Testable] widget.
  static WidgetBuilder fullGlobalOverlay({
    Color color,
    double opacity = 0.1,
  }) =>
      (BuildContext context) => Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: opacity,
                child: Container(
                  color: TestableRenderController.of(context)?.overlayColor ??
                      color ??
                      Theme.of(context).errorColor,
                ),
              ),
            ),
          );

  /// An individual overlay for a [Testable] widget that renders with a given
  /// [color] and centered [icon] using a border [radius].
  static WidgetOverlayBuilder iconWidgetOverlay({
    Color color,
    IconData icon,
    double radius = 0.0,
  }) =>
      ({
        BuildContext context,
        Testable testable,
      }) =>
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: TinyColor(
                  TestableRenderController.of(context)?.overlayColor ??
                      color ??
                      Theme.of(context).errorColor,
                ).darken(20).color,
              ),
            ),
            padding: EdgeInsets.all(4.0),
            child: ClipRect(
              child: Icon(
                icon ?? Icons.settings_applications,
                color: Colors.white,
              ),
            ),
          );

  /// An individual overlay for a [Testable] widget that renders with the given
  /// [color] and border [radius].  This will render the current status text
  /// from the active [TestRunner] in the center of the widget.
  static WidgetOverlayBuilder idWidgetOverlay({
    Color color,
    Color textColor = Colors.white,
    double radius = 0.0,
  }) =>
      ({
        BuildContext context,
        Testable testable,
      }) =>
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: TinyColor(
                  TestableRenderController.of(context)?.overlayColor ??
                      color ??
                      Theme.of(context).errorColor,
                ).darken(20).color,
              ),
            ),
            child: ClipRect(
              child: Text(
                testable.id,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          );

  /// Disposes the controller.
  void dispose() {
    _controller?.close();
    _controller = null;
  }

  @override
  String toString() => 'TestableRenderController<$debugLabel>';
}
