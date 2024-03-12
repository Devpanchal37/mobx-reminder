import 'package:flutter/material.dart';
import 'package:mobx_reminder/main.dart';
import 'package:mobx_reminder/state/app_state.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailCont = TextEditingController();

  final TextEditingController passCont = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
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
                  appState.register(email: email, password: password);
                  // context
                  //     .read<AppState>()
                  //     .register(email: email, password: password);
                },
                child: const Text("Register In")),
            TextButton(
                onPressed: () {
                  // context.read<AppState>().goTo(AppScreen.login);
                  appState.goTo(AppScreen.login);
                },
                child: const Text("Already account, Log In"))
          ],
        ),
      ),
    );
  }
}
