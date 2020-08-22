import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class TestRunner extends StatefulWidget {
  TestRunner({
    @required this.child,
    @required this.controller,
    bool enabled,
    Key key,
    this.progressBuilder = const TestProgressBuilder(),
    TestableRenderController testableRenderController,
  })  : assert(child != null),
        assert(controller != null ||
            enabled == false ||
            (enabled == null && foundation.kReleaseMode == true)),
        _enabled = enabled ?? foundation.kReleaseMode != true,
        _testableRenderController =
            testableRenderController ?? TestableRenderController(),
        super(key: key);

  final bool _enabled;

  final Widget child;
  final TestController controller;
  final Widget progressBuilder;

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

  TestController get controller => widget.controller;
  bool get enabled => _enabled;
  TestableRenderController get testableRenderController =>
      widget.testableRenderController;

  @override
  void initState() {
    super.initState();

    _enabled = widget.enabled == true;

    if (widget.enabled == true) {
      _subscriptions
          .add(controller.screencapStream.listen((captureContext) async {
        var captured = await capture(captureContext.devicePixelRatio);
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

  Future<Uint8List> capture([double devicePixelRatio = 1.0]) async {
    await Future.delayed(Duration(milliseconds: 100));

    Uint8List image;

    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
    if (boundary?.debugNeedsPaint != true) {
      var img = await boundary.toImage(
        pixelRatio: devicePixelRatio,
      );
      var byteData = await img.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image = byteData.buffer.asUint8List();
    }

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return widget.enabled != true
        ? widget.child
        : MaterialApp(
            home: Provider<TestController>.value(
              value: controller,
              child: Builder(
                builder: (BuildContext context) => Stack(
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
                ),
              ),
            ),
          );
  }
}
