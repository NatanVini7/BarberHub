import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/autenticacao/home_screen.dart';
import '/screens/autenticacao/welcome_screen.dart'; 

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //Provider.of "escuta" o valor que o StreamProvider está fornecendo.
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const WelcomeScreen(); 
    } else {
      return const HomeScreen();
    }
  }
}