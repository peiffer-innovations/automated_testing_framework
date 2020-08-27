import 'package:meta/meta.dart';

@immutable
class TestableType {
  const TestableType._(this.code) : assert(code != null);

  final String code;

  static const error_requestable = TestableType._('error_requestable');
  static const long_pressable = TestableType._('long_pressable');
  static const scrollable = TestableType._('scrollable');
  static const scrolled = TestableType._('scrolled');
  static const tappable = TestableType._('tappable');
  static const value_requestable = TestableType._('value_requestable');
  static const value_settable = TestableType._('value_settable');

  static const _all = [
    error_requestable,
    long_pressable,
    scrollable,
    scrolled,
    tappable,
    value_requestable,
    value_settable,
  ];

  static TestableType lookup(String code) => _all.firstWhere(
        (type) => type.code == code,
      );

  @override
  bool operator ==(other) => other is TestableType && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
