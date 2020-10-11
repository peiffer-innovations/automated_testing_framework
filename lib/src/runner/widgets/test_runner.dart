import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

/// Test runner that should be the base widget within an application.  This
/// requires the test controller and the [child] which is the application
/// itself.
class TestRunner extends StatefulWidget {
  /// Constructs the runner.  The [child] is the application to be tested.
  ///
  /// The [controller] is used to perform the actual test executions as well as
  /// loading and saving tests.  The [controller] may be [null] if, and only if,
  /// [enabled] is [false].
  ///
  /// Set [enabled] to [false] to disable the entire testing framework.  If
  /// omitted the frameworl is enabled in debug and profile mode but disabled in
  /// release mode.
  ///
  /// The [progressBuilder] is used to display test progress.  This will default
  /// to the built in progress builder but can be overridden by applications to
  /// display the test progress in their own unique way.
  ///
  /// The [testableRenderController] is used by the [Testable] widgets to
  /// determine how to render their UI and process user interactions.
  ///
  /// If a [theme] is passed in then that will be used by the framework's built
  /// in pages and widgets.
  TestRunner({
    @required this.child,
    @required TestController controller,
    bool enabled,
    Key key,
    this.progressBuilder = const TestProgressBuilder(),
    TestableRenderController testableRenderController,
    this.theme,
  })  : assert(child != null),
        assert(controller != null ||
            enabled == false ||
            (enabled == null && foundation.kReleaseMode == true)),
        _enabled = enabled ?? foundation.kReleaseMode != true,
        controller =
            (enabled ?? foundation.kReleaseMode != true) ? controller : null,
        _testableRenderController =
            testableRenderController ?? TestableRenderController(),
        super(key: key);

  final Widget child;
  final TestController controller;
  final Widget progressBuilder;
  final ThemeData theme;

  final bool _enabled;
  final TestableRenderController _testableRenderController;

  static TestRunnerState of(BuildContext context) {
    TestRunnerState runner;
    try {
      runner = context.findAncestorStateOfType<TestRunnerState>();
    } catch (e) {
      // no-op
    }

    return runner?.enabled == true ? runner : null;
  }

  bool get enabled => _enabled;
  TestableRenderController get testableRenderController =>
      _testableRenderController;

  @override
  TestRunnerState createState() => TestRunnerState();
}

class TestRunnerState extends State<TestRunner> {
  final GlobalKey _globalKey = GlobalKey();
  final List<StreamSubscription> _subscriptions = [];

  AnimationController _animationController;
  bool _enabled;
  MediaQueryData _mediaQuery;

  TestController get controller => widget.controller;
  bool get enabled => _enabled;
  TestableRenderController get testableRenderController =>
      widget.testableRenderController;
  ThemeData get theme => widget.theme;

  @override
  void initState() {
    super.initState();

    _enabled = widget.enabled == true;

    if (widget.enabled == true) {
      _subscriptions
          .add(controller.screencapStream.listen((captureContext) async {
        var captured = await capture();
        if (captured?.isNotEmpty == true) {
          captureContext.image.addAll(captured);
        }
      }));
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _animationController?.dispose();
    super.dispose();
  }

  Future<Uint8List> capture() async {
    await Future.delayed(Duration(milliseconds: 100));

    Uint8List image;

    if (!foundation.kIsWeb) {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      if (!foundation.kDebugMode || boundary?.debugNeedsPaint != true) {
        var img = await boundary.toImage(
          pixelRatio: _mediaQuery?.devicePixelRatio ?? 1.0,
        );
        var byteData = await img.toByteData(
          format: ui.ImageByteFormat.png,
        );
        image = byteData.buffer.asUint8List();
      }
    }

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return widget.enabled != true
        ? widget.child
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Provider<TestController>.value(
              value: controller,
              child: Builder(builder: (BuildContext context) {
                _mediaQuery = MediaQuery.of(context);
                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: widget.child,
                      ),
                    ),
                    if (widget.progressBuilder != null)
                      Builder(
                        builder: (BuildContext context) =>
                            widget.progressBuilder,
                      ),
                  ],
                );
              }),
            ),
          );
  }
}
