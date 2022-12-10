import 'dart:async';
import 'dart:convert';

import 'package:automated_testing_framework/automated_testing_framework.dart';

class RunTestHandler {
  factory RunTestHandler() => _singleton;
  RunTestHandler._internal();
  static final RunTestHandler _singleton = RunTestHandler._internal();

  late TestDriver _driver;
  Timer? _timer;

  set driver(TestDriver driver) => _driver = driver;

  Future<CommandAck> abort(
    DeviceCommand command,
  ) async {
    var result = CommandAck(
      commandId: command.id,
      message: '[${command.type}]: unknown command type',
      success: true,
    );
    if (command is AbortTestCommand) {
      final controller = _driver.testController;
      await controller!.cancelRunningTests();

      result = CommandAck(
        commandId: command.id,
        message: '[${command.type}]: success',
        success: true,
      );
    }

    return result;
  }

  Future<CommandAck> run(
    DeviceCommand command,
  ) async {
    _timer?.cancel();
    var result = CommandAck(
      commandId: command.id,
      message: '[${command.type}]: unknown command type',
      success: true,
    );
    final controller = _driver.testController;

    var running = controller!.runningTest;
    if (running == true) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        running = controller.runningTest;
      });
    }

    while (running == true) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (command is RunTestCommand) {
      if (command.test.steps.isNotEmpty == true) {
        final report = TestReport(
          name: command.test.name,
          suiteName: command.test.suiteName,
          version: command.test.version,
        );

        var status = '';
        final logSub = report.logStream!.listen((data) {
          _driver.communicator!.sendCommand(
            CommandAck(
              commandId: command.id,
              message: data,
              response: TestStatusResponse(
                complete: false,
                progress: report.steps.length / command.test.steps.length,
                report: report,
                status: status,
              ),
            ),
          );
        });

        final stepSub = report.stepStream!.listen((step) {
          status = step.id;
          _driver.communicator!.sendCommand(
            CommandAck(
              commandId: command.id,
              message: null,
              response: TestStatusResponse(
                complete: false,
                progress: report.steps.length / command.test.steps.length,
                report: report,
                status: status,
              ),
            ),
          );
        });
        StreamSubscription? imageSub;

        if (command.sendScreenshots == true) {
          imageSub = report.imageStream!.listen((data) {
            _driver.communicator!.sendCommand(CommandAck(
              commandId: command.id,
              response: ScreenshotResponse(image: data.image!),
            ));
          });
        }

        try {
          final deviceInfo = await TestDeviceInfoHelper.initialize(null);
          result = CommandAck(
            commandId: command.id,
            message: json.encode(deviceInfo),
            response: TestStatusResponse(
              complete: false,
              progress: 0.0,
              report: report,
              status: '[STARTING]',
            ),
          );

          await controller.executeTest(
            report: report,
            test: command.test,
          );
          result = CommandAck(
            commandId: command.id,
            message: '[${command.type}]: complete',
            response: TestStatusResponse(
              complete: true,
              progress: 1.0,
              report: report,
              status: '[COMPLETE]',
            ),
            success: true,
          );
        } catch (e, stack) {
          result = CommandAck(
            commandId: command.id,
            message:
                '[${command.type}]: exception running test:\n  - $e\n$stack',
            success: false,
          );
        } finally {
          await imageSub?.cancel();
          await logSub.cancel();
          await stepSub.cancel();
        }
      } else {
        result = CommandAck(
          commandId: command.id,
          message: '[${command.type}]: no test steps',
          success: false,
        );
      }
    }

    return result;
  }
}
