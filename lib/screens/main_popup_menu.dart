import 'package:flutter/material.dart';
import 'package:mobx_reminder/constant.dart';
import 'package:mobx_reminder/dialogs/delete_account_dialog.dart';
import 'package:mobx_reminder/dialogs/logout_dialog.dart';
import 'package:mobx_reminder/main.dart';
import 'package:mobx_reminder/state/app_state.dart';
import 'package:provider/provider.dart';

enum mainActionMenu { logout, deleteAccount }

class MainPopUpMenu extends StatelessWidget {
  const MainPopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      iconSize: 35,
      color: appBarColor,
      onSelected: (value) async {
        switch (value) {
          case mainActionMenu.logout:
            final shouldLogOut = await showLogOutDialog(context);
            if (shouldLogOut) {
              appState.logOut();
            }
            break;
          case mainActionMenu.deleteAccount:
            final shouldDeleteAccount = await showDeleteAccountDialog(context);
            if (shouldDeleteAccount) {
              appState.deleteAccount();

              break;
            }
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<mainActionMenu>(
            child: Text("Log Out"),
            value: mainActionMenu.logout,
          ),
          const PopupMenuItem<mainActionMenu>(
            child: Text("Delete Account"),
            value: mainActionMenu.deleteAccount,
          ),
        ];
      },
    );
  }
}
