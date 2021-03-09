import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:logging/logging.dart';

class ReservationHandler {
  factory ReservationHandler() => _singleton;
  ReservationHandler._internal();
  static final ReservationHandler _singleton = ReservationHandler._internal();

  static final Logger _logger = Logger('ReservationHandler');

  late TestDriver _driver;

  set driver(TestDriver driver) => _driver = driver;

  Future<CommandAck> release(
    DeviceCommand command,
  ) async {
    _driver.state.driverName = null;

    return CommandAck(
      commandId: command.id,
      message: '[${command.type}]: success',
      success: true,
    );
  }

  Future<CommandAck> reserve(
    DeviceCommand command,
  ) async {
    var commandAck = CommandAck(
      commandId: command.id,
      message: '[${command.type}]: unknown command type',
      success: false,
    );
    if (command is ReserveDeviceCommand) {
      _driver.state.driverName = command.driverName;
      commandAck = CommandAck(
        commandId: command.id,
        message: '[${command.type}]: success',
        success: true,
      );
      _logger.info('[DRIVER]: device reserved by: ${command.driverName}');
    }

    return commandAck;
  }
}
