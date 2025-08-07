import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.fieldType,
    required this.enabled,
  });

  final TextEditingController controller;
  final String fieldType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey),
        decoration: InputDecoration(
          labelText: fieldType,
          labelStyle: const TextStyle(color: Color(0xFF757575), fontSize: 20),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: enabled ? Colors.white : Color(0xFF90a9f0),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF225DE6), width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: enabled ? Colors.grey : Colors.grey.shade500,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: enabled ? Colors.grey : Colors.grey.shade500,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
