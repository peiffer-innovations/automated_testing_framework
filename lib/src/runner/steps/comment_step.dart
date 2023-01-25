import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:json_class/json_class.dart';

/// Technically not a step but is instead a place where testers can put comments
/// into the test.  Comments will be emitted into the logs in addition to being
/// viewable in the test editor itself.
class CommentStep extends TestRunnerStep {
  CommentStep({
    required this.comment,
  });

  static const id = 'comment';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        'write the comment "`{{comment}}`" to the log.',
      ]);

  /// The comment to put in the test.
  final String comment;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "comment": <String>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  static CommentStep? fromDynamic(dynamic map) {
    CommentStep? result;

    if (map != null) {
      result = CommentStep(
        comment: map['comment'],
      );
    }

    return result;
  }

  /// Attempts to locate the [Testable] identified by the [testableId] and will
  /// then set the associated [value] to the found widget.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    final comment = tester.resolveVariable(this.comment)?.toString() ?? '';
    final name = "$id('$comment')";

    log(
      name,
      tester: tester,
    );
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) =>
      behaviorDrivenDescriptions[0].replaceAll(
        '{{comment}}',
        comment,
      );

  @override
  Future<void> postStepSleep(Duration duration) async {}

  @override
  Future<void> preStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'comment': comment,
      };
}
