import 'dart:typed_data';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

/// Reader to load a golden image from a data store and return it for
/// comparison.  If [testVersion] is omitted, this should default to the highest
/// version listed in the golden file.
typedef TestImageReader = Future<Uint8List> Function({
  @required TestDeviceInfo deviceInfo,
  @required String imageId,
  String suiteName,
  @required String testName,
  int testVersion,
});
