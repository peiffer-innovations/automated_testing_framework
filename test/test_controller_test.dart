import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('variables', () {
    final navigatorKey = GlobalKey<NavigatorState>();
    var controller = TestController(
      navigatorKey: navigatorKey,
      onReset: () async {},
    );

    expect('foo', controller.resolveVariable('foo'));
    expect('{{foo}}', controller.resolveVariable('{{foo}}'));

    controller.setVariable(variableName: 'foo', value: 'bar');
    expect('bar', controller.resolveVariable('{{foo}}'));

    controller.setVariable(variableName: 'foo', value: null);
    expect(null, controller.resolveVariable('{{foo}}'));

    controller.setVariable(variableName: 'foo', value: false);
    expect(false, controller.resolveVariable('{{foo}}'));

    controller.setVariable(variableName: 'foo', value: 42.0);
    expect(42.0, controller.resolveVariable('{{foo}}'));

    controller.removeVariable(variableName: 'foo');
    expect('{{foo}}', controller.resolveVariable('{{foo}}'));
  });
}
