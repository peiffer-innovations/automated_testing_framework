import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

/// An extention to the standard [FormField] that is wrapped with a [Testable].
///
/// See also:
/// * [FormField]
class TestableFormField<T> extends StatelessWidget {
  TestableFormField({
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use [autovalidateMode] instead') this.autovalidate,
    this.autovalidateMode,
    required this.builder,
    this.enabled = true,
    required this.id,
    this.initialValue,
    this.onSaved,
    this.scrollableId,
    this.validator,
  });

  final bool? autovalidate;
  final AutovalidateMode? autovalidateMode;
  final FormFieldBuilder<T> builder;
  final bool enabled;
  final String id;
  final T? initialValue;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final String? scrollableId;

  @override
  Widget build(BuildContext context) => FormField(
        autovalidateMode: autovalidate == null
            ? autovalidateMode
            : autovalidate == true
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
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
