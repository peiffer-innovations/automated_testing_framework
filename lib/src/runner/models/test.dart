import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

/// PODO for a test that can be executed.
class Test extends JsonClass {
  /// Constructs the test.
  Test({
    this.active = true,
    this.name,
    List<TestStep> steps,
    this.suiteName,
    this.version = 0,
  })  : assert(active != null),
        assert(version != null),
        steps = steps == null ? <TestStep>[] : List<TestStep>.from(steps);

  /// Sets whether or not this test is currently active.  The interal system
  /// will always create active tests but loaders may return inactive tests.
  final bool active;

  /// The name for the test
  final String name;

  /// The list of steps for the test
  final List<TestStep> steps;

  /// The name of the test suite this test is a part of; may be [null] or empty.
  final String suiteName;

  /// The test version.
  final int version;

  /// Creates a test from a map-like object.  The [map] must support the `[]`
  /// operator if it is not [null].
  ///
  /// This expects a JSON-like object in the following form:
  /// ```json
  /// {
  ///   "active": <bool>,
  ///   "name": <String>,
  ///   "steps": <List<TestStep>>
  /// }
  /// ```
  static Test fromDynamic(
    dynamic map, {
    bool ignoreImages = false,
  }) {
    Test result;

    if (map != null) {
      result = Test(
        active:
            map['active'] == null ? true : JsonClass.parseBool(map['active']),
        name: map['name'],
        steps: JsonClass.fromDynamicList(
            map['steps'],
            (map) => TestStep.fromDynamic(
                  map,
                  ignoreImages: ignoreImages,
                )),
        suiteName: map['suiteName'],
        version: JsonClass.parseInt(map['version'], 1),
      );
    }

    return result;
  }

  /// Adds a test step to this test.
  void addTestStep(TestStep step) => steps.add(step);

  /// Clears all test steps from this test.
  void clearTestSteps() => steps.clear;

  /// Returns the id of the test which is a concatenation of the suite
  /// name and the test name.
  String get id =>
      '${(suiteName?.isNotEmpty == true ? '${suiteName}__' : '')}$name';

  /// Copies this test with the given values.
  Test copyWith({
    bool active,
    String name,
    List<TestStep> steps,
    String suiteName,
    int version,
  }) =>
      Test(
        active: active ?? this.active,
        name: name ?? this.name,
        steps: steps ?? this.steps,
        suiteName: suiteName ?? this.suiteName,
        version: version ?? this.version,
      );

  /// Converts this test to a JSON compatible format.  See [fromDynamic] for the
  /// structure.
  @override
  Map<String, dynamic> toJson() => {
        'active': active,
        'name': name ?? '<unnammed>',
        'steps': JsonClass.toJsonList(steps),
        'suiteName': suiteName,
        'version': version,
      };
}
