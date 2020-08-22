import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class TapStep extends TestRunnerStep {
  TapStep({
    @required this.testableId,
    this.timeout,
  }) : assert(testableId?.isNotEmpty == true);

  final String testableId;
  final Duration timeout;

  static TapStep fromDynamic(dynamic map) {
    TapStep result;

    if (map != null) {
      result = TapStep(
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    var name = "tap('$testableId')";
    log(
      name,
      tester: tester,
    );

    var finder = await waitFor(
      testableId,
      tester: tester,
      timeout: timeout,
    );

    await sleep(
      tester.delays.postFoundWidget,
      tester: tester,
    );

    await driver.tap(finder);
  }

  @override
  Map<String, dynamic> toJson() => {
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
