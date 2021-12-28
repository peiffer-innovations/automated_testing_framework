import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Tab that shows the test steps in a drag-and-drop reorderable format.
class TestStepListMarkdownTab extends StatefulWidget {
  TestStepListMarkdownTab({
    this.fromDialog,
    Key? key,
  }) : super(key: key);

  final bool? fromDialog;

  @override
  _TestStepListMarkdownTabState createState() =>
      _TestStepListMarkdownTabState();
}

class _TestStepListMarkdownTabState extends State<TestStepListMarkdownTab> {
  late TestController _testController;

  @override
  void initState() {
    super.initState();

    _testController = TestController.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: _testController
          .toBehaviorDrivenDescription(_testController.currentTest),
    );
  }
}
