import 'dart:async';
import 'dart:ui';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:json_class/json_class.dart';

/// Test step that asserts that the value equals (or does not equal) a specific
/// value.
class AssertSemanticsStep extends TestRunnerStep {
  AssertSemanticsStep({
    required this.field,
    required this.testableId,
    this.timeout,
    required this.value,
  }) : assert(testableId.isNotEmpty == true);

  static const id = 'assert_semantics';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        "assert that the `{{testableId}}` widget's semantic `{{field}}` is `{{value}}` and fail if the widget cannot be found in `{{timeout}}` seconds.",
        "assert that the `{{testableId}}` widget's semantic `{{field}}` is `{{value}}`.",
      ]);

  final String field;

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration? timeout;

  final String? value;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "field": <String>,
  ///   "testableId": <String>,
  ///   "timeout": <number>,
  ///   "value": <String>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseBool]
  /// * [JsonClass.parseDurationFromSeconds]
  static AssertSemanticsStep? fromDynamic(dynamic map) {
    AssertSemanticsStep? result;

    if (map != null) {
      result = AssertSemanticsStep(
        field: map['field'],
        testableId: map['testableId']!,
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
        value: map['value']?.toString(),
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the [Testable], get the value
  /// of the appropriate semantic field from the [Testable], then compare that
  /// value against the set [value].
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    if (kReleaseMode) {
      throw Exception('$id does not support running in Release Mode.');
    }

    var semanticsHandle =
        WidgetsBinding.instance!.pipelineOwner.ensureSemantics();

    try {
      String? testableId = tester.resolveVariable(this.testableId);
      var value = tester.resolveVariable(this.value)?.toString();
      assert(testableId?.isNotEmpty == true);

      var name = "$id('$field', '$testableId', '$value')";
      log(
        name,
        tester: tester,
      );
      var finder = await waitFor(
        testableId,
        cancelToken: cancelToken,
        tester: tester,
        timeout: timeout,
      );

      await sleep(
        tester.delays.postFoundWidget,
        cancelStream: cancelToken.stream,
        tester: tester,
      );

      if (cancelToken.cancelled == true) {
        throw Exception('[CANCELLED]: step was cancelled by the test');
      }

      var widgetFinder = finder.evaluate();
      String? actual;
      var match = false;
      if (widgetFinder.isNotEmpty == true) {
        widgetFinder = finder.evaluate();

        var element = widgetFinder.first;
        var renderObject = element.renderObject!;

        var node = _getSemantics(renderObject);
        var data = node.getSemanticsData();
        var flags = data.flags;

        switch (field) {
          case 'currentValueLength':
            actual = data.currentValueLength.toString();
            break;
          case 'decreasedValue':
            actual = data.decreasedValue;
            break;
          case 'elevation':
            actual = data.elevation.toString();
            break;
          case 'hasImplicitScrolling':
            actual = (flags & SemanticsFlag.hasImplicitScrolling.index != 0)
                .toString();
            break;
          case 'hint':
            actual = data.hint.toString();
            break;
          case 'increasedValue':
            actual = data.increasedValue.toString();
            break;
          case 'isButton':
            actual = (flags & SemanticsFlag.isButton.index != 0).toString();
            break;
          case 'isChecked':
            actual = (flags & SemanticsFlag.isChecked.index != 0).toString();
            break;
          case 'isEnabled':
            actual = (flags & SemanticsFlag.isEnabled.index != 0).toString();
            break;
          case 'isFocusable':
            (flags & SemanticsFlag.isFocusable.index != 0).toString();
            break;
          case 'isFocused':
            actual = (flags & SemanticsFlag.isFocused.index != 0).toString();
            break;
          case 'isHeader':
            actual = (flags & SemanticsFlag.isHeader.index != 0).toString();
            break;
          case 'isHidden':
            actual = (flags & SemanticsFlag.isHidden.index != 0).toString();
            break;
          case 'isImage':
            actual = (flags & SemanticsFlag.isImage.index != 0).toString();
            break;
          case 'isInMutuallyExclusiveGroup':
            actual =
                (flags & SemanticsFlag.isInMutuallyExclusiveGroup.index != 0)
                    .toString();
            break;
          case 'isKeyboardKey':
            actual =
                (flags & SemanticsFlag.isKeyboardKey.index != 0).toString();
            break;
          case 'isLink':
            actual = (flags & SemanticsFlag.isLink.index != 0).toString();
            break;
          case 'isMultiline':
            actual = (flags & SemanticsFlag.isMultiline.index != 0).toString();
            break;
          case 'isObscured':
            actual = (flags & SemanticsFlag.isObscured.index != 0).toString();
            break;
          case 'isReadOnly':
            actual = (flags & SemanticsFlag.isReadOnly.index != 0).toString();
            break;
          case 'isSelected':
            actual = (flags & SemanticsFlag.isSelected.index != 0).toString();
            break;
          case 'isSlider':
            actual = (flags & SemanticsFlag.isSlider.index != 0).toString();
            break;
          case 'isTextField':
            actual = (flags & SemanticsFlag.isTextField.index != 0).toString();
            break;
          case 'isToggled':
            actual = (flags & SemanticsFlag.isToggled.index != 0).toString();
            break;
          case 'label':
            actual = data.label.toString();
            break;
          case 'maxValueLength':
            actual = data.maxValueLength.toString();
            break;
          case 'scrollChildCount':
            actual = data.scrollChildCount.toString();
            break;
          case 'scrollExtentMax':
            actual = data.scrollExtentMax.toString();
            break;
          case 'scrollExtentMin':
            actual = data.scrollExtentMin.toString();
            break;
          case 'scrollIndex':
            actual = data.scrollIndex.toString();
            break;
          case 'scrollPosition':
            actual = data.scrollPosition.toString();
            break;
          case 'thickness':
            actual = data.thickness.toString();
            break;
          case 'value':
            actual = data.value.toString();
            break;

          default:
            throw Exception('Unknown field: [$field]');
        }

        match = actual == value;
      }
      if (match != true) {
        throw Exception(
          'testableId: [$testableId] -- actualValue: [$actual] != [$value].',
        );
      }
    } finally {
      semanticsHandle.dispose();
    }
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) {
    String result;

    if (timeout == null) {
      result = behaviorDrivenDescriptions[1];
    } else {
      result = behaviorDrivenDescriptions[0];
      result = result.replaceAll(
        '{{timeout}}',
        timeout!.inSeconds.toString(),
      );
    }

    result = result.replaceAll('{{field}}', field);
    result = result.replaceAll('{{testableId}}', testableId);
    result = result.replaceAll('{{value}}', value ?? 'null');

    return result;
  }

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'field': field,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
        'value': value,
      };

  SemanticsNode _getSemantics(RenderObject child) {
    var result = SemanticsNode();

    var children = <SemanticsNode>[];

    _popupateSemanticsFromChildren(child, children);

    var reversed = children.reversed.toList();

    result.updateWith(config: null, childrenInInversePaintOrder: reversed);

    SemanticsNode? firstChild;

    result.visitChildren((node) {
      firstChild ??= node;
      return false;
    });

    return firstChild ?? result;
  }

  void _popupateSemanticsFromChildren(
      RenderObject child, List<SemanticsNode> children) {
    var node = child.debugSemantics;

    if (node != null) {
      children.add(node);
    }

    child.visitChildrenForSemantics((child) {
      _popupateSemanticsFromChildren(child, children);
    });
  }
}
