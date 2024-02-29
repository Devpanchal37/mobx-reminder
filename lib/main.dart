import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_reminder/dialogs/show_auth_error.dart';
import 'package:mobx_reminder/firebase_options.dart';
import 'package:mobx_reminder/loading/loading_screen.dart';
import 'package:mobx_reminder/screens/login_screen.dart';
import 'package:mobx_reminder/screens/register_screen.dart';
import 'package:mobx_reminder/screens/reminder_screen.dart';
import 'package:mobx_reminder/state/app_state.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
      Provider(create: (_) => AppState()..initialize(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReactionBuilder(
        builder: (context) {
          //Handle Loading Screen
          return autorun(
            (_) {
              final isLoading = context.read<AppState>().isLoading;
              if (isLoading) {
                LoadingScreen.instance()
                    .show(context: context, text: "Loading...");
              } else {
                LoadingScreen.instance().hide();
              }
              final authError = context.read<AppState>().authError;
              if (authError != null) {
                showAuthError(authError: authError, context: context);
              }
            },
          );
        },
        child: Observer(
          name: "current screen",
          builder: (context) {
            switch (context.read<AppState>().currentScreen) {
              case AppScreen.login:
                // TODO: Handle this case.
                return LogInScreen();
              case AppScreen.register:
                // TODO: Handle this case.
                return RegisterScreen();
              case AppScreen.reminders:
                // TODO: Handle this case.
                return const ReminderScreen();
            }
          },
        ),
      ),
    );
  }
}
