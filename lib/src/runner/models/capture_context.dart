import 'package:meta/meta.dart';

/// PODO that simply holds the request for a screen capture.
@immutable
class CaptureContext {
  CaptureContext({
    @required this.image,
  });

  /// The resulting image from the screen capture.
  final List<int> image;
}
