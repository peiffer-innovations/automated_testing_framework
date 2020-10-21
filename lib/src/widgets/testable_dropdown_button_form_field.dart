import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';

/// An extention to the standard [DropdownButtonFormField] that is wrapped with
/// a [Testable].
///
/// See also:
/// * [DropdownButtonFormField]
class TestableDropdownButtonFormField<T> extends StatefulWidget {
  TestableDropdownButtonFormField({
    this.autofocus = false,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use [autovalidateMode] instead') this.autovalidate,
    this.autovalidateMode,
    this.decoration = const InputDecoration(),
    this.disabledHint,
    this.dropdownColor,
    this.elevation = 8,
    this.enabled = true,
    this.focusColor,
    this.focusNode,
    this.hint,
    this.icon,
    this.iconSize = 24.0,
    this.id,
    this.items,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.isDense = true,
    this.isExpanded = false,
    this.itemHeight,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.scrollableId,
    this.selectedItemBuilder,
    this.validator,
    this.style,
    this.value,
  });

  final bool autofocus;
  final bool autovalidate;
  final AutovalidateMode autovalidateMode;
  final dynamic decoration;
  final Widget disabledHint;
  final Color dropdownColor;
  final int elevation;
  final bool enabled;
  final Color focusColor;
  final FocusNode focusNode;
  final Widget hint;
  final Widget icon;
  final String id;
  final List<DropdownMenuItem<T>> items;
  final Color iconDisabledColor;
  final double iconSize;
  final Color iconEnabledColor;
  final bool isDense;
  final bool isExpanded;
  final double itemHeight;
  final ValueChanged onChanged;
  final FormFieldSetter<T> onSaved;
  final VoidCallback onTap;
  final String scrollableId;
  final dynamic selectedItemBuilder;
  final FormFieldValidator<T> validator;
  final TextStyle style;
  final T value;

  @override
  _TestableDropdownButtonFormFieldState<T> createState() =>
      _TestableDropdownButtonFormFieldState<T>();
}

class _TestableDropdownButtonFormFieldState<T>
    extends State<TestableDropdownButtonFormField<T>> {
  String _error;

  @override
  Widget build(BuildContext context) {
    return Testable(
      id: widget.id,
      onRequestError: () => _error,
      onRequestValue: () => widget.value,
      onSetValue:
          widget.onChanged == null ? null : (value) => widget.onChanged(value),
      scrollableId: widget.scrollableId,
      child: DropdownButtonFormField<T>(
        autofocus: widget.autofocus,
        autovalidateMode: widget.autovalidate == null
            ? widget.autovalidateMode
            : widget.autovalidate == true
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
        decoration: widget.decoration,
        disabledHint: widget.disabledHint,
        dropdownColor: widget.dropdownColor,
        elevation: widget.elevation,
        focusColor: widget.focusColor,
        focusNode: widget.focusNode,
        hint: widget.hint,
        icon: widget.icon,
        items: widget.items,
        iconDisabledColor: widget.iconDisabledColor,
        iconEnabledColor: widget.iconEnabledColor,
        iconSize: widget.iconSize,
        isDense: widget.isDense,
        isExpanded: widget.isExpanded,
        itemHeight: widget.itemHeight,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        onTap: widget.onTap,
        selectedItemBuilder: widget.selectedItemBuilder,
        validator: widget.validator == null
            ? null
            : (value) {
                _error = widget.validator(value);
                return _error;
              },
        style: widget.style,
        value: widget.value,
      ),
    );
  }
}
