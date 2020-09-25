import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// The result for an executed test step.  It's important to note that times in
/// the report are relative to each run and should not be thought of in absolute
/// terms.  Too many variables such as animations, built in delays, etc. can
/// cause an individual test step to take 1-2 seconds despite a perceived
/// expectation that something should be sub-second.  When comparing the times,
/// do so only across tests and look for trends.  Avoid the temptation to look
/// at the times as absolutes.
class TestReportStep extends JsonClass {
  TestReportStep({
    this.endTime,
    this.error,
    @required this.id,
    DateTime startTime,
    @required this.step,
    @required this.subStep,
  })  : assert(id?.isNotEmpty == true),
        assert(subStep != null),
        startTime = startTime ?? DateTime.now();

  /// The date time that the step completed.
  final DateTime endTime;

  /// Any error description if an error happened.  Will be [null] if, and only
  /// if, the step passed.
  final String error;

  /// The id of the test step.
  final String id;

  /// The start date time for when the test step execution began.
  final DateTime startTime;

  /// The values from the test step.
  final Map<String, dynamic> step;

  /// Set to [true] if this represents a step executed by another step or
  /// [false] if the step is a top-level test step directly executed by the
  /// framework.
  final bool subStep;

  static TestReportStep fromDynamic(dynamic map) {
    TestReportStep result;

    if (map != null) {
      result = TestReportStep(
        endTime: JsonClass.parseUtcMillis(map['endTime']),
        error: map['error'],
        id: map['id'],
        startTime: JsonClass.parseUtcMillis(map['startTime']),
        step:
            map['step'] == null ? null : Map<String, dynamic>.from(map['step']),
        subStep: JsonClass.parseBool(map['subStep']),
      );
    }

    return result;
  }

  /// Copies the report entry with the given values.
  TestReportStep copyWith({
    DateTime endTime,
    String error,
    Map<String, dynamic> step,
    DateTime startTime,
    bool subStep,
  }) =>
      TestReportStep(
        endTime: endTime ?? this.endTime,
        error: error ?? this.error,
        id: id,
        startTime: startTime ?? this.startTime,
        step: step ?? this.step,
        subStep: subStep ?? this.subStep,
      );

  /// Converts the report entry to a JSON compatible representation.
  @override
  Map<String, dynamic> toJson() => {
        'endTime': endTime?.millisecondsSinceEpoch,
        'error': error,
        'id': id,
        'startTime': startTime?.millisecondsSinceEpoch,
        'step': step,
        'subStep': subStep,
      };
}
