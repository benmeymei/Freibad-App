import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final bool obscureText;
  final String Function(String) validator;
  final void Function(String) onSaved;

  static String defaultValidator(String value) {
    if (value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  static void defaultOnSaved(String value) {}

  CustomTextField({
    @required this.labelText,
    this.controller,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    String Function(String) validator,
    void Function(String) onSaved,
  })  : validator = validator ?? defaultValidator,
        onSaved = onSaved ?? defaultOnSaved;

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onSaved: widget.onSaved,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: _focusNode.hasFocus
              ? Theme.of(context).primaryColor
              : Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
