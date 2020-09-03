import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:json_theme/json_theme.dart';

/// Test runner theme data that can be used to alter the appearance of the built
/// in test runner.
@immutable
class TestRunnerThemeData implements JsonClass {
  const TestRunnerThemeData({
    this.runnerOverlayColor = Colors.black26,
    this.showRunnerStatus = kDebugMode == true,
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

  /// Default theme for dark mode.
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

  /// The color of the overlay (or backdrop) the runner will display on top of
  /// the application.
  final Color runnerOverlayColor;

  /// Set to [true] to show the test runner status and [false] otherwise.
  final bool showRunnerStatus;

  /// Set to [true] to show the test steps as they happen and [false] to hide
  /// the test steps to fall back to a minimally sized progress bar.
  final bool showStepText;

  /// The alignment for where the tests status bar will be displayed.
  final TestStatusAlignment statusAlignment;

  /// The background color for the test status bar.
  final Color statusBackgroundColor;

  /// The color to display when the current progress will result in an error if
  /// completed.
  final Color statusErrorColor;

  /// The opacity of the overall status bar.
  final double statusOpacity;

  /// The color to display to indicate the how far along the the test is in its
  /// execution.
  final Color statusProgressColor;

  /// The color to display to indicate the test step is a success step if the
  /// progress completes.
  final Color statusSuccessColor;

  /// The color of the status text.
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

/// Alignment for the test status bar.
class TestStatusAlignment {
  const TestStatusAlignment._(this._code);

  /// Aligns the test status bar at the very bottom of the screen.
  static const bottom = TestStatusAlignment._('bottom');

  /// Aligns the test status bar at the bottom of the screen, but is padded so
  /// that it renders above any system UI.
  static const bottomSafe = TestStatusAlignment._('bottomSafe');

  /// Aligns the test status bar at the center of the screen.
  static const center = TestStatusAlignment._('center');

  /// Aligns the test status bar at the top of the screen.
  static const top = TestStatusAlignment._('top');

  /// Aligns the test status bar at the top of the screen, but is padded so that
  /// it renders below any system UI.
  static const topSafe = TestStatusAlignment._('topSafe');

  /// Converts the alignment from a string to an actual object.  This will throw
  /// an exception if the string does not match any valid value.
  static TestStatusAlignment fromString(String data) {
    TestStatusAlignment result;

    if (data != null) {
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

  /// Returns the string representation of this alignment that can be safely
  /// passed to [fromString] to recreate the object.
  @override
  String toString() => _code;
}
