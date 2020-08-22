import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

class SleepProgress extends StatefulWidget {
  SleepProgress({
    this.error,
    Key key,
    @required this.max,
    this.progress,
    @required this.stream,
    @required this.theme,
  })  : assert(max != null),
        assert(max >= 0),
        assert(stream != null),
        assert(theme != null),
        super(key: key);

  final bool error;
  final int max;
  final double progress;
  final Stream<ProgressValue> stream;
  final TestRunnerThemeData theme;

  @override
  _SleepProgressState createState() => _SleepProgressState();
}

class _SleepProgressState extends State<SleepProgress>
    with SingleTickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];

  AnimationController _animationController;
  bool _error;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.max * 1000 ~/ 50),
      vsync: this,
    );

    _animationController.addListener(() {
      if (mounted == true) {
        setState(() {});
      }
    });

    _subscriptions.add(widget.stream.listen((event) {
      _error = _error == true || event?.error == true;
      if (event?.progress != null) {
        _animationController.animateTo(event.progress);
      } else {
        _animationController.animateTo(1.0);
      }
    }));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _subscriptions?.forEach((sub) => sub.cancel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: widget.theme.statusOpacity,
        child: LinearProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(
            widget.error == true || _error == true
                ? widget.theme.statusErrorColor
                : widget.theme.statusProgressColor,
          ),
          value: _animationController.value,
        ),
      ),
    );
  }
}
