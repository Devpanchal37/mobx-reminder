import 'package:flutter/material.dart' show BuildContext;
import 'package:mobx_reminder/auth/auth_error.dart';
import 'package:mobx_reminder/dialogs/generic_dialog.dart';

Future<void> showAuthError({
  required AuthError authError,
  required BuildContext context,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionsBuilder: () => {
      'OK': true,
    },
  );
}
