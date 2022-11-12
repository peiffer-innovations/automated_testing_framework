import 'dart:async';
import 'dart:io';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

/// Container class for the device information for the device the test is being
/// executed on.
@immutable
class TestDeviceInfoHelper {
  static Completer<TestDeviceInfo>? _completer;
  static TestDeviceInfo? _instance;

  static Future<TestDeviceInfo> initialize(BuildContext? context) async {
    var result = _instance;

    while (_completer != null) {
      await _completer!.future;
    }
    result = _instance;

    if (result == null || (context != null && result.dips == null)) {
      _completer = Completer<TestDeviceInfo>();

      var appIdentifier = '<unknown>';
      late String brand;
      var buildNumber = '<unknown>';
      late String device;
      double? devicePixelRatio;
      BaseSize? dips;
      var id = Uuid().v4();
      late String manufacturer;
      late String model;
      late String os;
      String? orientation;
      late bool physicalDevice;
      BaseSize? pixels;
      late String systemVersion;

      var plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        var info = await plugin.webBrowserInfo;
        brand = info.browserName.name;
        device = info.appName ?? '<unknown>';
        manufacturer = info.vendor ?? '<unknown>';
        model = info.userAgent ?? '<unknown>';
        physicalDevice = true;
        os = 'web';
        systemVersion = info.platform ?? '<unknown>';
      } else {
        try {
          var pInfo = await PackageInfo.fromPlatform();
          appIdentifier = pInfo.appName;
          buildNumber = pInfo.buildNumber;
        } catch (e) {
          // No-op; don't fail because we can't get the build number.
        }
        if (Platform.isAndroid) {
          os = 'android';

          try {
            var info = await plugin.androidInfo;

            brand = info.brand;
            device = info.device;
            manufacturer = info.manufacturer;
            model = info.model;
            physicalDevice = info.isPhysicalDevice;
            systemVersion = '${info.version.sdkInt}';
          } catch (e) {
            // No-op; don't fail because we can't get the device info.
          }
        } else if (Platform.isIOS) {
          brand = 'apple';
          manufacturer = 'apple';
          os = 'ios';

          try {
            var info = await plugin.iosInfo;

            device = info.name ?? 'unknown';
            model = info.model ?? 'unknown';
            physicalDevice = info.isPhysicalDevice;
            systemVersion = info.systemVersion ?? 'unknown';
          } catch (e) {
            // No-op; don't fail because we can't get the device info.
          }
        } else if (Platform.isFuchsia) {
          brand = '<unknown>';
          device = '<unknown>';
          manufacturer = '<unknown>';
          model = '<unknown>';
          physicalDevice = true;
          os = 'fuchsia';
          systemVersion = '<unknown>';
        } else if (Platform.isLinux) {
          var info = await plugin.linuxInfo;

          brand = info.id;
          device = info.name;
          manufacturer = info.variant ?? '<unknown>';
          model = info.prettyName;
          physicalDevice = true;
          os = 'linux';
          systemVersion = info.versionId ?? '<unknown>';
        } else if (Platform.isMacOS) {
          var info = await plugin.macOsInfo;

          brand = 'apple';
          device = info.arch;
          manufacturer = 'apple';
          model = info.model;
          physicalDevice = true;
          os = 'macos';
          systemVersion = info.osRelease;
        } else if (Platform.isWindows) {
          // var info = await plugin.windowsInfo;

          brand = '<unknown>';
          device = '<unknown>';
          manufacturer = 'microsoft';
          model = '<unknown>';
          physicalDevice = true;
          os = 'windows';
          systemVersion = '<unknown>';
        }
      }

      if (context != null) {
        try {
          var mq = MediaQuery.of(context);

          dips = BaseSize(
            mq.size.width,
            mq.size.height,
          );
          orientation = dips.width >= dips.height ? 'landscape' : 'portrait';
          devicePixelRatio = mq.devicePixelRatio;
          pixels = BaseSize(
            mq.size.width * devicePixelRatio,
            mq.size.height * devicePixelRatio,
          );
        } catch (e) {
          // no-op, we don't know the screen, but let's not make a big fuss.
        }
      }
      result = TestDeviceInfo.custom(
        appIdentifier: TestAppSettings.settings.appIdentifier ?? appIdentifier,
        brand: brand,
        buildNumber: buildNumber,
        device: device,
        deviceGroup: TestAppSettings.settings.deviceGroup,
        devicePixelRatio: devicePixelRatio,
        dips: dips,
        // Always use the settings device id if it is set
        id: TestAppSettings.settings.deviceId ?? id,
        manufacturer: manufacturer,
        model: model,
        orientation: orientation,
        os: os,
        physicalDevice: physicalDevice,
        pixels: pixels,
        systemVersion: systemVersion,
      );

      _instance = result;
      _completer?.complete(result);
      _completer = null;
    }

    return result;
  }
}
