import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class DropdownPage extends StatefulWidget {
  DropdownPage({Key key}) : super(key: key);

  @override
  _DropdownPageState createState() => _DropdownPageState();
}

class _DropdownPageState extends State<DropdownPage> {
  final Map<int, String> _values = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dropdown'),
      ),
      body: Material(
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (BuildContext context, int index) => Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Container(
                constraints: BoxConstraints(maxWidth: 420.0),
                child: TestableDropdownButtonFormField<String>(
                  autovalidate: true,
                  decoration: InputDecoration(
                    labelText: 'Dropdown $index',
                  ),
                  id: 'dropdown_$index',
                  items: [
                    for (var i = 0; i < 100; i++)
                      DropdownMenuItem<String>(
                        value: i.toString(),
                        child: Text('$i'),
                      ),
                  ],
                  onChanged: (value) {
                    _values[index] = value;
                    if (mounted == true) {
                      setState(() {});
                    }
                  },
                  validator: (String value) {
                    var validator = Validator(
                      validators: [
                        _CustomValidator(index),
                      ],
                    );

                    return validator.validate(
                      context: context,
                      label: 'Dropdown #$index',
                      value: value,
                    );
                  },
                  value: _values[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomValidator extends ValueValidator {
  _CustomValidator(this.min);

  final int min;

  @override
  Map<String, dynamic> toJson() => {};

  @override
  String validate({
    String label,
    Translator translator,
    String value,
  }) {
    String error;

    if (value != null) {
      if (int.parse(value) < min) {
        error = 'Pick a number at least: $min';
      }
    }

    return error;
  }
}
