import 'package:meta/meta.dart';

/// PODO that simply holds the request for a screen capture with the device
/// pixel ratio and the resulting image bytes.
@immutable
class CaptureContext {
  CaptureContext({
    @required this.devicePixelRatio,
    @required this.image,
  });

  /// The device pixel ratio to use when requesting the screen capture.
  final double devicePixelRatio;

  /// The resulting image from the screen capture.
  final List<int> image;
}
