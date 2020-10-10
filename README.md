# automated_testing_framework

## Table of Contents

* [Live Example](#live-example)
* [Introduction](#introduction)
* [Framework Philosophy](#framework-philosophy)
* [Running the Example](#running-the-example)
* [Quick Start](#quick-start)
* [Annotating Testable Widgets](#annotating-testable-widgets)
* [Creating Tests](#creating-tests)
* [Saving and Loading Tests](#saving-and-loading-tests)
* [Reporting Test Results](#reporting-test-results)
* [Working with Variables](#working-with-variables)
  * [Reserved Variables](#reserved-variables)
* [Framework in Action](#framework-in-action)
* See Also
  * [Building & Running Tests](https://github.com/peiffer-innovations/automated_testing_framework/blob/main/documentation/BUILDING_RUNNING_TESTS.md)
  * [Built In Test Steps](https://github.com/peiffer-innovations/automated_testing_framework/blob/main/documentation/STEPS.md)
* Plugins
  * [Cloud Firestore](https://pub.dev/packages/automated_testing_framework_plugin_firestore)
  * [Firebase Storage](https://pub.dev/packages/automated_testing_framework_plugin_firebase_storage)
  * [Firebase Realtime Database](https://pub.dev/packages/automated_testing_framework_plugin_firebase)
  * [Flow Control](https://pub.dev/packages/automated_testing_framework_plugin_flow_control)
  * [Images](https://pub.dev/packages/automated_testing_framework_plugin_images)
  * [Logging](https://pub.dev/packages/automated_testing_framework_plugin_logging)
  * [Strings](https://pub.dev/packages/automated_testing_framework_plugin_strings)

---
## Live Example

* [Web](https://peiffer-innovations.github.io/automated_testing_framework/web/index.html#/)
  * _Note_: Please wait a few seconds after the example loads for the tests to start.  Once the tests are complete, you can interact with the app and build and run your own tests.


---

## Introduction

Automated Testing Framework that allows for the building and executing of automated tests on emulators and / or physical devices.  Unlike the [Flutter Driver](https://api.flutter.dev/flutter/flutter_driver/flutter_driver-library.html), this framework does not require any host driver so it does not have the same limitations, such as the requirement that iOS devices be on the same network as the host computer.

Via this framework, the application itself is the test driver so it can execute in any circumstance the Flutter application itself can execute.  It also opens Flutter applications up to being tested on more standard cloud testing solutions as the app "self tests" so provided the app can be installed, the tests can execute.

For users of the Framework, the three most important classes to become familiar with are:

Name | Description
-----|------------
[Testable](https://pub.dev/documentation/automated_testing_framework/latest/widgets/Testable-class.html) | Widget that is used to wrap application level widgets to provide the framework with the ability to interact with it.
[TestRunner](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/TestRunner-class.html) | Top-level widget that must wrap the application as a whole.  Acts as an owner for the testing framework.
[TestController](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/TestController-class.html) | Controller that is used to create, edit, load, save, and execute the tests.


---

## Running the Example

The framework comes with an example application that showcases the majority of the features the framework provides.  If you run the example in `debug` mode, you can interact with the `Testable` widgets, create tests, run tests, and see the results.

If you run the framework in `profile` mode, the application will immediately start executing the bundled test suite and at the end of the tests, it will provide a result page.

To see the tests in action, run the example via:
```
flutter run --profile
```


---

## Framework Philosophy


The testing framework is designed to be utilized by developers, QA members, or even Product folks to build and run automated tests.  The base framework is purposefully "Dart Native" to provide compatibility with steps that are easy to understand and used by the widest number of people.

The framework provides plugin capabilities to allow for more advanced test steps or steps that require non-Dart-native dependencies.

All steps provided by the framework or any first party plugins are guaranteed to be fully editable within a testable application itself.  While JSON experience may be beneficial, it is not required.


---

## Quick Start

In order to run the automated tests, the framework must be associated to your application.  First, the framework utilizes the [logging](https://pub.dev/packages/logging) package to allow fine control over the console messages.  A quick way to enable all logging from the framework is to set up a log emitter to the console as follows:

```dart
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      print('${record.stackTrace}');
    }
  });

  ...
}
```

Feel free to change the logging levels based on your application's needs.

Next your app will need to create a [TestController](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/TestController-class.html).  The controller is the logic heart of the framework.  That controller will now need to be passed to a [TestRunner](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/TestRunner-class.html) that is attached to the base of the widget tree.

The following code is a minimal use case for getting started:

```dart
import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


void main() {
  ...

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _testsEnabled = !kReleaseMode;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  UniqueKey _uniqueKey;


  @override
  void initState() {
    super.initState();

    if (_testsEnabled) {
      _testController = TestController(
        navigatorKey: _navigatorKey,
        onReset: _onReset,
      );
    }
  }

  @override
  void dispose() {
    _testController?.dispose();

    super.dispose();
  }

  /// Application specific logic that resets the app to a base state.  The code
  /// below is a relatively straight forward way to accomplish this reset, but
  /// your application may require more logic to actually clear any internal
  /// state.
  Future<void> _onReset() async {
    while (_navigatorKey.currentState.canPop()) {
      _navigatorKey.currentState.pop();
    }
    _uniqueKey = UniqueKey();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => 
    TestRunner(
      controller: _testController,
      enabled: _testsEnabled,
      child: MaterialApp(
        key: _uniqueKey,
        ...
      ),
    );
  
}
```


---

## Annotating Testable Widgets

Now that you've wired up the core portions of the framework, you will need to start annotating your application to identify widgets that the framework can interact with.  The main class for tihs annotation is the [Testable](https://pub.dev/documentation/automated_testing_framework/latest/widgets/Testable-class.html) widget.  Wrap widgets that need to be interacted with in an automated way with this `Testable` widget and the `Testable` widget will perform the bindings for you and also respond to commands from the framework when running tests.

Let's say you have a button that you want to be able to tap via the framework.  That would look something like:

```dart
Testable(
  id: 'my-spiffy-button',
  child: RaisedButton(
    onPressed: () => _buttonPressed(),
    child: Text('Button Text'),
  )
)
```

The `Testable` will now wrap the button in a way that allows you to use it to build a test, run a test, and press the button via a test.  Any widget can be wrapped via a `Testable` to provide interaction.  By default, the only action that sub widgets are assumped to support is the `tap` and `long_press` capabilities.  The `Testable` will try to search for common widgets in the child tree and add capabilities.  However, if you know that there are capabilities you want to provide such as setting a value, checking a value, or checking an error, you will need to associate the appropriate methods:

* `onRequestError` -- Informs the framework that the widget supports an error state.  When executed, this must 
* `onRequestValue` -- Informs the framework that the widget supports a value that may be requested.  When executed, this must return the widget's current value.
* `onSetValue` -- Informs the framework that a value may be set on this widget.  When executed, the callback must set the value on the widget.  Although the user may specify the type as a `String`, a `bool`, a `double` or an `int`, it is actually recommended that the callback be very generous in what it accepts and try to support conversions internally as testers may not always be aware of which type to use when creating the steps.

In addition to the base Testable widget, there are a small number of widgets that automatically wrap and expose capabilities.  Each of the wrapper widgets are API compatible with the widgets that they are wrapping with the exception that they each need an `id` set.  They are: 

Name | Description
-----|------------
[TestableDropdownButtonFormField](https://pub.dev/documentation/automated_testing_framework/latest/widgets/TestableDropdownButtonFormField-class.html) | Wrapper for the DropdownButtonFormField to provide the common testable callbacks
[TestableFormField](https://pub.dev/documentation/automated_testing_framework/latest/widgets/TestableFormField-class.html) | Wrapper for the FormField to provide the common testable callbacks
[TestableTextFormField](https://pub.dev/documentation/automated_testing_framework/latest/widgets/TestableTextFormField-class.html) | Wrapper for the TextFormField to provide the common testable callbacks


---

## Creating Tests

The `Testable` widgets add on to wrapped widgets gestures that allow you to interact with the test framework.  It's important to note that if the wrapped widget listens for the same gesture as the `Testable` then the wrapped widget will "win" and the `Testable` will not receive that gesture.  It is for that reason that the default implementation provides gestures for both a Long Press gesture and a Double Tap.  The `Testable` also introduces the concept of a "direct" interaction and an "interdirect" interaction.

A "direct" action is one the `Testable` listens for even when it's in a transparent state to the user.  An "indirect" action is one that the `Testable` listens to once it's activated to a more "in your face" state.  These separate modes allow for a wider number of actionable gestures.

The defaults can be overridden by using the [TestableGestures](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/TestableGestures-class.html) class.  The `widget` gestures are all applied to the inactive `Testable` widget and the `overlay` gestures are applied to the activated overlay.

The default gestures are as follows:

Target    | Gesture    | Description
----------|------------|-------------
`widget`  | Long Press | Activate the Test Controls dialog
`widget`  | Double Tap | Deactivate the `Testable` and hide the widget overlay
`overlay` | Double Tap | Activate the `Testable` and show the widget overlay
`overlay` | Long Press | Toggle the global overlay over all `Testable` widgets.  This is useful to be able to quickly identify what widgets on a page have been annotated as `Testable` and which ones may have been missed. 


---

## Saving and Loading Tests

Tests can be saved and loaded by associating appropriate functions to the `TestController`.  The functions to be associated are the `TestReader` and `TestWriter` functions.

As you might assume, the `TestReader` function must be able to load one or more tests from where ever your test store resides and the `TestWriter` is expected to be able to write out tests for long term storage.

The default implementation for both of these functions is a no-op that will not read or write any test data.  However, the framework does come with a few convenience Test Store options to assist:

Class | Function | Description
------|----------|-------------
[AssetTestStore](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/AssetTestStore-class.html) | `testReader` | Function capable of reading tests from built in Flutter assets
[ClipboardTestStore](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/ClipboardTestStore-class.html) | `testReader` | Function that reads test data from the clipboard.  Only really useful on emulators where the clipboard is shared with the host computer.
[ClipboardTestStore](https://pub.dev/documentation/automated_testing_framework/latest/automated_testing_framework/ClipboardTestStore-class.html) | `testWriter` | Function that writes the test data to the clipboard.  This can be used on a device, but it is really intended for use on emulators where the clipboard is shared with the host computer.


---

## Reporting Test Results

Similarly to the saving and loading of tests, the `TestController` provides a mechanism to send out reports from test runs.  There are no built in reporters that will provide the data outside of the application.  There are only screens that display test results at the end of a test or test suite.

To receive the test report, implement the `testReporter` callback to send the report to your targetted area.


---

## Working with Variables

The `TestController` supports variables within test steps and from external code.  Within steps that support variables, the variables utilize the mustache syntax.  For example: `{{variableName}}`.  Test steps that support variables will attempt to resolve the variable at runtime.  This provides the application the ability to set up common variables like usernames, passwords, etc. in a way that any test can generically refer to them.

Variables can be either the entire value or can be interpolated as a partial value.  For example, a variable named "one" with the value of "1" and the string of: "Number {{one}}" will result in a value of "Number 1".


### Reserved Variables

Reserved variables are begin with an underscore (`_`) and should be reserved for the framework itself plus any plugins that are applied to the framework.  Applications should avoid setting variables that begin with an underscore as they may be overwritten by plugins or the framework either now or at some future time.

The following table defines the reserved variables provided by the framework that can be used in any test:

Name       | Type       | Example | Description
-----------|------------|---------|-------------
`_now`     | `DateTime` | n/a     | Returns `DateTime.now().toUtc()`.
`_passing` | `boolean`  | `true`  | Describes whether the test is currently passing or not.  This will be `true` up until the first failed step at which it will remain `false` for the remainder of the test.


---

## Framework in Action

![Activating Test Widget](https://raw.githubusercontent.com/peiffer-innovations/automated_testing_framework/main/documentation/images/activating_test_widget.gif)

![Dropdown Test](https://raw.githubusercontent.com/peiffer-innovations/automated_testing_framework/main/documentation/images/dropdown_test.gif)

![Failing Test](https://raw.githubusercontent.com/peiffer-innovations/automated_testing_framework/main/documentation/images/failing_test.gif)

![Stacked Scrolling](https://raw.githubusercontent.com/peiffer-innovations/automated_testing_framework/main/documentation/images/stacked_scrolling.gif)