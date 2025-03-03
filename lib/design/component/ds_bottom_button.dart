import 'package:flutter/material.dart';
import 'package:wedding/design/ds_foundation.dart';

Widget bottomButtonWidget({
  required VoidCallback? onPressed,
  required String text,
  bool isEnabled = true,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
}) => Padding(
  padding: padding,
  child: Material(
    color: Colors.transparent,
    child: Ink(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isEnabled ? primaryColor : secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: whiteBodyStyle1.copyWith(
              letterSpacing: 2
            ),
          ),
        ),
      ),
    ),
  ),
);