import 'dart:async';

import 'package:flutter/material.dart';

class TestDriverStatus extends StatefulWidget {
  TestDriverStatus({
    required this.child,
    this.displayStatus = true,
    required this.statusStream,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final bool displayStatus;
  final Stream<String> statusStream;

  @override
  _TestDriverStatusState createState() => _TestDriverStatusState();
}

class _TestDriverStatusState extends State<TestDriverStatus> {
  final List<StreamSubscription> _subscriptions = [];
  bool _statusShowing = false;
  late String _status;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _subscriptions.add(widget.statusStream.listen((status) async {
      _status = status;
      _statusShowing = true;
      if (mounted == true) {
        setState(() {});
      }

      _timer?.cancel();
      _timer = Timer(Duration(seconds: 5), () {
        _statusShowing = false;
        if (mounted == true) {
          setState(() {});
        }
      });
    }));

    _status = 'waiting';
  }

  @override
  void dispose() {
    _subscriptions.forEach((element) => element.cancel());
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.displayStatus == true
        ? Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (BuildContext context) => Stack(
                children: [
                  widget.child,
                  Align(
                    alignment: Alignment.center,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _statusShowing == true ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 400.0,
                          ),
                          height: 120.0,
                          child: Material(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Colors.black87,
                            elevation: 4.0,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bug_report,
                                    color: Colors.white,
                                    size: 40.0,
                                  ),
                                  SizedBox(
                                    height: 16.0,
                                  ),
                                  Text(
                                    _status,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : widget.child;
  }
}
