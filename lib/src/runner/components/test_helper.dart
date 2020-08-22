// import 'dart:async';

// import 'package:automated_testing_framework/automated_testing_runner.dart';
// import 'package:device_info/device_info.dart';
// import 'package:websafe_platform/websafe_platform.dart';

// class TestHelper {
//   factory TestHelper() => _singleton;
//   TestHelper._internal() {
//     _initialize();
//   }
//   static final TestHelper _singleton = TestHelper._internal();

//   InfoResponse _deviceInfo;

//   InfoResponse get deviceInfo => _deviceInfo;

//   Future<void> _initialize() async {
//     var websafePlatform = WebsafePlatform();

//     if (websafePlatform.isAndroid() == true) {
//       var androidInfo = await DeviceInfoPlugin().androidInfo;
//       _deviceInfo = InfoResponse(
//         device: androidInfo.model,
//         os: 'android',
//         osVersion: androidInfo.version.sdkInt.toString(),
//       );
//     } else if (websafePlatform.isIOS() == true) {
//       var iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
//       _deviceInfo = InfoResponse(
//         device: iosDeviceInfo.model,
//         os: 'ios',
//         osVersion: iosDeviceInfo.systemVersion,
//       );
//     } else if (websafePlatform.isWeb() == true) {
//       _deviceInfo = InfoResponse(
//         device: 'browser',
//         os: 'web',
//         osVersion: 'unknown',
//       );
//     }
//   }
// }
