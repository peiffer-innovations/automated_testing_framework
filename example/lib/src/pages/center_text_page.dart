import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

class CenterTextPage extends StatelessWidget {
  CenterTextPage({
    Key key,
    @required this.text,
  })  : assert(text != null),
        super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Center Text')),
      body: Center(
        child: Material(
          borderRadius: BorderRadius.circular(8.0),
          elevation: 2.0,
          child: Testable(
            id: 'center_text',
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(text),
            ),
          ),
        ),
      ),
    );
  }
}
