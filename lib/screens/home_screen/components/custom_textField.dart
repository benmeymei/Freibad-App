import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final String Function(String) validator;

  static String defaultValidator(String value) {
    if (value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  CustomTextField({
    @required this.labelText,
    @required this.controller,
    @required this.readOnly,
    this.keyboardType = TextInputType.text,
    String Function(String) validator,
  }) : validator = validator ?? defaultValidator;

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
      keyboardType: widget.keyboardType,
      validator: widget.validator,
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
