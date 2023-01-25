import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';

class ScreenshotHandler {
  factory ScreenshotHandler() => _singleton;
  ScreenshotHandler._internal();
  static final ScreenshotHandler _singleton = ScreenshotHandler._internal();

  late TestDriver _driver;
  Uint8List? _screenshot;
  Timer? _timer;

  set driver(TestDriver driver) => _driver = driver;

  void cancel() {
    _timer?.cancel();
    _screenshot = null;
  }

  Future<CommandAck> screenshot(
    DeviceCommand command,
  ) async {
    CommandAck result;

    if (kIsWeb) {
      result = CommandAck(
        commandId: command.id,
        message: '[${command.type}]: not supported on Web',
        success: false,
      );
    } else {
      final screenshot =
          await (_driver.testController!.screencap() as FutureOr<Uint8List>);
      result = CommandAck(
        commandId: command.id,
        response: ScreenshotResponse(image: screenshot),
        success: true,
      );
    }

    return result;
  }

  Future<CommandAck> startStream(
    DeviceCommand command,
  ) async {
    var result = CommandAck(
      commandId: command.id,
      message: '[${command.type}]: unknown command type',
      success: false,
    );
    _timer?.cancel();
    _screenshot = null;

    if (kIsWeb) {
      result = CommandAck(
        commandId: command.id,
        message: '[${command.type}]: not supported on Web',
        success: false,
      );
    } else if (command is StartScreenshotStreamCommand) {
      _timer = Timer(command.interval, () async {
        await _sendScreenshot(command);
      });
    }

    return result;
  }

  Future<CommandAck> stopStream(
    DeviceCommand command,
  ) async {
    cancel();

    return CommandAck(
      commandId: command.id,
      message: '[${command.type}]: success',
      success: true,
    );
  }

  Future<void> _sendScreenshot(
    StartScreenshotStreamCommand command,
  ) async {
    final screenshot = await _driver.testController!.screencap();
    if (screenshot != null) {
      var differ =
          _screenshot == null || _screenshot!.length != screenshot.length;

      if (differ != true) {
        for (var i = 0; i < screenshot.length; i++) {
          if (screenshot[i] != _screenshot![i]) {
            differ = true;
            break;
          }
        }
      }

      if (differ == true) {
        _screenshot = screenshot;
        await _driver.communicator!.sendCommand(
          CommandAck(
            commandId: command.id,
            response: ScreenshotResponse(image: screenshot),
            success: true,
          ),
        );
      }

      if (_timer != null) {
        if (_driver.state.driverName != null) {
          _timer = Timer(
            command.interval,
            () => _sendScreenshot(command),
          );
        } else {
          _timer?.cancel();
          _timer = null;
        }
      }
    }
  }
}
