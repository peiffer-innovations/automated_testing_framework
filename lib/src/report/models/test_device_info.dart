import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:websafe_platform/websafe_platform.dart';

/// Container class for the device information for the device the test is being
/// executed on.
@immutable
class TestDeviceInfo extends BaseTestDeviceInfo {
  TestDeviceInfo._internal(BaseTestDeviceInfo info)
      : super.custom(
          appIdentifier: info.appIdentifier,
          brand: info.brand,
          buildNumber: info.buildNumber,
          device: info.device,
          devicePixelRatio: info.devicePixelRatio,
          dips: info.dips,
          id: info.id,
          manufacturer: info.manufacturer,
          model: info.model,
          orientation: info.orientation,
          os: info.os,
          physicalDevice: info.physicalDevice,
          pixels: info.pixels,
          systemVersion: info.systemVersion,
        );

  static Completer<TestDeviceInfo> _completer;
  static TestDeviceInfo _instance;

  static TestDeviceInfo get instance => _instance ?? initialize(null);

  static TestDeviceInfo fromDynamic(dynamic map) {
    TestDeviceInfo result;

    if (map != null) {
      result = TestDeviceInfo._internal(BaseTestDeviceInfo.fromDynamic(map));
    }

    return result;
  }

  static Future<TestDeviceInfo> initialize(BuildContext context) async {
    var result = _instance;

    while (_completer != null) {
      await _completer.future;
    }
    result = _instance;

    if (result == null || (context != null && result.dips == null)) {
      _completer = Completer<TestDeviceInfo>();

      var appIdentifier = '<unknown>';
      String brand;
      String buildNumber;
      String device;
      double devicePixelRatio;
      BaseSize dips;
      var id = '<unknown>';
      String manufacturer;
      String model;
      String os;
      String orientation;
      bool physicalDevice;
      BaseSize pixels;
      String systemVersion;
      var wsp = WebsafePlatform();

      if (kIsWeb) {
        brand = 'web';
        device = 'browser';
        manufacturer = '<unknown>';
        model = '<unknown>';
        physicalDevice = true;
        os = 'web';
        systemVersion = 'web';
      } else {
        try {
          var pInfo = await PackageInfo.fromPlatform();
          appIdentifier = pInfo.appName;
          buildNumber = pInfo.buildNumber;
        } catch (e) {
          // No-op; don't fail because we can't get the build number.
        }
        if (wsp.isAndroid()) {
          os = 'android';

          try {
            var plugin = DeviceInfoPlugin();
            var info = await plugin.androidInfo;

            brand = info.brand;
            device = info.device;
            id = info.androidId;
            manufacturer = info.manufacturer;
            model = info.model;
            physicalDevice = info.isPhysicalDevice;
            systemVersion = '${info.version.sdkInt}';
          } catch (e) {
            // No-op; don't fail because we can't get the device info.
          }
        } else if (wsp.isIOS()) {
          brand = 'apple';
          manufacturer = 'apple';
          os = 'ios';

          try {
            var plugin = DeviceInfoPlugin();
            var info = await plugin.iosInfo;

            device = info.name;
            id = info.identifierForVendor;
            model = info.model;
            physicalDevice = info.isPhysicalDevice;
            systemVersion = info.systemVersion;
          } catch (e) {
            // No-op; don't fail because we can't get the device info.
          }
        } else if (wsp.isFuchsia()) {
          brand = '<unknown>';
          device = '<unknown>';
          manufacturer = '<unknown>';
          model = '<unknown>';
          physicalDevice = true;
          os = 'fuchsia';
          systemVersion = '<unknown>';
        } else if (wsp.isLinux()) {
          brand = '<unknown>';
          device = '<unknown>';
          manufacturer = '<unknown>';
          model = '<unknown>';
          physicalDevice = true;
          os = 'linux';
          systemVersion = '<unknown>';
        } else if (wsp.isMacOS()) {
          brand = 'apple';
          device = 'macos';
          manufacturer = 'apple';
          model = 'macos';
          physicalDevice = true;
          os = 'macos';
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
      result = TestDeviceInfo._internal(
        BaseTestDeviceInfo.custom(
          appIdentifier:
              TestAppSettings.settings.appIdentifier ?? appIdentifier,
          brand: brand,
          buildNumber: buildNumber,
          device: device,
          devicePixelRatio: devicePixelRatio,
          dips: dips,
          id: id,
          manufacturer: manufacturer,
          model: model,
          orientation: orientation,
          os: os,
          physicalDevice: physicalDevice,
          pixels: pixels,
          systemVersion: systemVersion,
        ),
      );

      _instance = result;
      _completer?.complete(result);
      _completer = null;
    }

    return result;
  }
}
