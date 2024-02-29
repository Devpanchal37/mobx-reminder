import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx_reminder/dialogs/delete_reminder_dialog.dart';
import 'package:mobx_reminder/dialogs/show_textfield_dialog.dart';
import 'package:mobx_reminder/screens/main_popup_menu.dart';
import 'package:mobx_reminder/state/app_state.dart';
import 'package:provider/provider.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders"),
        actions: [
          IconButton(
              onPressed: () async {
                final reminderText = await showTextFieldDialog(
                  context: context,
                  title: "what do you want to add",
                  hintText: "enter here",
                  optionsBuilder: () => {
                    TextFieldDialogButtonType.cancel: "cancel",
                    TextFieldDialogButtonType.confirm: "save"
                  },
                );

                if (reminderText != null) {
                  context.read<AppState>().createReminder(reminderText);
                } else {
                  return;
                }
              },
              icon: const Icon(Icons.add)),
          const MainPopUpMenu()
        ],
      ),
      body: ReminderViewList(),
    );
  }
}

class ReminderViewList extends StatelessWidget {
  const ReminderViewList({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Observer(
      builder: (context) {
        return ListView.builder(
          itemCount: appState.sortedReminders.length,
          itemBuilder: (context, index) {
            final reminder = appState.sortedReminders[index];
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: reminder.isDone,
              onChanged: (isDone) {
                appState.modify(reminder, isDone: isDone ?? false);
                reminder.isDone = isDone ?? false;
              },
              title: Row(
                children: [
                  Expanded(child: Text(reminder.text)),
                  IconButton(
                      onPressed: () async {
                        final shouldDeleteReminder =
                            await showDeleteReminderDialog(context);
                        if (shouldDeleteReminder) {
                          appState.delete(reminder);
                        }
                      },
                      icon: Icon(Icons.delete))
                ],
              ),
            );
          },
        );
      },
    );
  }
}
