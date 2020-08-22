import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

class EnsureExistsStep extends TestRunnerStep {
  EnsureExistsStep({
    @required this.testableId,
    this.timeout,
  }) : assert(testableId?.isNotEmpty == true);

  final String testableId;
  final Duration timeout;

  static EnsureExistsStep fromDynamic(dynamic map) {
    EnsureExistsStep result;

    if (map != null) {
      result = EnsureExistsStep(
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
    var name = "ensureExists('$testableId')";
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

    var widgetFinder = finder.evaluate();
    if (widgetFinder?.isNotEmpty != true) {
      throw Exception('testableId: [$testableId] -- could not locate widget.');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
