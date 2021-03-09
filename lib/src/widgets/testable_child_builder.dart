import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:child_builder/child_builder.dart';
import 'package:flutter/material.dart';

/// [ChildWidgetBuilder] that can be used to wrap child widgets with a
/// [Testable] widget.  This particular builder will only wrap the [child] if
/// the [child] has a [ValueKey] set on it.  In that case, the [Testable] will
/// be given the a new [ValueKey] with the value from the child's key prefixed
/// with `value_key_`.
Widget testableChildBuilder(BuildContext context, Widget child) {
  String? id;

  if (child.key != null && child.key is ValueKey) {
    var childKey = child.key as ValueKey<dynamic>;

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
