import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:json_theme/json_theme.dart';

/// Test runner theme data
@immutable
class TestRunnerThemeData implements JsonClass {
  const TestRunnerThemeData({
    this.runnerOverlayColor = Colors.black26,
    this.showRunnerStatus = kReleaseMode != true,
    this.showStepText = false,
    this.statusAlignment = TestStatusAlignment.bottom,
    this.statusBackgroundColor = Colors.black45,
    this.statusErrorColor = Colors.red,
    this.statusOpacity = 0.4,
    this.statusProgressColor = Colors.black,
    this.statusSuccessColor = Colors.green,
    this.statusTextColor = Colors.white,
  })  : assert(runnerOverlayColor != null),
        assert(showRunnerStatus != null),
        assert(showStepText != null),
        assert(statusAlignment != null),
        assert(statusBackgroundColor != null),
        assert(statusErrorColor != null),
        assert(statusOpacity != null),
        assert(statusOpacity >= 0.0 && statusOpacity <= 1.0),
        assert(statusProgressColor != null),
        assert(statusSuccessColor != null),
        assert(statusTextColor != null);

  factory TestRunnerThemeData.dark({
    Color runnerOverlayColor = Colors.white24,
    bool showRunnerStatus = kReleaseMode != true,
    bool showStepText = false,
    TestStatusAlignment statusAlignment = TestStatusAlignment.bottom,
    Color statusBackgroundColor = Colors.white54,
    Color statusErrorColor = const Color(0xFFE57373),
    double statusOpacity = 0.4,
    Color statusProgressColor = Colors.white,
    Color statusSuccessColor = const Color(0xFF81C784),
    Color statusTextColor = Colors.black,
  }) =>
      TestRunnerThemeData(
        runnerOverlayColor: runnerOverlayColor,
        showRunnerStatus: showRunnerStatus,
        showStepText: showStepText,
        statusAlignment: statusAlignment,
        statusBackgroundColor: statusBackgroundColor,
        statusErrorColor: statusErrorColor,
        statusOpacity: statusOpacity,
        statusProgressColor: statusProgressColor,
        statusSuccessColor: statusSuccessColor,
        statusTextColor: statusTextColor,
      );

  final Color runnerOverlayColor;
  final bool showRunnerStatus;
  final bool showStepText;
  final TestStatusAlignment statusAlignment;
  final Color statusBackgroundColor;
  final Color statusErrorColor;
  final double statusOpacity;
  final Color statusProgressColor;
  final Color statusSuccessColor;
  final Color statusTextColor;

  @override
  bool operator ==(dynamic other) =>
      other is TestRunnerThemeData &&
      other.runnerOverlayColor == runnerOverlayColor &&
      other.showRunnerStatus == showRunnerStatus &&
      other.showStepText == showStepText &&
      other.statusAlignment == statusAlignment &&
      other.statusBackgroundColor == statusBackgroundColor &&
      other.statusErrorColor == statusErrorColor &&
      other.statusOpacity == statusOpacity &&
      other.statusProgressColor == statusProgressColor &&
      other.statusSuccessColor == statusSuccessColor &&
      other.statusTextColor == statusTextColor;

  @override
  int get hashCode => hashValues(
        runnerOverlayColor,
        showRunnerStatus,
        showStepText,
        statusAlignment,
        statusBackgroundColor,
        statusErrorColor,
        statusOpacity,
        statusProgressColor,
        statusSuccessColor,
        statusTextColor,
      );

  /// Creates a theme data object from a JSON compatible map.  This expects the
  /// JSON to follow the format:
  ///
  /// ```json
  /// {
  ///   "runnerOverlayColor": <Color>,
  ///   "showRunnerStatus": <bool>,
  ///   "showStepText": <bool>,
  ///   "statusAlignment": <TestStatusAlignment>,
  ///   "statusBackgroundColor": <Color>,
  ///   "statusErrorColor": <Color>,
  ///   "statusOpacity": <double>,
  ///   "statusProgressColor": <Color>,
  ///   "statusSuccessColor": <Color>,
  ///   "statusTextColor": <Color>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseBool]
  /// * [JsonClass.parseDouble]
  /// * [ThemeDecoder.decodeColor]
  /// * [TestStatusAlignment.fromString]
  static TestRunnerThemeData fromDynamic(dynamic map) {
    TestRunnerThemeData result;

    if (map != null) {
      result = TestRunnerThemeData(
        runnerOverlayColor: ThemeDecoder.decodeColor(map['runnerOverlayColor']),
        showRunnerStatus: JsonClass.parseBool(map['showRunnerStatus']),
        showStepText: JsonClass.parseBool(map['showStepText']),
        statusAlignment: TestStatusAlignment.fromString(map['statusAlignment']),
        statusBackgroundColor:
            ThemeDecoder.decodeColor(map['statusBackgroundColor']),
        statusErrorColor: ThemeDecoder.decodeColor(map['statusErrorColor']),
        statusOpacity: JsonClass.parseDouble(map['statusOpacity']),
        statusProgressColor:
            ThemeDecoder.decodeColor(map['statusProgressColor']),
        statusSuccessColor: ThemeDecoder.decodeColor(map['statusSuccessColor']),
        statusTextColor: ThemeDecoder.decodeColor(map['statusTextColor']),
      );
    }

    return result;
  }

  /// Encodees the object to JSON.  For the format, see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'runnerOverlayColor': ThemeEncoder.encodeColor(runnerOverlayColor),
        'showRunnerStatus': showRunnerStatus,
        'showStepText': showStepText,
        'statusAlignment': statusAlignment.toString(),
        'statusBackgroundColor':
            ThemeEncoder.encodeColor(statusBackgroundColor),
        'statusErrorColor': ThemeEncoder.encodeColor(statusErrorColor),
        'statusOpacity': statusOpacity,
        'statusProgressColor': ThemeEncoder.encodeColor(statusProgressColor),
        'statusSuccessColor': ThemeEncoder.encodeColor(statusSuccessColor),
        'statusTextColor': ThemeEncoder.encodeColor(statusTextColor),
      };
}

class TestStatusAlignment {
  const TestStatusAlignment._(this._code);
  static const bottom = TestStatusAlignment._('bottom');
  static const bottomSafe = TestStatusAlignment._('bottomSafe');
  static const center = TestStatusAlignment._('center');
  static const none = TestStatusAlignment._('none');
  static const top = TestStatusAlignment._('top');
  static const topSafe = TestStatusAlignment._('topSafe');

  static TestStatusAlignment fromString(String data) {
    TestStatusAlignment result;

    if (data == null) {
      result = TestStatusAlignment.none;
    } else {
      switch (data) {
        case 'bottom':
          result = TestStatusAlignment.bottom;
          break;
        case 'bottomSafe':
          result = TestStatusAlignment.bottomSafe;
          break;
        case 'center':
          result = TestStatusAlignment.center;
          break;
        case 'none':
          result = TestStatusAlignment.none;
          break;
        case 'top':
          result = TestStatusAlignment.top;
          break;
        case 'topSafe':
          result = TestStatusAlignment.topSafe;
          break;
      }
    }

    if (result == null) {
      throw Exception(
        'No matching TestStatusAlignment exists for value: [$data].',
      );
    }
    return result;
  }

  final String _code;

  @override
  String toString() => _code;
}
