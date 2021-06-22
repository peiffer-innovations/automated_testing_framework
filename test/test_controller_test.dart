import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all variables', () {
    final navigatorKey = GlobalKey<NavigatorState>();
    var controller = TestController(
      navigatorKey: navigatorKey,
      onReset: () async {},
    );

    controller.setGlobalVariable(variableName: 'foo', value: null);
    expect(null, controller.resolveVariable('{{foo}}'));

    controller.setGlobalVariable(variableName: 'foo', value: 'bar');
    expect('bar', controller.resolveVariable('{{foo}}'));

    controller.setTestVariable(variableName: 'foo', value: 'foo');
    expect('foo', controller.resolveVariable('{{foo}}'));

    controller.setTestVariable(variableName: 'foo', value: null);
    expect(null, controller.resolveVariable('{{foo}}'));

    controller.removeGlobalVariable(variableName: 'foo');
    expect(null, controller.resolveVariable('{{foo}}'));
  });

  test('global variables', () {
    final navigatorKey = GlobalKey<NavigatorState>();
    var controller = TestController(
      navigatorKey: navigatorKey,
      onReset: () async {},
    );

    expect('foo', controller.resolveVariable('foo'));
    expect('{{foo}}', controller.resolveVariable('{{foo}}'));

    controller.setGlobalVariable(variableName: 'foo', value: 'bar');
    expect('bar', controller.resolveVariable('{{foo}}'));

    controller.setGlobalVariable(variableName: 'foo', value: null);
    expect(null, controller.resolveVariable('{{foo}}'));

    controller.setGlobalVariable(variableName: 'foo', value: false);
    expect(false, controller.resolveVariable('{{foo}}'));

    controller.setGlobalVariable(variableName: 'foo', value: 42.0);
    expect(42.0, controller.resolveVariable('{{foo}}'));

    controller.removeGlobalVariable(variableName: 'foo');
    expect('{{foo}}', controller.resolveVariable('{{foo}}'));
  });

  test('test variables', () {
    final navigatorKey = GlobalKey<NavigatorState>();
    var controller = TestController(
      navigatorKey: navigatorKey,
      onReset: () async {},
    );

    expect('foo', controller.resolveVariable('foo'));
    expect('{{foo}}', controller.resolveVariable('{{foo}}'));

    controller.setTestVariable(variableName: 'foo', value: 'bar');
    expect('bar', controller.resolveVariable('{{foo}}'));

    controller.setTestVariable(variableName: 'foo', value: null);
    expect(null, controller.resolveVariable('{{foo}}'));

    controller.setTestVariable(variableName: 'foo', value: false);
    expect(false, controller.resolveVariable('{{foo}}'));

    controller.setTestVariable(variableName: 'foo', value: 42.0);
    expect(42.0, controller.resolveVariable('{{foo}}'));

    controller.removeTestVariable(variableName: 'foo');
    expect('{{foo}}', controller.resolveVariable('{{foo}}'));
  });
}
