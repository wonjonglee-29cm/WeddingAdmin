import 'package:flutter/material.dart';
import 'package:wedding/design/ds_foundation.dart';

Widget buildSelectionButtons(String title, Map<bool, String> options, bool? groupValue, ValueChanged<bool?> onChanged, {String? description}) {
  return buildSection(
    title,
    Row(
      children: options.entries.map((entry) {
        final bool value = entry.key;
        final String text = entry.value;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: EdgeInsets.only(
                right: value ? 4 : 0,
                left: !value ? 4 : 0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: groupValue == value ? primaryColor : Colors.grey,
                  width: groupValue == value ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: bodyStyle1,
              ),
            ),
          ),
        );
      }).toList(),
    ),
    description: description,
  );
}

Widget buildSection(String title, Widget child, {String? description}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: titleStyle2),
      const SizedBox(height: 4),
      if (description != null) ...[
        Text(description, style: bodyStyle2.copyWith(color: Colors.grey)),
        title2Gap,
      ],
      child,
      itemsGap,
    ],
  );
}
