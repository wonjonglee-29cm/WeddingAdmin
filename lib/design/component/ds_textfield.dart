import 'package:flutter/material.dart';
import 'package:wedding/design/ds_foundation.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? labelText;
  final int? maxLength;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;

  const TextFieldWidget({
    super.key,
    this.controller,
    this.hint,
    this.labelText,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            TextFormField(
              style: bodyStyle2,
              cursorColor: secondaryColor,
              cursorErrorColor: Colors.red,
              cursorWidth: 2,
              controller: controller,
              maxLength: maxLength,
              onChanged: onChanged,
              validator: validator,
              obscureText: obscureText,
              keyboardType: keyboardType,
              decoration: (decoration ??
                      InputDecoration(
                        hintText: hint,
                        labelText: labelText,
                        border: const OutlineInputBorder(),
                      ))
                  .copyWith(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            if (maxLength != null)
              Positioned(
                right: 16,
                bottom: 16,
                child: ValueListenableBuilder(
                  valueListenable: controller!,
                  builder: (context, value, child) => Text(
                    '${value.text.length}/$maxLength',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

InputDecoration defaultDecor({String? hint, String? labelText}) => InputDecoration(
      hintText: hint,
      hintStyle: bodyStyle2.copyWith(color: Colors.grey[300]),
      labelText: labelText,
      labelStyle: bodyStyle2,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      fillColor: Colors.white,
      // 배경색
      filled: true,
    );
