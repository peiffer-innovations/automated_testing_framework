import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class SleepStep extends TestRunnerStep {
  SleepStep({
    @required this.timeout,
  })  : assert(timeout != null),
        assert(timeout.inMilliseconds >= 0);

  final Duration timeout;

  static SleepStep fromDynamic(dynamic map) {
    SleepStep result;

    if (map != null) {
      result = SleepStep(
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  @override
  Future<void> execute({
    TestReport report,
    @required TestController tester,
  }) =>
      sleep(
        timeout,
        tester: tester,
      );

  @override
  Map<String, dynamic> toJson() => {
        'timeout': timeout.inSeconds,
      };
}
