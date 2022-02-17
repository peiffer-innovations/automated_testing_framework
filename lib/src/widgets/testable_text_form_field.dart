import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An extention to the standard [TextFormField] that is wrapped with a
/// [Testable].
///
/// See also:
/// * [TextFormField]
class TestableTextFormField extends StatefulWidget {
  TestableTextFormField({
    this.autocorrect = true,
    this.autofillHints,
    this.autofocus = false,
    // ignore: deprecated_member_use_from_same_package
    @Deprecated('Use [autovalidateMode] instead') this.autovalidate,
    this.autovalidateMode,
    this.buildCounter,
    this.controller,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorWidth = 2.0,
    this.decoration = const InputDecoration(),
    this.enableInteractiveSelection = true,
    this.enableSuggestions = true,
    this.enabled = true,
    this.expands = false,
    this.focusNode,
    this.gestures,
    this.id,
    this.initialValue,
    this.inputFormatters,
    this.keyboardAppearance,
    this.keyboardType,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.maxLines,
    this.minLines,
    this.obscureText = false,
    this.obscuringCharacter = '*',
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.onTap,
    this.readOnly = false,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.scrollPhysics,
    this.scrollableId,
    this.showCursor,
    this.smartDashesType,
    this.smartQuotesType,
    this.strutStyle,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textCapitalization = TextCapitalization.none,
    this.textDirection,
    this.textInputAction,
    this.toolbarOptions,
    this.validator,
  });

  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final bool? autovalidate;
  final AutovalidateMode? autovalidateMode;
  final InputCounterWidgetBuilder? buildCounter;
  final TextEditingController? controller;
  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final double cursorWidth;
  final dynamic decoration;
  final bool enableInteractiveSelection;
  final bool enableSuggestions;
  final bool enabled;
  final bool expands;
  final FocusNode? focusNode;
  final TestableGestures? gestures;
  final String? id;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final Brightness? keyboardAppearance;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool maxLengthEnforced;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final String obscuringCharacter;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final VoidCallback? onTap;
  final bool readOnly;
  final EdgeInsetsGeometry scrollPadding;
  final ScrollPhysics? scrollPhysics;
  final String? scrollableId;
  final bool? showCursor;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final StrutStyle? strutStyle;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextCapitalization textCapitalization;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final ToolbarOptions? toolbarOptions;
  final String? Function(String?)? validator;

  @override
  _TestableTextFormFieldState createState() => _TestableTextFormFieldState();
}

class _TestableTextFormFieldState extends State<TestableTextFormField> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ??
        TextEditingController(
          text: widget.initialValue,
        );
  }

  @override
  void dispose() {
    // If the controller on the widget isn't null then we don't own the
    // controller so don't dispose it.
    if (widget.controller == null) {
      _controller!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Testable(
        gestures: widget.gestures,
        id: widget.id,
        scrollableId: widget.scrollableId,
        onRequestValue: () => _controller!.text,
        onSetValue: widget.enabled == true
            ? (dynamic value) => _controller!.text = value
            : null,
        child: TextFormField(
          autocorrect: widget.autocorrect,
          autofillHints: widget.autofillHints,
          autofocus: widget.autofocus,
          autovalidateMode: widget.autovalidate == null
              ? widget.autovalidateMode
              : widget.autovalidate == true
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
          buildCounter: widget.buildCounter,
          controller: _controller,
          cursorColor: widget.cursorColor,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius,
          cursorWidth: widget.cursorWidth,
          decoration: widget.decoration,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          enableSuggestions: widget.enableSuggestions,
          enabled: widget.enabled,
          expands: widget.expands,
          focusNode: widget.focusNode,
          initialValue: widget.initialValue,
          inputFormatters: widget.inputFormatters,
          keyboardAppearance: widget.keyboardAppearance,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,

          // ignore: deprecated_member_use
          maxLengthEnforced: widget.maxLengthEnforced,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscuringCharacter,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onFieldSubmitted,
          onSaved: widget.onSaved,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          scrollPadding: widget.scrollPadding as EdgeInsets,
          scrollPhysics: widget.scrollPhysics,
          showCursor: widget.showCursor,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          strutStyle: widget.strutStyle,
          style: widget.style,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          textCapitalization: widget.textCapitalization,
          textDirection: widget.textDirection,
          textInputAction: widget.textInputAction,
          toolbarOptions: widget.toolbarOptions,
          validator: widget.validator,
        ),
      );
}
