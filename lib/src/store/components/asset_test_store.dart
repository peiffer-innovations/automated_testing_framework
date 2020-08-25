import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetTestStore {
  static List<String> testAssets;

  static Future<List<PendingTest>> testReader(BuildContext context) async {
    var tests = <PendingTest>[];

    if (testAssets?.isNotEmpty == true) {
      for (var asset in testAssets) {
        try {
          var text = await rootBundle.loadString(asset);
          if (text?.isNotEmpty == true) {
            var parsed = json.decode(text);

            tests.addAll(TestStore.createMemoryTests(parsed));
          }
        } catch (e) {
          debugPrint(e);
          debugPrint(e.stack);
        }
      }
    }

    if (tests?.isEmpty == true) {
      tests = null;
    }
    return tests;
  }
}
