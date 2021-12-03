import 'package:flutter/material.dart';
import 'package:shared_widgets/shared_widgets.dart';

TextField buildTextField({
  required ValueChanged<String> onChanged,
  Widget? prefixIcon,
  Color? fillColor,
  String? hintText,
  double borderRadius = 10,
  Color borderColor = gray,
  EdgeInsets prefixPadding = const EdgeInsets.only(left: 15, right: 13),
}) {
  return TextField(
    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 16.5),
      prefixIcon: Padding(
        padding: prefixPadding,
        child: prefixIcon,
      ),
      prefixIconConstraints: const BoxConstraints(
        minHeight: 24,
        minWidth: 24,
      ),
      fillColor: fillColor,
      hintText: hintText,
      filled: fillColor != null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: borderColor,
          width: 0.6,
        ),
      ),
    ),
  );
}
