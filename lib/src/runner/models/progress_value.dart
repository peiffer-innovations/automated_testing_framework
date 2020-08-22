import 'dart:math';
import 'package:meta/meta.dart';

@immutable
class ProgressValue {
  ProgressValue({
    this.error = false,
    @required this.max,
    @required int value,
  })  : assert(error != null),
        assert(max != null),
        assert(value != null),
        assert(max > 0),
        assert(value >= 0),
        value = min(value, max);

  final bool error;
  final int max;
  final int value;

  double get progress => value / max;
}
