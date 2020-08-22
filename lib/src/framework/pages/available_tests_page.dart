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
  })  : assert(autoRun != null),
        super(key: key);

  final bool autoRun;

  @override
  _AvailableTestsPageState createState() => _AvailableTestsPageState();
}

class _AvailableTestsPageState extends State<AvailableTestsPage> {
  final Map<String, bool> _active = {};
  List<Test> _tests;
  Translator _translator;
  TestController _testController;

  @override
  void initState() {
    super.initState();

    _translator = Translator.of(context);

    _testController = TestController.of(context);

    _loadTests();
  }

  bool _isActive(Test test) => _active[test.name] ?? test.active ?? false;

  void _loadTest(Test test) {
    _testController.currentTest = test;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => TestStepsPage(),
      ),
    );
  }

  Future<void> _loadTests() async {
    _tests = (await _testController.loadTests(context)) ?? [];
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
      if (_isActive(test) == true && test.steps?.isNotEmpty == true) {
        var steps = <TestStep>[];

        for (var step in test.steps) {
          steps.add(
            TestStep(
              id: step.id,
              values: step.values,
            ),
          );
        }

        tests.add(Test(
          name: test.name,
          steps: steps,
          version: test.version,
        ));
      }
    }

    await TestController.of(context)?.runTests(tests);
  }

  void _setActive(Test test) {
    var active = _isActive(test);

    _active[test.name] = active != true;

    if (mounted == true) {
      setState(() {});
    }
  }

  Widget _buildTest(BuildContext context, Test test) => ListTile(
        onLongPress: () => _loadTest(test),
        onTap: () => _setActive(test),
        subtitle: Text(
          _translator.translate(
            TestTranslations.atf_version_steps,
            {
              'steps': test.steps?.length,
              'version': test.version,
            },
          ),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        title: Text(test.name),
        trailing: IgnorePointer(
          child: Switch(
            onChanged: (_) => _setActive(test),
            value: _isActive(test),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.play_circle_filled,
            ),
            onPressed: _tests?.isNotEmpty == true ? () => _runTests() : null,
          ),
        ],
        title: Text(
          _translator.translate(TestTranslations.atf_tests),
        ),
      ),
      body: _tests == null || _tests?.isEmpty == true
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
                  _buildTest(context, _tests[index]),
              itemCount: _tests.length,
            ),
    );
  }
}
