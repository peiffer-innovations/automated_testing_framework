import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

class Test extends JsonClass {
  Test({
    this.active = true,
    this.name,
    List<TestStep> steps,
    this.version = 1,
  })  : assert(active != null),
        assert(version != null),
        steps = steps == null ? <TestStep>[] : List<TestStep>.from(steps);

  final bool active;
  final String name;
  final List<TestStep> steps;
  final int version;

  static Test fromDynamic(dynamic map) {
    Test result;

    if (map != null) {
      result = Test(
        active:
            map['active'] == null ? true : JsonClass.parseBool(map['active']),
        name: map['name'],
        steps: JsonClass.fromDynamicList(
            map['steps'], (map) => TestStep.fromDynamic(map)),
        version: JsonClass.parseInt(map['version'], 1),
      );
    }

    return result;
  }

  void addTestStep(TestStep step) => steps.add(step);
  void clearTestSteps() => steps.clear;

  Test copyWith({
    bool active,
    String name,
    List<TestStep> steps,
    int version,
  }) =>
      Test(
        active: active ?? this.active,
        name: name ?? this.name,
        steps: steps ?? this.steps,
        version: version ?? this.version,
      );

  @override
  Map<String, dynamic> toJson() => {
        'active': active,
        'name': name ?? '<unnammed>',
        'steps': JsonClass.toJsonList(steps),
        'version': version,
      };
}
