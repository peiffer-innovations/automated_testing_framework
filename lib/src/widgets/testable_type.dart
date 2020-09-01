import 'package:meta/meta.dart';

/// Enum-like class that describes the various capabilities of a [Testable]
@immutable
class TestableType {
  const TestableType._(this._code) : assert(_code != null);

  static const error_requestable = TestableType._('error_requestable');
  static const scrollable = TestableType._('scrollable');
  static const scrolled = TestableType._('scrolled');
  static const tappable = TestableType._('tappable');
  static const value_requestable = TestableType._('value_requestable');
  static const value_settable = TestableType._('value_settable');

  static const _all = [
    error_requestable,
    scrollable,
    scrolled,
    tappable,
    value_requestable,
    value_settable,
  ];

  final String _code;

  /// Gets the [TestableType] from the given string [code].  This will return
  /// [null] if the [code] is not one that is supported.
  static TestableType lookup(String code) => _all.firstWhere(
        (type) => type._code == code,
      );

  @override
  bool operator ==(other) => other is TestableType && other._code == _code;

  @override
  int get hashCode => _code.hashCode;
}
