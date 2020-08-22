import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

Widget testableChildBuilder(BuildContext context, Widget child) {
  String id;

  if (child.key != null && child.key is ValueKey) {
    ValueKey childKey = child.key;

    if (childKey.value is String) {
      id = 'value_key_${childKey.value}';
    }
  }

  return id == null
      ? child
      : Testable(
          id: id,
          child: child,
        );
}
