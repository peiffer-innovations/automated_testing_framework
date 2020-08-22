import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

class TestableFormField<T> extends StatelessWidget {
  TestableFormField({
    this.autovalidate = false,
    @required this.builder,
    this.enabled = true,
    @required this.id,
    this.initialValue,
    this.onSaved,
    this.scrollableId,
    this.validator,
  }) : assert(id?.isNotEmpty == true);

  final bool autovalidate;
  final FormFieldBuilder<T> builder;
  final bool enabled;
  final String id;
  final T initialValue;
  final FormFieldSetter<T> onSaved;
  final FormFieldValidator<T> validator;
  final String scrollableId;

  @override
  Widget build(BuildContext context) => FormField(
        autovalidate: autovalidate,
        builder: (FormFieldState<T> state) => Testable(
          id: id,
          onRequestValue: () => state.value,
          onSetValue: (value) => state.didChange(value),
          scrollableId: scrollableId,
          child: builder(state),
        ),
        enabled: enabled,
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
      );
}
