import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:logging/logging.dart';

class TestDriver {
  TestDriver({
    required this.communicator,
    required this.testController,
  }) : assert(communicator != null || testController == null) {
    LogHandler().driver = this;
    ReservationHandler().driver = this;
    RunTestHandler().driver = this;
    ScreenshotHandler().driver = this;
  }

  static final Logger _logger = Logger('TestDriver');

  final TestDeviceCommunicator? communicator;
  final TestController? testController;
  final Map<String, DeviceCommandHandler> _builtInHandlers = {
    AbortTestCommand.kCommandType: RunTestHandler().abort,
    ReleaseDeviceCommand.kCommandType: ReservationHandler().release,
    ReserveDeviceCommand.kCommandType: ReservationHandler().reserve,
    RunTestCommand.kCommandType: RunTestHandler().run,
    StartLogStreamCommand.kCommandType: LogHandler().startStream,
    StartScreenshotStreamCommand.kCommandType: ScreenshotHandler().startStream,
    StopLogStreamCommand.kCommandType: LogHandler().stopStream,
    StopScreenshotStreamCommand.kCommandType: ScreenshotHandler().stopStream,
  };
  final Map<String, DeviceCommandHandler> _handlers = {};
  final TestDriverState _state = TestDriverState();

  StreamSubscription<DeviceCommand>? _commandSubscription;

  TestDriverState get state => _state;

  /// Activates the test driver, which will also activate the [communicator].
  void activate([ConnectionChangedCallback? onConnectionChanged]) async {
    if (testController != null) {
      state.active = true;
      communicator!.onConnectionChanged =
          onConnectionChanged ?? _onConnectionChanged;

      if (communicator!.active != true) {
        await communicator!.activate(
          () => TestDeviceInfoHelper.initialize(null),
        );
      }
      _commandSubscription = communicator!.commandStream.listen(
        (command) => _onCommandReceived(command),
      );
    }
  }

  Future<void> deactivate() async {
    if (testController != null) {
      state.active = false;
      await _commandSubscription?.cancel();
      _commandSubscription = null;
      await communicator!.deactivate();
    }
  }

  void disconnectDriver() {
    state.driverName = null;
    LogHandler().cancel();
    ScreenshotHandler().cancel();
    _logger.info('[DRIVER]: device reservation released.');
  }

  /// Registers custom command handlers.  Commands with a type that matches the
  /// key in the custom handlers map will allow the
  void registerCustomCommandHandlers(
          Map<String, DeviceCommandHandler> handlers) =>
      _handlers.addAll(handlers);

  Future<void> _onCommandReceived(DeviceCommand command) async {
    if (state.active == true) {
      var handler = _handlers[command.type] ?? _builtInHandlers[command.type];

      if (handler != null) {
        _logger.info('[COMMAND]: handling command: [${command.type}]');
        var ack = await handler(command);
        await communicator!.sendCommand(ack);
      }
    }
  }

  Future<void> _onConnectionChanged(
    TestDeviceCommunicator communicator,
    bool connected,
  ) async {
    _logger.info('[CONNECTION CHANGED]: [$connected]');
  }
}
