import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

/// Builds and displays the test progress.
class TestProgressBuilder extends StatefulWidget {
  const TestProgressBuilder({
    Key? key,
    this.theme = const TestRunnerThemeData(),
  }) : super(key: key);

  final TestRunnerThemeData theme;

  @override
  _TestProgressBuilderStart createState() => _TestProgressBuilderStart();
}

class _TestProgressBuilderStart extends State<TestProgressBuilder> {
  final List<StreamSubscription> _subscriptions = [];

  TestController? _controller;
  bool? _error;
  int? _max;
  Key _sleepKey = UniqueKey();
  bool _sleeping = false;

  @override
  void initState() {
    super.initState();

    final testRunner = TestRunner.of(context);

    if (testRunner?.enabled == true) {
      _controller = testRunner!.controller;
      _subscriptions.add(_controller!.sleepStream.listen((event) {
        final sleeping = event?.progress != null;
        _error = event?.error == true;
        _max = event?.max;

        if (sleeping != _sleeping) {
          _sleepKey = UniqueKey();
          _sleeping = sleeping;
          if (mounted == true) {
            setState(() {});
          }
        }
      }));
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  Widget _buildProgressWidgets(BuildContext context) => Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: StreamBuilder<ProgressValue?>(
                builder: (
                  BuildContext context,
                  AsyncSnapshot<ProgressValue?> sleepValue,
                ) =>
                    StreamBuilder<ProgressValue?>(
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<ProgressValue?> value,
                  ) =>
                      value.data == null && sleepValue.data == null
                          ? const SizedBox()
                          : Container(
                              color: widget.theme.runnerOverlayColor,
                            ),
                  stream: _controller!.stepStream,
                ),
                stream: _controller!.sleepStream,
              ),
            ),
          ),
          StreamBuilder<ProgressValue?>(
            builder: (
              BuildContext context,
              AsyncSnapshot<ProgressValue?> value,
            ) =>
                value.data == null
                    ? const SizedBox()
                    : Align(
                        alignment: (widget.theme.statusAlignment ==
                                    TestStatusAlignment.top ||
                                widget.theme.statusAlignment ==
                                    TestStatusAlignment.topSafe)
                            ? Alignment.topCenter
                            : widget.theme.statusAlignment ==
                                    TestStatusAlignment.center
                                ? Alignment.center
                                : Alignment.bottomCenter,
                        child: IgnorePointer(
                          child: Container(
                            height:
                                widget.theme.showStepText == true ? 32.0 : 4.0,
                            margin: EdgeInsets.only(
                              bottom: widget.theme.statusAlignment ==
                                      TestStatusAlignment.bottomSafe
                                  ? MediaQuery.of(context).padding.bottom
                                  : 0.0,
                              top: widget.theme.statusAlignment ==
                                      TestStatusAlignment.topSafe
                                  ? MediaQuery.of(context).padding.top
                                  : 0.0,
                            ),
                            width: double.infinity,
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: Container(
                                    color: widget.theme.statusBackgroundColor,
                                  ),
                                ),
                                _buildStepListener(context),
                                if (_sleeping == true)
                                  SleepProgress(
                                    error: _error,
                                    key: _sleepKey,
                                    max: _max!,
                                    stream: _controller!.sleepStream,
                                    theme: widget.theme,
                                  ),
                                _buildStatusListener(context),
                              ],
                            ),
                          ),
                        ),
                      ),
            stream: _controller!.stepStream,
          ),
        ],
      );

  Widget _buildStatusListener(BuildContext context) => Theme(
        data: ThemeData(),
        child: Builder(
          builder: (BuildContext context) => Align(
            alignment: Alignment.center,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                    builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) =>
                        Text(
                      snapshot.data ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.theme.statusTextColor,
                      ),
                    ),
                    stream: _controller!.statusStream,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildStepListener(BuildContext context) => Positioned.fill(
        child: StreamBuilder<ProgressValue?>(
          builder: (
            BuildContext context,
            AsyncSnapshot<ProgressValue?> value,
          ) =>
              value.data == null
                  ? const SizedBox()
                  : LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        widget.theme.statusSuccessColor,
                      ),
                      value: value.data!.progress,
                    ),
          stream: _controller!.stepStream,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return widget.theme.showRunnerStatus == true
        ? _buildProgressWidgets(context)
        : const SizedBox();
  }
}
