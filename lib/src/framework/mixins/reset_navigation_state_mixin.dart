import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

/// Mixin to listen for the testing framework to request a reset and thus pop
/// itself off the navigation stack if it is still mounted.
mixin ResetNavigationStateMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription? _resetSubscription;

  @override
  void initState() {
    super.initState();

    var testController = TestController.of(context);
    _resetSubscription = testController?.resetStream.listen((_) {
      if (mounted) {
        var nav = Navigator.of(context);
        if (nav.canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _resetSubscription?.cancel();

    super.dispose();
  }
}
