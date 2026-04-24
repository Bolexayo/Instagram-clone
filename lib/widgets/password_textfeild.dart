import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final TextInputType textInputType;
  const PasswordField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    required this.textInputType,
  });
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  // 1. Define the state variable
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
      borderRadius: BorderRadius.circular(15),
    );

    return TextField(
      // 2. Assign variable to obscureText
      obscureText: _isObscured,
      controller: widget.textEditingController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        contentPadding: const EdgeInsets.all(8),
        filled: true,
        // 3. Add the suffix IconButton
        suffixIcon: IconButton(
          icon: Icon(
            // Change icon based on state
            _isObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 25,
          ),
          onPressed: () {
            // 4. Toggle the state
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
    );
  }
}
