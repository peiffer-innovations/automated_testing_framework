import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

/// Represents an image from a test.
@immutable
class TestImage extends JsonClass {
  TestImage({
    int captureTime,
    @required this.goldenCompatible,
    String hash,
    @required this.id,
    @required this.image,
  })  : assert(goldenCompatible != null),
        assert(id?.isNotEmpty == true),
        captureTime = captureTime ?? DateTime.now().millisecondsSinceEpoch,
        hash = hash ?? sha256.convert(image ?? [0]).toString();

  static TestImage fromDynamic(dynamic map) {
    TestImage result;

    if (map != null) {
      result = TestImage(
        captureTime: JsonClass.parseInt(map['captureTime']),
        goldenCompatible: JsonClass.parseBool(map['goldenCompatible']),
        hash: map['hash'],
        id: map['id'],
        image: map['image'] == null ? null : base64.decode(map['image']),
      );
    }

    return result;
  }

  static List<Map<String, dynamic>> toJsonList(
    List<TestImage> images, [
    bool includeImageData = false,
  ]) {
    List<Map<String, dynamic>> result;

    if (images != null) {
      result = <Map<String, dynamic>>[];

      for (var image in images) {
        result.add(image.toJson(includeImageData));
      }
    }

    return result;
  }

  /// The time the image was captured in UTC Millis.
  final int captureTime;

  /// Set to [true] if this image can be saved as a golden image.  Set to
  /// [false] if it contains dynamic data that can't be automatically handled
  /// and is meant to be manually reviewed instead.
  final bool goldenCompatible;

  /// A sha256 hash of the image bytes
  final String hash;

  /// The identifier for the screenshot
  final String id;

  /// The actual bytes from the image.
  final Uint8List image;

  @override
  Map<String, dynamic> toJson([bool includeImageData = false]) => {
        'captureTime': captureTime,
        'goldenCompatible': goldenCompatible,
        'hash': hash,
        'id': id,
        if (includeImageData == true) 'image': base64.encode(image),
      };
}
