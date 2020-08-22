import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class TestReportStep extends JsonClass {
  TestReportStep({
    this.endTime,
    this.error,
    @required this.id,
    @required this.step,
    DateTime startTime,
  }) : startTime = startTime ?? DateTime.now();

  final DateTime endTime;
  final String error;
  final String id;
  final DateTime startTime;
  final Map<String, dynamic> step;

  TestReportStep copyWith({
    DateTime endTime,
    String error,
    Map<String, dynamic> step,
    DateTime startTime,
  }) =>
      TestReportStep(
        endTime: endTime ?? this.endTime,
        error: error ?? this.error,
        id: id,
        startTime: startTime ?? this.startTime,
        step: step ?? this.step,
      );

  @override
  Map<String, dynamic> toJson() => {
        'endTime': endTime?.millisecondsSinceEpoch,
        'error': error,
        'id': id,
        'startTime': startTime?.millisecondsSinceEpoch,
        'step': step,
      };
}
