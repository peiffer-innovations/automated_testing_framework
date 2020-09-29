import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:static_translations/static_translations.dart';

/// Page that displays all the currently available tests and provides the option
/// to run them.
class AvailableTestsPage extends StatefulWidget {
  AvailableTestsPage({
    this.autoRun = false,
    Key key,
    this.suiteName,
  })  : assert(autoRun != null),
        super(key: key);

  final bool autoRun;
  final String suiteName;

  @override
  _AvailableTestsPageState createState() => _AvailableTestsPageState();
}

class _AvailableTestsPageState extends State<AvailableTestsPage> {
  final Map<String, bool> _active = {};
  String _suiteName;
  List<String> _testSuites = [];
  List<PendingTest> _tests;
  Translator _translator;
  TestController _testController;

  @override
  void initState() {
    super.initState();

    _translator = Translator.of(context);

    _testController = TestController.of(context);
    _suiteName = widget.suiteName ?? _testController.selectedSuiteName;

    _loadTests();
  }

  bool _isActive(PendingTest test) => _active[test.id] ?? false;

  Future<void> _loadTest(PendingTest pendingTest) async {
    var test = await pendingTest.loader.load();
    _testController.currentTest = test;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => TestStepsPage(),
      ),
    );
  }

  Future<void> _loadTests() async {
    _tests = (await _testController.loadTests(
          context,
        )) ??
        [];
    _active.clear();

    var suites = <String>{};
    _tests?.forEach((test) {
      _active[test.id] = test.active;
      if (test.suiteName != null) {
        suites.add(test.suiteName);
      }
    });
    _testSuites = suites.toList()..sort((a, b) => a.compareTo(b));
    if (mounted == true) {
      setState(() {});
    }

    if (widget.autoRun == true) {
      await _runTests();
    }
  }

  Future<void> _runTests() async {
    var tests = <Test>[];

    for (var test in _tests) {
      if (_isActive(test) &&
          test.numSteps > 0 &&
          (_suiteName == null || _suiteName == test.suiteName)) {
        var t = await test.loader.load(ignoreImages: true);

        tests.add(t);
      }
    }

    await TestController.of(context)?.runTests(tests);
  }

  void _setActive(PendingTest test) {
    var active = _isActive(test);

    _active[test.id] = active != true;

    if (mounted == true) {
      setState(() {});
    }
  }

  void setSuiteName(String suiteName) {
    _suiteName = suiteName;
    if (mounted == true) {
      setState(() {});
    }
  }

  Widget _buildTest(
    BuildContext context,
    PendingTest test,
  ) =>
      ListTile(
        key: ValueKey('${test.name}_${test.suiteName}'),
        onLongPress: () => _loadTest(test),
        onTap: () => _setActive(test),
        subtitle: Text(
          _translator.translate(
            test.suiteName == null
                ? TestTranslations.atf_version_steps
                : TestTranslations.atf_suite_version_steps,
            {
              'steps': test.numSteps,
              'suiteName': test.suiteName,
              'version': test.version,
            },
          ),
          style: (TestRunner.of(context)?.theme ?? Theme.of(context))
              .textTheme
              .subtitle2,
        ),
        title: Text(test.name),
        trailing: IgnorePointer(
          child: Switch.adaptive(
            onChanged: (_) => _setActive(test),
            value: _isActive(test),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var theme = TestRunner.of(context)?.theme ?? Theme.of(context);
    var translator = Translator.of(context);
    var suiteTests = _tests
        ?.where((test) => _suiteName == null || _suiteName == test.suiteName)
        ?.toList();

    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      contentPadding: EdgeInsets.only(top: 16.0),
                      title: Text(
                        translator.translate(
                          TestTranslations.atf_select_test_suite,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              setState(() => _suiteName = null);
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              translator.translate(
                                TestTranslations.atf_no_filter,
                              ),
                            ),
                            trailing: _suiteName == null
                                ? Icon(
                                    Icons.check_circle,
                                    color: theme.textTheme.bodyText2.color,
                                  )
                                : null,
                          ),
                          ...[
                            for (var suite in _testSuites)
                              ListTile(
                                onTap: () {
                                  setState(() => _suiteName = suite);
                                  Navigator.of(context).pop();
                                },
                                title: Text(suite),
                                trailing: _suiteName == suite
                                    ? Icon(
                                        Icons.check_circle,
                                        color: theme.textTheme.bodyText2.color,
                                      )
                                    : null,
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.play_circle_filled,
                ),
                onPressed:
                    _tests?.isNotEmpty == true ? () => _runTests() : null,
              ),
            ],
            title: Text(
              _translator.translate(TestTranslations.atf_tests),
            ),
          ),
          body: suiteTests == null || suiteTests?.isEmpty == true
              ? Center(
                  child: _tests == null
                      ? CircularProgressIndicator()
                      : Text(
                          _translator.translate(
                            TestTranslations.atf_no_tests_found,
                          ),
                        ),
                )
              : ListView.builder(
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) =>
                      _buildTest(context, suiteTests[index]),
                  itemCount: suiteTests.length,
                ),
        ),
      ),
    );
  }
}
