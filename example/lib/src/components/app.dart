import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:example/src/pages/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final List<StreamSubscription> _subscriptions = [];
  bool _darkTheme = true;
  TestController _testController;
  StreamController<void> _themeController = StreamController<void>.broadcast();

  Key _uniqueKey = UniqueKey();

  @override
  void initState() {
    super.initState();

    AssetTestStore.testAssets = [
      'assets/tests/buttons.json',
      'assets/tests/dropdowns.json',
      'assets/tests/failure.json',
      'assets/tests/icons_gesture.json',
      'assets/tests/stacked_scrolling.json',
      'assets/tests/theme.json',
    ];

    _testController = TestController(
      navigatorKey: _navigatorKey,
      onReset: () async {
        while (_navigatorKey.currentState.canPop()) {
          _navigatorKey.currentState.pop();
        }

        _uniqueKey = UniqueKey();
        setState(() {});
      },
      registry: TestStepRegistry.instance,
      testReader: AssetTestStore.testReader,
      testWriter: ClipboardTestStore.testWriter,
    );

    _themeController.stream.listen((_) {
      _darkTheme = _darkTheme != true;
      if (mounted == true) {
        setState(() {});
      }
    });

    if (kProfileMode == true) {
      _runTests();
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();
    _testController?.dispose();
    _testController = null;
    _themeController?.close();
    _themeController = null;

    super.dispose();
  }

  Future<void> _runTests() async {
    var tests = await _testController.loadTests(context);
    await _testController.runPendingTests(tests);
  }

  @override
  Widget build(BuildContext context) {
    return TestRunner(
      controller: _testController,
      enabled: true,
      progressBuilder: TestProgressBuilder(
        theme: _darkTheme
            ? TestRunnerThemeData.dark(
                showStepText: true,
                showRunnerStatus: kDebugMode,
                statusAlignment: TestStatusAlignment.bottomSafe,
              )
            : TestRunnerThemeData(
                showRunnerStatus: kDebugMode,
              ),
      ),
      testableRenderController: TestableRenderController(
        flashCount: _darkTheme ? 3 : 0,
        testWidgetsEnabled: kDebugMode,
      ),
      child: MultiProvider(
        providers: [
          Provider<StreamController<void>>.value(value: _themeController),
        ],
        child: MaterialApp(
          key: _uniqueKey,
          navigatorKey: _navigatorKey,
          theme: _darkTheme == true
              ? ThemeData(
                  brightness: Brightness.dark,
                  buttonColor: Colors.indigo.shade700,
                  canvasColor: Color(0xff404040),
                  iconTheme: IconThemeData(color: Colors.lightBlue.shade200),
                  errorColor: Colors.red.shade300,
                  scaffoldBackgroundColor: Color(0xff303030),
                  primarySwatch: Colors.blue,
                )
              : ThemeData(
                  brightness: Brightness.light,
                  buttonTheme: ButtonThemeData(
                    buttonColor: Colors.indigo.shade700,
                    textTheme: ButtonTextTheme.primary,
                  ),
                  canvasColor: Color(0xffe0e0e0),
                  iconTheme: IconThemeData(color: Colors.blue),
                  errorColor: Colors.red,
                  scaffoldBackgroundColor: Color(0xffd0d0d0),
                  primarySwatch: Colors.blue,
                ),
          home: HomePage(),
        ),
      ),
    );
  }
}
