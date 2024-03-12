import 'package:flutter/material.dart';
import 'package:mobx_reminder/constant.dart';

enum TextFieldDialogButtonType { cancel, confirm }

typedef DialogOptionBuilder = Map<TextFieldDialogButtonType, String> Function();

late final controller = TextEditingController();

Future<String?> showTextFieldDialog({
  required BuildContext context,
  required String title,
  required String? hintText,
  required DialogOptionBuilder optionsBuilder,
}) {
  controller.clear();
  final options = optionsBuilder();
  return showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: InputDecoration(
              hintText: hintText, hintStyle: TextStyle(color: primaryColor)),
        ),
        actions: options.entries.map(
          (option) {
            return TextButton(
              onPressed: () {
                switch (option.key) {
                  case TextFieldDialogButtonType.cancel:
                    Navigator.of(context).pop();
                    break;
                  case TextFieldDialogButtonType.confirm:
                    Navigator.of(context).pop(controller.text);
                    break;
                }
              },
              child: Text(
                option.value,
              ),
            );
          },
        ).toList(),
      );
    },
  );
}
