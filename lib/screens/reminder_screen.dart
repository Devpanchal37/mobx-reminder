import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx_reminder/constant.dart';
import 'package:mobx_reminder/dialogs/delete_reminder_dialog.dart';
import 'package:mobx_reminder/dialogs/show_textfield_dialog.dart';
import 'package:mobx_reminder/hive_service/hive_reminder_model.dart';
import 'package:mobx_reminder/main.dart';
import 'package:mobx_reminder/screens/main_popup_menu.dart';
import 'package:mobx_reminder/state/reminder.dart';
import 'package:nb_utils/nb_utils.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: Observer(builder: (_) {
          print(
              "isconnected or not: ${localDatabaseState.isConnected.toString()}");
          return const Text(
            "Reminders",
            // context.read<AppState>().isConnected.toString(),
            // appState.isConnected.toString(),
            // localDatabaseState.isConnected.toString(),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
        actions: [
          const Image(
            image: AssetImage("assets/icon/edit.png"),
            height: 30,
            color: primaryColor,
          ).onTap(
            () async {
              final String? reminderText = await showTextFieldDialog(
                context: context,
                title: "what do you want to add",
                hintText: "enter here",
                optionsBuilder: () => {
                  TextFieldDialogButtonType.cancel: "cancel",
                  TextFieldDialogButtonType.confirm: "save"
                },
              );

              if (reminderText != null) {
                print("reminder text is not emptyy");
                // context.read<AppState>().createReminder(reminderText);
                appState.createReminder(reminderText);
              } else {
                return;
              }
            },
          ),
          const MainPopUpMenu()
        ],
      ),
      body: const ReminderViewList(),
    );
  }
}

class ReminderViewList extends StatelessWidget {
  const ReminderViewList({super.key});

  @override
  Widget build(BuildContext context) {
    print("sorted remider is : ${appState.sortedReminders}");
    // final appState = context.watch<AppState>();
    return Observer(
      builder: (context) {
        return ListView.builder(
          itemCount: appState.sortedReminders.length,
          itemBuilder: (context, index) {
            final reminder = appState.sortedReminders[index];
            final creationDate =
                DateFormat('d-MMM-yy').format(reminder.creationDate);
            return CheckboxListTile(
              contentPadding: const EdgeInsets.only(left: 10),
              controlAffinity: ListTileControlAffinity.leading,
              value: reminder.isDone,
              onChanged: (isDone) {
                appState.modify(reminder, isDone: isDone ?? false);
                reminder.isDone = isDone ?? false;
              },
              title: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${reminder.text}",
                          style: CommonStyles.primaryTextStyle,
                        ).expand(),
                        Text(
                          creationDate,
                          style: const TextStyle(color: dateColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final shouldDeleteReminder =
                            await showDeleteReminderDialog(context);
                        if (shouldDeleteReminder) {
                          appState.delete(reminder.id);
                        }
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: redColors,
                      ))
                ],
              ),
            );
          },
        );
      },
    );
  }
}
