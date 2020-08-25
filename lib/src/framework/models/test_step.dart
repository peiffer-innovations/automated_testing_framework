import 'dart:convert';
import 'dart:typed_data';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// Describes a single step in a test.  A test step is required to have an [id]
/// which is the human-readable key for the test step.  It has an optional
/// [image] that is a capture of the widget for reference.  Finally, it has an
/// optional set of [values] that configure the step.
@immutable
class TestStep extends JsonClass {
  TestStep({
    this.id,
    this.image,
    this.values,
  });

  /// Human readable identifer for the test step.
  final String id;

  /// Optional image that shows an example of the widget involved with the step.
  final Uint8List image;

  /// Guaranteed unique key for the step.  This is meant for internal use to
  /// ensure widgets that represent the widget can be correctly, and uniquely,
  /// identified by Flutter's widget builder.  This is not meant for external
  /// consumption as it is guaranteed to be unique with every object instance.
  final String key = Uuid().v4();

  /// The map of key / value pairs that are utilized by the step.  This map will
  /// be different based on the step's [id].
  final Map<String, dynamic> values;

  /// Converts a JSON-like object to a [TestStep].  Whie this accepts a
  /// [dynamic], that is because different frameworks provide different types of
  /// JSON-like objects.  So long as the given [map] implements the `[]`
  /// operator, this will work.  A value of [null] will result in [null] being
  /// returned and an object that does not suppor the `[]` operator will result
  /// in an exception being thrown.
  ///
  /// The optional [ignoreImages] param instructs the steps to ignore any
  /// [image] attribute.  This is useful if an application has a large number of
  /// tests that need to be run.  By ignoring the images, a lot of memory can
  /// be saved.
  ///
  /// This expects a JSON-like map object of the following format:
  /// ```json
  /// {
  ///   "id": <String>,
  ///   "image": <String; base64 encoded>,
  ///   "values": <Map<String, dynamic>>
  /// }
  /// ```
  static TestStep fromDynamic(
    dynamic map, {
    bool ignoreImages = false,
  }) {
    TestStep result;

    if (map != null) {
      result = TestStep(
        id: map['id'],
        image: map['image'] == null || ignoreImages == true
            ? null
            : base64Decode(map['image']),
        values: map['values'] == null
            ? null
            : Map<String, dynamic>.from(map['values']),
      );
    }

    return result;
  }

  /// Copies the current test step with the values provided.  The values from
  /// the original object will only be overwritten by any values from non-null
  /// passed in objects.
  TestStep copyWith({
    String id,
    Uint8List image,
    Map<String, dynamic> values,
  }) =>
      TestStep(
        id: id ?? this.id,
        image: image ?? this.image,
        values: values ?? this.values,
      );

  /// Returns a JSON-compatible representation of the internal data structure.
  /// For the returned format, see the [fromDynamic] function.
  @override
  Map<String, dynamic> toJson() => {
        if (id?.isNotEmpty == true) 'id': id,
        if (image != null) 'image': base64Encode(image),
        if (values?.isNotEmpty == true) 'values': values,
      };
}
