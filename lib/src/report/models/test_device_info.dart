import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:package_info/package_info.dart';
import 'package:websafe_platform/websafe_platform.dart';

@immutable
class TestDeviceInfo extends JsonClass {
  TestDeviceInfo.custom({
    this.brand,
    this.buildNumber,
    this.device,
    this.manufacturer,
    this.model,
    this.os,
    this.physicalDevice,
    this.screenWidth,
    this.screenHeight,
    this.systemVersion,
  });

  static TestDeviceInfo _instance;

  final String brand;
  final String buildNumber;

  final String device;
  final String manufacturer;
  final String model;
  final String os;
  final bool physicalDevice;
  final double screenWidth;
  final double screenHeight;
  final String systemVersion;

  static Future<TestDeviceInfo> initialize(BuildContext context) async {
    var result = _instance;

    String brand;
    String buildNumber;
    String device;
    String manufacturer;
    String model;
    String os;
    bool physicalDevice;
    double screenWidth;
    double screenHeight;
    String systemVersion;

    if (result == null) {
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
          buildNumber = pInfo.buildNumber;
        } catch (e) {
          // No-op; don't fail because we can't get the build number.
        }
        if (wsp.isAndroid()) {
          var plugin = DeviceInfoPlugin();
          var info = await plugin.androidInfo;

          brand = info.brand;
          device = info.device;
          manufacturer = info.manufacturer;
          model = info.model;
          physicalDevice = info.isPhysicalDevice;
          os = 'android';
          systemVersion = '${info.version.sdkInt}';
        } else if (wsp.isIOS()) {
          var plugin = DeviceInfoPlugin();
          var info = await plugin.iosInfo;

          brand = 'apple';
          device = info.localizedModel;
          manufacturer = 'apple';
          model = info.model;
          physicalDevice = info.isPhysicalDevice;
          os = 'ios';
          systemVersion = info.systemVersion;
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
          screenHeight = mq.size.height;
          screenWidth = mq.size.width;
        } catch (e) {
          // no-op, we don't know the screen, but let's not make a big fuss.
        }
      }
      result = TestDeviceInfo.custom(
        brand: brand,
        buildNumber: buildNumber,
        device: device,
        manufacturer: manufacturer,
        model: model,
        os: os,
        physicalDevice: physicalDevice,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        systemVersion: systemVersion,
      );

      if (result != null) {
        _instance = result;
      }
    }

    return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'brand': brand,
        'buildNumber': buildNumber,
        'device': device,
        'manufacturer': manufacturer,
        'model': model,
        'os': os,
        'physicalDevice': physicalDevice,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
        'systemVersion': systemVersion,
      };
}
