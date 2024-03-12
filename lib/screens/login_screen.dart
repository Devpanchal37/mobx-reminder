import 'package:flutter/material.dart';
import 'package:mobx_reminder/constant.dart';
import 'package:mobx_reminder/main.dart';
import 'package:mobx_reminder/state/app_state.dart';

class LogInScreen extends StatelessWidget {
  final emailCont = TextEditingController(text: "demo@provider.com");

  final passCont = TextEditingController(text: "12345678");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text("Log in "),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCont,
              decoration: const InputDecoration(hintText: "Enter Email"),
            ),
            TextField(
              controller: passCont,
              decoration: const InputDecoration(hintText: "Enter Password"),
            ),
            TextButton(
                onPressed: () {
                  final email = emailCont.text.trim();
                  final password = passCont.text.trim();
                  // context
                  //     .read<AppState>()
                  //     .login(email: email, password: password);
                  appState.login(email: email, password: password);
                },
                child: const Text(
                  "Log In",
                )),
            TextButton(
                onPressed: () {
                  // context.read<AppState>().goTo(AppScreen.register);
                  appState.goTo(AppScreen.register);
                },
                child: const Text("New Register"))
          ],
        ),
      ),
    );
  }
}
