import 'dart:math';
import 'package:meta/meta.dart';

/// PODO that holds the value of progress.  The progress can be anything.
@immutable
class ProgressValue {
  /// Creates the progress instance.
  ProgressValue({
    this.error = false,
    required this.max,
    required int value,
  })   : assert(max > 0),
        assert(value >= 0),
        value = min(value, max);

  /// Set to [true] if this progress will result in an error if it hits the
  /// complete stage.  Set to [false] otherwise.
  final bool error;

  /// The max value for the progress.  This must be 1 or higher.
  final int max;

  /// The current value for the progress.
  final int value;

  /// The one-based percent value for the progress.
  double get progress => value / max;
}
