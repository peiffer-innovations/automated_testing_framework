import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:package_info/package_info.dart';
import 'package:websafe_platform/websafe_platform.dart';

/// Container class for the device information for the device the test is being
/// executed on.
@immutable
class TestDeviceInfo extends JsonClass {
  TestDeviceInfo.custom({
    @required this.appIdentifier,
    @required this.brand,
    @required this.buildNumber,
    @required this.device,
    @required this.devicePixelRatio,
    @required this.dips,
    @required this.id,
    @required this.manufacturer,
    @required this.model,
    @required this.os,
    @required this.orientation,
    bool physicalDevice = true,
    @required this.pixels,
    @required this.systemVersion,
  }) : physicalDevice = physicalDevice ?? true;

  static Completer<TestDeviceInfo> _completer;
  static TestDeviceInfo _instance;

  static TestDeviceInfo get instance => _instance ?? initialize(null);

  final String appIdentifier;
  final String brand;
  final String buildNumber;
  final String device;
  final double devicePixelRatio;
  final Size dips;
  final String id;
  final String manufacturer;
  final String model;
  final String orientation;
  final String os;
  final bool physicalDevice;
  final Size pixels;
  final String systemVersion;

  static TestDeviceInfo fromDynamic(dynamic map) {
    TestDeviceInfo result;

    if (map != null) {
      var screen = map['screen'] ?? {};
      var dips = screen['dips'];
      var pixels = screen['pixels'];

      result = TestDeviceInfo.custom(
        appIdentifier: map['appIdentifier'],
        brand: map['brand'],
        buildNumber: map['buildNumber'],
        device: map['device'],
        devicePixelRatio: JsonClass.parseDouble(screen['devicePixelRatio']),
        dips: dips == null
            ? null
            : Size(
                JsonClass.parseDouble(
                  dips['width'],
                ),
                JsonClass.parseDouble(
                  dips['height'],
                ),
              ),
        id: map['id'],
        manufacturer: map['manufacturer'],
        model: map['model'],
        orientation: map['orientation'],
        os: map['os'],
        physicalDevice: JsonClass.parseBool(map['physicalDevice']),
        pixels: pixels == null
            ? null
            : Size(
                JsonClass.parseDouble(
                  pixels['width'],
                ),
                JsonClass.parseDouble(
                  pixels['height'],
                ),
              ),
        systemVersion: map['systemVersion'],
      );
    }

    return result;
  }

  String get deviceSignature => [
        appIdentifier,
        buildNumber,
        os,
        manufacturer,
        model,
        physicalDevice,
        systemVersion,
      ].join('_');

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
      Size dips;
      var id = '<unknown>';
      String manufacturer;
      String model;
      String os;
      String orientation;
      bool physicalDevice;
      Size pixels;
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

          dips = Size(
            mq.size.width,
            mq.size.height,
          );
          orientation = dips.width >= dips.height ? 'landscape' : 'portrait';
          devicePixelRatio = mq.devicePixelRatio;
          pixels = Size(
            mq.size.width * devicePixelRatio,
            mq.size.height * devicePixelRatio,
          );
        } catch (e) {
          // no-op, we don't know the screen, but let's not make a big fuss.
        }
      }
      result = TestDeviceInfo.custom(
        appIdentifier: appIdentifier,
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
      );

      _instance = result;
      _completer?.complete(result);
      _completer = null;
    }

    return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'brand': brand,
        'buildNumber': buildNumber,
        'device': device,
        'id': id,
        'manufacturer': manufacturer,
        'model': model,
        'orientation': orientation,
        'os': os,
        'physicalDevice': physicalDevice,
        'screen': devicePixelRatio == null
            ? null
            : {
                'devicePixelRatio': devicePixelRatio,
                'dips': dips == null
                    ? null
                    : {
                        'height': dips.height,
                        'width': dips.width,
                      },
                'pixels': pixels == null
                    ? null
                    : {
                        'height': pixels.height,
                        'width': pixels.width,
                      },
              },
        'systemVersion': systemVersion,
      };
}
