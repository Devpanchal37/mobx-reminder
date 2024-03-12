import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_reminder/dialogs/show_auth_error.dart';
import 'package:mobx_reminder/firebase_options.dart';
import 'package:mobx_reminder/hive_service/hive_reminder_model.dart';
import 'package:mobx_reminder/hive_service/hive_service.dart';
import 'package:mobx_reminder/loading/loading_screen.dart';
import 'package:mobx_reminder/screens/login_screen.dart';
import 'package:mobx_reminder/screens/register_screen.dart';
import 'package:mobx_reminder/screens/reminder_screen.dart';
import 'package:mobx_reminder/state/app_state.dart';
import 'package:mobx_reminder/state/local_database_state.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

late Box box;
late Box<ReminderHive> reminderBox;
AppState appState = AppState();
LocalDatabaseState localDatabaseState = LocalDatabaseState();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final appDocumentDirectory =
  //     await path_provider.getApplicationDocumentsDirectory();
  // Hive.init(appDocumentDirectory.path);
  // Hive.registerAdapter(FutureBoolAdapter());
  // box = await Hive.openBox("myBox");
  print("before hive init");
  await Hive.initFlutter();
  print("after hive init");
  Hive.registerAdapter(ReminderHiveAdapter());
  // print("after register hive adapterrr");
  try {
    box = await Hive.openBox('myBox');
    reminderBox = await Hive.openBox<ReminderHive>('reminderBox');
    print("box reminderbox box open ");
  } catch (e) {
    print("HIVE box open error : $e");
  }
  print("after hive box open");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await appState.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void dispose() {
    localDatabaseState.disposeConnectivity();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReactionBuilder(
        builder: (context) {
          //Handle Loading Screen
          return autorun(
            (_) {
              // final isLoading = context.read<AppState>().isLoading;
              final isloading = appState.isLoading;
              if (isloading) {
                LoadingScreen.instance()
                    .show(context: context, text: "Loading...");
              } else {
                LoadingScreen.instance().hide();
              }
              final authError = appState.authError;
              if (authError != null) {
                showAuthError(authError: authError, context: context);
              }
            },
          );
        },
        child: Observer(
          name: "current screen",
          builder: (context) {
            switch (appState.currentScreen) {
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
