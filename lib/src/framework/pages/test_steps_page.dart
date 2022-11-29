import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_validation/form_validation.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:static_translations/static_translations.dart';

/// Page that shows all the test steps and their values for a current test.
class TestStepsPage extends StatefulWidget {
  TestStepsPage({
    this.doublePop = true,
    Key? key,
  }) : super(key: key);

  final bool doublePop;

  @override
  _TestStepsPageState createState() => _TestStepsPageState();
}

class _TestStepsPageState extends State<TestStepsPage>
    with ResetNavigationStateMixin, SingleTickerProviderStateMixin {
  static const _kClearTabIndex = 0;
  static const _kExportTabIndex = 1;
  static const _kRunAllTabIndex = 2;

  final Logger _logger = Logger('TestStepsPageState');

  bool _exporting = false;

  late TabController _tabController;
  late TestController _testController;

  @override
  void initState() {
    super.initState();

    _testController = context.read<TestController>();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onEditTestName({
    required TestController tester,
    required Translator translator,
  }) async {
    var label = translator.translate(TestTranslations.atf_test_name);
    var testName = tester.currentTest.name ?? '';
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    var suiteName =
        tester.currentTest.suiteName ?? tester.selectedSuiteName ?? '';
    var endTestName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => Form(
        autovalidateMode: AutovalidateMode.always,
        child: Builder(
          builder: (BuildContext context) => Theme(
            data: theme,
            child: AlertDialog(
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    translator.translate(
                      TestTranslations.atf_button_cancel,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    var valid = Form.of(context).validate();
                    if (valid == true) {
                      Navigator.of(context).pop(testName);
                    }
                  },
                  child: Text(
                    translator.translate(
                      TestTranslations.atf_button_ok,
                    ),
                  ),
                ),
              ],
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    autocorrect: false,
                    autofocus: true,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: InputDecoration(
                      labelText: label,
                    ),
                    initialValue: testName,
                    onChanged: (value) => testName = value,
                    validator: (value) =>
                        Validator(validators: [RequiredValidator()]).validate(
                      context: context,
                      label: label,
                      value: value,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    autocorrect: false,
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: translator.translate(
                        TestTranslations.atf_suite_name,
                      ),
                    ),
                    initialValue: suiteName,
                    onChanged: (value) => suiteName = value,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (endTestName?.isNotEmpty == true) {
      _testController.currentTest = _testController.currentTest.copyWith(
        name: endTestName,
        suiteName: suiteName.isEmpty == true ? null : suiteName,
      );
      if (mounted == true) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var tester = TestController.of(context);
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    var translator = Translator.of(context);
    var testController = TestController.of(context);

    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _onEditTestName(
                  tester: tester!,
                  translator: translator,
                ),
                tooltip: translator.translate(TestTranslations.atf_button_edit),
              ),
              Builder(
                builder: (BuildContext context) => IconButton(
                  icon: Icon(Icons.content_copy),
                  onPressed: () async {
                    var encoder = JsonEncoder.withIndent('  ');
                    var steps = testController!.currentTest.steps;
                    var simpleSteps = [];
                    for (var step in steps) {
                      simpleSteps.add(
                        step
                            .copyWith(
                              image: Uint8List(0),
                            )
                            .toJson(),
                      );
                    }
                    var encoded = encoder.convert(simpleSteps);

                    var translator = Translator.of(context);

                    await Clipboard.setData(ClipboardData(text: encoded));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        translator.translate(
                          TestTranslations.atf_copied_to_clipboard,
                        ),
                      ),
                    ));
                  },
                  tooltip: translator.translate(
                    _tabController.index == 2
                        ? TestTranslations.atf_tooltip_copy_steps
                        : TestTranslations.atf_tooltip_copy_bdd,
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: translator.translate(TestTranslations.atf_minified)),
                Tab(text: translator.translate(TestTranslations.atf_full)),
                Tab(text: translator.translate(TestTranslations.atf_bdd)),
              ],
            ),
            centerTitle: !kIsWeb && Platform.isIOS,
            title: Text(
              (_testController.currentTest.name ??
                      translator.translate(
                        TestTranslations.atf_unnamed_test,
                      )) +
                  (testController!.currentTest.suiteName?.isNotEmpty == true
                      ? ' (${testController.currentTest.suiteName})'
                      : ''),
            ),
          ),
          body: SafeArea(
            bottom: true,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _exporting == true,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        TestStepListMinifiedTab(
                          doublePop: widget.doublePop,
                        ),
                        TestStepListFullTab(
                          doublePop: widget.doublePop,
                        ),
                        TestStepListMarkdownTab(),
                      ],
                    ),
                  ),
                ),
                if (_exporting == true) ...[
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: IgnorePointer(
            ignoring: _exporting == true,
            child: Builder(
              builder: (BuildContext context) => BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.error,
                    ),
                    label: translator.translate(
                      TestTranslations.atf_button_clear,
                    ),
                    // style: TextStyle(color: theme.errorColor),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.save,
                      color: theme.iconTheme.color,
                    ),
                    label: translator.translate(
                      TestTranslations.atf_button_export,

                      // style: TextStyle(color: theme.iconTheme.color),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.play_circle_filled,
                      color: theme.iconTheme.color,
                    ),
                    label: translator.translate(
                      TestTranslations.atf_button_run_all,
                    ),
                    // style: TextStyle(color: theme.iconTheme.color),
                  ),
                ],
                onTap: (int index) async {
                  switch (index) {
                    case _kClearTabIndex:
                      var clear = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => Theme(
                          data: theme,
                          child: AlertDialog(
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  translator.translate(
                                    TestTranslations.atf_button_cancel,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ButtonStyle(
                                  textStyle: MaterialStateProperty.all(
                                    TextStyle(color: theme.colorScheme.error),
                                  ),
                                ),
                                child: Text(
                                  translator.translate(
                                    TestTranslations.atf_button_clear,
                                  ),
                                ),
                              ),
                            ],
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.warning,
                                  color: theme.textTheme.bodyMedium!.color,
                                  size: 54.0,
                                ),
                                SizedBox(
                                  height: 16.0,
                                ),
                                Text(
                                  translator.translate(
                                    TestTranslations.atf_clear_confirmation,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      if (clear == true) {
                        testController.currentTest = Test(
                          name: 'Change Me ${Random().nextInt(1000)}',
                        );
                        Navigator.of(context).pop();
                      }
                      break;
                    case _kExportTabIndex:
                      _exporting = true;
                      if (mounted == true) {
                        setState(() {});
                      }
                      try {
                        if (await testController.exportCurrentTest(
                              context: context,
                            ) ==
                            true) {
                          Navigator.of(context).pop();
                        }
                      } finally {
                        _exporting = false;
                        if (mounted == true) {
                          setState(() {});
                        }
                      }

                      break;

                    case _kRunAllTabIndex:
                      var controller = TestableRenderController.of(context);
                      controller.showGlobalOverlay = false;
                      var tester = TestController.of(context)!;
                      Navigator.of(context).pop();
                      await Future.delayed(Duration(milliseconds: 500));
                      try {
                        await tester.execute(
                          name: _testController.currentTest.name,
                          reset: true,
                          steps: _testController.currentTest.steps,
                          submitReport: false,
                          suiteName: _testController.currentTest.suiteName,
                          version: _testController.currentTest.version,
                        );
                      } catch (e, stack) {
                        _logger.severe(e, stack);
                      }
                      break;

                    default:
                      throw FlutterError('Unknown tab index encountered');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
