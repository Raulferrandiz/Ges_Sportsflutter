import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required controller,
    required validator,
    required label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //controller: controller,
      //validator: validator,
      decoration: InputDecoration(
        //labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
