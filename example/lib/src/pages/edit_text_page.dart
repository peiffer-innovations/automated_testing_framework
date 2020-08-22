import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';

class EditTextPage extends StatelessWidget {
  EditTextPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Text'),
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
                child: TestableTextFormField(
                  autovalidate: true,
                  decoration: InputDecoration(
                    labelText: 'Text $index',
                  ),
                  id: 'edit_text_$index',
                  validator: (String value) {
                    var validator = Validator(
                      validators: [
                        MinLengthValidator(length: index),
                      ],
                    );

                    return validator.validate(
                      context: context,
                      label: 'Text #$index',
                      value: value,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
