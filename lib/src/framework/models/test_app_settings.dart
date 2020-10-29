import 'package:meta/meta.dart';

/// Provides settings for the test app that apply globaly.  Any settings set
/// here will globally override values from other parts of the framework.
@immutable
class TestAppSettings {
  TestAppSettings._({
    this.appIdentifier,
  });

  static TestAppSettings _settings;

  /// The unique identifier for the application.  This can be anything
  /// meaningful for the application.  It can be the application's name, the
  /// bundle id, etc.
  final String appIdentifier;

  static TestAppSettings get settings => _settings ?? TestAppSettings._();

  static void initialize({
    String appIdentifier,
  }) =>
      _settings = TestAppSettings._(
        appIdentifier: appIdentifier,
      );
}
