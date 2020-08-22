import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

typedef TestReader = Future<List<Test>> Function(BuildContext context);
