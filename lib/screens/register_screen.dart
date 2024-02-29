import 'package:flutter/material.dart';
import 'package:mobx_reminder/state/app_state.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  TextEditingController emailCont = TextEditingController();

  TextEditingController passCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                  context
                      .read<AppState>()
                      .register(email: email, password: password);
                },
                child: const Text("Register In")),
            TextButton(
                onPressed: () {
                  context.read<AppState>().goTo(AppScreen.login);
                },
                child: const Text("Already account, Log In"))
          ],
        ),
      ),
    );
  }
}
