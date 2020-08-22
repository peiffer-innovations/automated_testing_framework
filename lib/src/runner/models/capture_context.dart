import 'package:meta/meta.dart';

@immutable
class CaptureContext {
  CaptureContext({
    @required this.devicePixelRatio,
    @required this.image,
  });

  final double devicePixelRatio;
  final List<int> image;
}
