import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:static_translations/static_translations.dart';

/// Describes an automated test step.  Custom test steps must register with the
/// [TestStepRegistry] and create an instance of this class.  This binds the
/// input form, any quick-add values, the help and title translation entities,
/// and the requirements of the step that determines if the step will show or
/// not given the current constraints.
@immutable
class AvailableTestStep {
  const AvailableTestStep({
    required this.form,
    this.keys = const <String>{},
    required this.help,
    required this.id,
    this.quickAddValues,
    required this.title,
    this.type,
    required this.widgetless,
  });

  /// Binds the input form associated with the test step.  This must
  /// self-validate and ensure all required values exist before allowing
  /// submission.
  final TestStepForm form;

  /// Translation key for the help text that describes the test step.
  final TranslationEntry help;

  /// The unique set of value keys supported by the step.  Entries in the
  /// `values` map that do not have an associated key must be removed before
  /// final processing is complete.
  final Set<String> keys;

  /// The id / human readable string for this particular step.  Built-in values
  /// all use a `lower_under_lower` format for the keys rather than a
  /// `camelCase` format.  However, custom steps may use whichever form they
  /// prefer.
  final String id;

  /// Map of key / value pairs that can be used to quick add (form less add) the
  /// step to a test.  This must be `null` if forms are always required to be
  /// filled out before adding the step.
  final Map<String, dynamic>? quickAddValues;

  /// Translation key for the title text that tescribes the test step.
  final TranslationEntry title;

  /// The type value that the [Testable] must support or else this step will be
  /// hidden from the available options.  If this is not set then it is assumed
  /// the test supports all types.
  ///
  /// This will be ignored whenever [widgetless] is set to [true].
  final TestableType? type;

  /// Sets whether this step is dependent on a [Testable] widget or not.  If
  /// this value is [true] then it is assumed the step is [Testable] agnostic
  /// and can be used anywhere in the application.  If [false] then it the step
  /// will only be shown for compatible [type] values.
  final bool widgetless;

  /// Requests the step to minify the given [values] map by stripping any key /
  /// value pairs that exist in the map but are not allowed by the step.
  Map<String, dynamic> minify(Map<String, dynamic> values) =>
      values..removeWhere((key, value) => !keys.contains(key) || value == null);

  /// Returns [true] if this step supports any of the given [types] or if this
  /// step has no specific type requirement.  Returns [false] if this has a type
  /// requirement that the [Testable] does not support the required type.
  bool supports(List<TestableType>? types) {
    var supported = types?.isNotEmpty != true || type == null;

    if (supported != true) {
      types!.forEach(
        (type) => supported = supported || type == this.type,
      );
    }

    return supported;
  }
}
