import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logging/logging.dart';
import 'package:static_translations/static_translations.dart';

/// Workhorse of the Automate Testing Framework.
class Testable extends StatefulWidget {
  /// Constructor for the [Testable] widget.  If there is no [TestRunner], or
  /// the runner is not enabled then this is a simple passthrough for the
  /// [child].
  ///
  /// This requires an [id] for the test framework to be able to find the widget
  /// on the tree when running tests.  Ideally this [id] is human readable but
  /// id can technically be any string that is valid w/in a [ValueKey].  If the
  /// [id] is either [null] or empty then this will disable the test framework
  /// for the child wildget and act as a simple passthrough.
  ///
  /// The [gestures] can be passed in as an override from the values set on the
  /// [TestController].  That is useful if the default gestures are already
  /// supported by this individual widget so providing a unique set of gestures
  /// for the [Testable] is desired.
  ///
  /// The [scrollableId] is typically only required if there are multiple
  /// [Scollables] on a page; such as a Netflix like vertical + horizontal
  /// scroll.  When that happens, the framework will always find the top level
  /// scroll and can only find the secondary scroll if the [scrollableId] is
  /// passed in.  The [scrollableId] is the value passed into the [ValueKey] on
  /// the key argument on the inner [Scrollable].
  ///
  /// This provides multiple mechanisms to try to interact with the [child]
  /// widget.  The first is to try to search the widget tree for widgets this
  /// knows how to interact with.  This will search up to
  /// [TestController.maxCommonSearchDepth] for a widget it knows how to
  /// interact with.  If none is found, or if the application would to provide
  /// custom logic, then the following callback methods are available:
  /// * [onRequestError] - Callback that will provide the current error message from the [child] widget.
  /// * [onRequestValue] - Callback that will provide the current value from the [child] widget.
  /// * [onSetValue] - Function that the framework can call to set the current value on the [child] widget.
  ///
  /// The list of Widgets this can auto-discover capabilities are as follows:
  /// * [Checkbox]: onRequestValue
  /// * [CupertinoSwitch]: onRequestValue; if a [TextEditingController] is set then also: onSetValue
  /// * [CupertinoTextField]: onRequestValue
  /// * [DropdownButton]: onRequestValue
  /// * [FormField]: **Note**: must have a GlobalKey<FormFieldState> set; onRequestError, onRequestValue, onSetValue
  /// * [Radio]: onRequestValue
  /// * [Switch]: onRequestValue
  /// * [Text]: onRequestValue
  /// * [TextField]: onRequestValue; if a [TextEditingController] is set then also: onSetValue
  /// * [TextFormField]: onRequestValue; if a [TextEditingController] is set then also: onSetValue
  Testable({
    @required this.child,
    this.gestures,
    @required this.id,
    this.onRequestError,
    this.onRequestValue,
    this.onSetValue,
    this.scrollableId,
  })  : assert(child != null),
        super(key: ValueKey(id));

  /// The child widget the test framework should be testing.
  final Widget child;

  /// The gesture overrides for this [Testable] widget.
  final TestableGestures gestures;

  /// The page-unique identifier for the widget.  This is required for the
  /// framework to be able to locate then widget when runnning in test mode.
  final String id;

  /// Callback function that can provide the error message from the [child]
  /// widget to the testing framework.
  final String Function() onRequestError;

  /// Callback function that can provide the value from the [child] widget to
  /// the testing framework.
  final dynamic Function() onRequestValue;

  /// Callback funcation that can be used to set the value to the [child]
  /// widget.
  final ValueChanged<dynamic> onSetValue;

  /// The page-unique id of the [Scrollable] widget containing this [Testable]
  /// widget.  This is required to be able to identify the propery [Scrollable]
  /// when there are multiple [Scrollable] widgets on a single plage.
  final String scrollableId;

  @override
  TestableState createState() => TestableState();
}

/// State object for a [Testable] widget.
class TestableState extends State<Testable>
    with SingleTickerProviderStateMixin {
  static final Logger _logger = Logger('_TestableState');

  final List<StreamSubscription> _subscriptions = [];
  final Set<TestableType> _types = {TestableType.tappable};

  Animation<Color> _animation;
  AnimationController _animationController;
  Color _backgroundColor;
  bool _isDialogOpen;
  Color _obscureColor = Colors.transparent;
  dynamic Function() _onRequestError;
  dynamic Function() _onRequestValue;
  ValueChanged<dynamic> _onSetValue;
  double _opacity = 1.0;
  TestableRenderController _renderController;
  GlobalKey _renderKey;
  String _scrollableId;

  /// Global key that provides the ability for the scroll_until_visible step to
  /// actually scroll to this widget.
  GlobalKey _scrollKey;
  bool _showTestableOverlay = false;
  TestController _testController;
  TestRunnerState _testRunner;

  /// Returns the callback function capable of prividing the current error
  /// message from the [child] widget.
  dynamic Function() get onRequestError => _onRequestError;

  /// Returns the callback function capable of prividing the current value from
  /// the [child] widget.
  dynamic Function() get onRequestValue => _onRequestValue;

  /// Returns the callback funcation that can be used to set the value to the
  /// [child]  widget.
  ValueChanged<dynamic> get onSetValue => _onSetValue;

  @override
  void initState() {
    super.initState();

    if (widget.id?.isNotEmpty == true) {
      _testRunner = TestRunner.of(context);

      if (_testRunner?.enabled == true) {
        _renderController = TestableRenderController.of(context);
        _testController = TestController.of(context);
        _onRequestError =
            widget.onRequestError ?? _tryCommonGetErrorMethods(widget.child);
        if (_onRequestError != null) {
          _types.add(TestableType.error_requestable);
        }

        _onRequestValue =
            widget.onRequestValue ?? _tryCommonGetValueMethods(widget.child);
        if (_onRequestValue != null) {
          _types.add(TestableType.value_requestable);
        }

        _onSetValue =
            widget.onSetValue ?? _tryCommonSetValueMethods(widget.child);
        if (_onSetValue != null) {
          _types.add(TestableType.value_settable);
        }

        if (_renderController.testWidgetsEnabled == true) {
          _renderKey = GlobalKey();

          _subscriptions.add(_renderController.stream.listen((_) {
            if (mounted == true) {
              setState(() {});
            }
          }));
        }

        if (_renderController.flashCount > 0) {
          _animationController = AnimationController(
            duration: _renderController.flashDuration,
            vsync: this,
          );
          _animation = ColorTween(
            begin: Colors.transparent,
            end: _renderController.flashColor,
          ).animate(_animationController)
            ..addListener(() {
              if (mounted == true) {
                setState(() {});
              }
            });
        }

        _isDialogOpen = false;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.id?.isNotEmpty == true) {
      _testRunner = TestRunner.of(context);

      if (_testRunner?.enabled == true) {
        TestDeviceInfoHelper.initialize(context);

        if (mounted == true) {
          _scrollableId = widget.scrollableId;
          var canBeScrolled = false;
          if (_scrollableId?.isNotEmpty != true) {
            try {
              var scrollable = Scrollable.of(context);
              canBeScrolled = scrollable != null;
              _scrollableId = scrollable?.widget?.key?.toString();
            } catch (e, stack) {
              _logger.severe(e, stack);
            }
          }

          if (canBeScrolled == true || _scrollableId?.isNotEmpty == true) {
            _types.add(TestableType.scrolled);
            _scrollKey = GlobalKey();
          }
        }
      }
    }
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.id?.isNotEmpty == true) {
      _testRunner = TestRunner.of(context);

      if (_testRunner?.enabled == true) {
        _types.remove(TestableType.error_requestable);
        _types.remove(TestableType.value_requestable);
        _types.remove(TestableType.value_settable);

        _onRequestError =
            widget.onRequestError ?? _tryCommonGetErrorMethods(widget.child);
        if (_onRequestError != null) {
          _types.add(TestableType.error_requestable);
        }

        _onRequestValue =
            widget.onRequestValue ?? _tryCommonGetValueMethods(widget.child);
        if (_onRequestValue != null) {
          _types.add(TestableType.value_requestable);
        }

        _onSetValue =
            widget.onSetValue ?? _tryCommonSetValueMethods(widget.child);
        if (_onSetValue != null) {
          _types.add(TestableType.value_settable);
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _animationController = null;
    _subscriptions?.forEach((sub) => sub.cancel());

    super.dispose();
  }

  /// Captures the image from the current widget.  This will return [null] if
  /// the image cannot be captured for any reason.
  ///
  /// This will always return [null] on the Web platform.
  ///
  /// This accepts an optional [backgroundColor].  When set, the
  /// [backgroundColor] will be painted on the image first and then the widget
  /// image will be painted.  This can be useful when widgets inherit a
  /// background from their parent because that background would not be part of
  /// the captured value.
  Future<Uint8List> captureImage([
    Color backgroundColor,
  ]) async {
    RenderRepaintBoundary boundary =
        _renderKey.currentContext.findRenderObject();
    Uint8List image;
    if (!kIsWeb) {
      if (!kDebugMode || boundary?.debugNeedsPaint != true) {
        _backgroundColor = backgroundColor;
        if (mounted == true) {
          setState(() {});
        }

        await Future.delayed(Duration(milliseconds: 500));
        boundary = _renderKey.currentContext.findRenderObject();
        var img = await boundary.toImage(
          pixelRatio: MediaQuery.of(context).devicePixelRatio,
        );
        var byteData = await img.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image = byteData.buffer.asUint8List();
        _backgroundColor = null;
        if (mounted == true) {
          setState(() {});
        }
      }
    }

    return image;
  }

  /// Flashes the [Testable] widget to give a visual indicator that the
  /// framework is interactging with the widget.
  Future<void> flash() async {
    if (_renderController.testWidgetsEnabled == true) {
      for (var i = 0; i < _renderController.flashCount; i++) {
        await _animationController.forward(from: 0.0);
        await _animationController.reverse(from: 1.0);
      }
    }
  }

  /// Obscures the testable widget using the given color.  This provides a way
  /// to obscure / exclude dynamic widgets from golden screenshot calculations.
  Future<void> obscure(Color color) async {
    _obscureColor = color ?? Colors.transparent;
    if (mounted == true) {
      setState(() {});
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  /// Sets the opacity on the widget to hide it or show it for golden image
  /// tests.
  Future<void> opacity(double opacity) async {
    _opacity = opacity ?? 0;
    if (mounted == true) {
      setState(() {});
      await Future.delayed(Duration(milliseconds: 300));
    }
  }

  VoidCallback _getGestureAction({
    TestableGestureAction widget,
    TestableGestureAction overlay,
  }) {
    VoidCallback result;

    if (_showTestableOverlay == true) {
      if (overlay != null) {
        result = () => _fireTestableAction(overlay);
      }
    } else {
      if (widget != null) {
        result = () => _fireTestableAction(widget);
      }
    }

    return result;
  }

  Future<void> _fireTestableAction(TestableGestureAction action) async {
    if (mounted == true) {
      switch (action) {
        case TestableGestureAction.open_test_actions_dialog:
          await _openTestActions(page: false);
          break;

        case TestableGestureAction.open_test_actions_page:
          await _openTestActions(page: true);
          break;

        case TestableGestureAction.toggle_global_overlay:
          _showTestableOverlay = false;
          _renderController.showGlobalOverlay =
              _renderController.showGlobalOverlay != true;
          if (mounted == true) {
            setState(() {});
          }
          break;

        case TestableGestureAction.toggle_overlay:
          _showTestableOverlay = !_showTestableOverlay;
          if (mounted == true) {
            setState(() {});
          }
          break;
      }
    }
  }

  Future<void> _openTestActions({@required bool page}) async {
    var overlayShowing = _showTestableOverlay;
    _showTestableOverlay = false;
    if (mounted == true) {
      setState(() {});
    }
    try {
      if (overlayShowing == true) {
        await Future.delayed(Duration(milliseconds: 500));
      }

      var image = await captureImage();

      if (mounted == true) {
        setState(() {});
      }

      if (page == true) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => TestableStepsPage(
              error: _onRequestError == null ? null : _onRequestError(),
              image: image,
              scrollableId: _scrollableId,
              testableId: widget.id,
              types: _types.toList(),
              value: _onRequestValue == null ? null : _onRequestValue(),
            ),
          ),
        );
      } else if (_isDialogOpen == false) {
        _isDialogOpen = true;
        var result = await showDialog<String>(
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) => TestableStepsDialog(
            error: _onRequestError == null ? null : _onRequestError(),
            image: image,
            scrollableId: _scrollableId,
            testableId: widget.id,
            types: _types.toList(),
            value: _onRequestValue == null ? null : _onRequestValue(),
          ),
        );
        _isDialogOpen = false;

        if (result?.isNotEmpty == true) {
          var translator = Translator.of(context);
          try {
            var snackBar = SnackBar(
              content: Text(result),
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: translator
                    .translate(TestTranslations.atf_button_view_steps),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => TestStepsPage(),
                  ),
                ),
              ),
            );
            // ignore: deprecated_member_use
            Scaffold.of(context).showSnackBar(snackBar);
          } catch (e) {
            await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      translator.translate(TestTranslations.atf_button_ok),
                    ),
                  ),
                ],
                content: Text(result),
              ),
            );
          }
        }
      }
    } finally {
      if (mounted == true) {
        setState(() {});
      }
    }
  }

  dynamic Function() _tryCommonGetErrorMethods(
    dynamic widget, {
    int depth = 0,
  }) {
    dynamic Function() result;

    if (depth < _testController.maxCommonSearchDepth) {
      if (widget is FormField) {
        var key = widget.key;
        if (key is GlobalKey) {
          var state = key.currentState;
          if (state is FormFieldState) {
            result = () => state.errorText;
          }
        }
      }

      try {
        if (result == null && widget?.child != null) {
          result = _tryCommonGetErrorMethods(widget.child, depth: depth + 1);
        }
      } catch (e) {
        // no-op
      }
    }

    return result;
  }

  dynamic Function() _tryCommonGetValueMethods(
    dynamic widget, {
    int depth = 0,
  }) {
    dynamic Function() result;

    if (depth < _testController.maxCommonSearchDepth) {
      if (widget is Text) {
        result = () => widget.data ?? widget.textSpan?.toPlainText();
      } else if ((widget is TextField ||
          widget is TextFormField ||
          widget is CupertinoTextField)) {
        dynamic text = widget;
        if (text?.controller != null) {
          result = () => text.controller.text;
        }
      } else if (widget is Checkbox) {
        result = () => widget.value;
      } else if (widget is CupertinoSwitch) {
        result = () => widget.value;
      } else if (widget is DropdownButton) {
        result = () => widget.value;
      } else if (widget is Radio) {
        result = () => widget.groupValue;
      } else if (widget is Switch) {
        result = () => widget.value;
      } else if (widget is FormField) {
        var key = widget.key;
        if (key is GlobalKey) {
          var state = key.currentState;
          if (state is FormFieldState) {
            result = () => state.value;
          }
        }
      }

      try {
        if (result == null && widget?.child != null) {
          result = _tryCommonGetValueMethods(widget.child, depth: depth + 1);
        }
      } catch (e) {
        // no-op
      }
    }

    return result;
  }

  ValueChanged<dynamic> _tryCommonSetValueMethods(
    dynamic widget, {
    int depth = 0,
  }) {
    ValueChanged<dynamic> result;

    if (depth < _testController.maxCommonSearchDepth) {
      if ((widget is TextField ||
          widget is TextFormField ||
          widget is CupertinoTextField)) {
        dynamic text = widget;
        if (text?.controller != null) {
          result = (dynamic value) => text.controller.text = value?.toString();
        }
      } else if (widget is FormField) {
        var key = widget.key;
        if (key is GlobalKey) {
          var state = key.currentState;
          if (state is FormFieldState) {
            result = (value) => state.didChange(value);
          }
        }
      }
      try {
        if (result == null && widget?.child != null) {
          result = _tryCommonSetValueMethods(widget.child, depth: depth + 1);
        }
      } catch (e) {
        // no-op
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget result;

    if (widget.id?.isNotEmpty == true &&
        _testRunner?.enabled == true &&
        _renderController.testWidgetsEnabled == true) {
      var gestures =
          widget.gestures ?? TestableRenderController.of(context).gestures;

      Widget overlay = _renderController.widgetOverlayBuilder(
        context: context,
        testable: widget,
      );

      overlay = Positioned.fill(
        child: IgnorePointer(
          ignoring: _showTestableOverlay != true,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: _showTestableOverlay == true ? 1.0 : 0.0,
            child: Material(
              color: _renderController.overlayColor ??
                  Theme.of(context).errorColor,
              child: InkWell(
                onDoubleTap: _getGestureAction(
                  overlay: gestures.overlayDoubleTap,
                ),
                onLongPress: _getGestureAction(
                  overlay: gestures.overlayLongPress,
                ),
                onTap: _getGestureAction(
                  overlay: gestures.overlayTap,
                ),
                child: overlay,
              ),
            ),
          ),
        ),
      );

      result = Stack(
        fit: StackFit.passthrough,
        key: _scrollKey,
        children: [
          IgnorePointer(
            ignoring: _showTestableOverlay == true,
            child: GestureDetector(
              onDoubleTap: _getGestureAction(
                widget: gestures.widgetDoubleTap,
              ),
              onForcePressEnd: gestures.widgetForcePressEnd == null
                  ? null
                  : (_) => _fireTestableAction(gestures.widgetForcePressEnd),
              onForcePressStart: gestures.widgetForcePressStart == null
                  ? null
                  : (_) => _fireTestableAction(gestures.widgetForcePressStart),
              onLongPress: _getGestureAction(
                widget: gestures.widgetLongPress,
              ),
              onLongPressMoveUpdate: gestures.widgetLongPressMoveUpdate == null
                  ? null
                  : (details) {
                      if (details.localOffsetFromOrigin.distance != 0) {
                        _fireTestableAction(
                          gestures.widgetLongPressMoveUpdate,
                        );
                      }
                    },
              onSecondaryLongPress: _getGestureAction(
                widget: gestures.widgetSecondaryLongPress,
              ),
              onSecondaryTap: _getGestureAction(
                widget: gestures.widgetSecondaryTap,
              ),
              onTap: _getGestureAction(
                widget: gestures.widgetTap,
              ),
              child: RepaintBoundary(
                key: _renderKey,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: _opacity ?? 1.0,
                  child: Stack(
                    children: <Widget>[
                      if (_backgroundColor != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: _backgroundColor,
                            ),
                          ),
                        ),
                      widget.child,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            color: _obscureColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_renderController.showGlobalOverlay == true &&
              _testController.runningTest != true)
            _renderController.globalOverlayBuilder(context),
          overlay,
          if (_renderController.flashCount > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: _animation.value),
              ),
            ),
        ],
      );
    } else if (widget.id?.isNotEmpty == true && _testRunner?.enabled == true) {
      // The scroll_until_visible step is expecting a stack with a global key.
      // So even though the test widgets are disabled, this wrapping still needs
      // to happen or else that step will always fail.
      result = Stack(
        fit: StackFit.passthrough,
        key: _scrollKey,
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                color: _obscureColor,
              ),
            ),
          ),
        ],
      );
    } else {
      result = widget.child;
    }

    return result;
  }
}
