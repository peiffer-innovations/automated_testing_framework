import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

typedef TestWriter = Future<bool> Function(BuildContext context, Test test);
