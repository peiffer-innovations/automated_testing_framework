import 'dart:core';
import 'dart:math' as math;

double bound01(double n, double max) {
  n = max == 360.0 ? n : math.min(max, math.max(0.0, n));
  final absDifference = n - max;
  if (absDifference.abs() < 0.000001) {
    return 1.0;
  }

  if (max == 360) {
    n = (n < 0 ? n % max + max : n % max) / max;
  } else {
    n = (n % max) / max;
  }
  return n;
}

double clamp01(double val) {
  return math.min(1.0, math.max(0.0, val));
}
