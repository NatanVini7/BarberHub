import 'package:flutter/material.dart';
import 'package:gestao_beleza_app/screens/autenticacao/welcome_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart'; 
import 'usuario/home_screen_cliente.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    print('DEBUG: Wrapper reconstruído. Usuário está autenticado? ${authService.isAuth}');

    if (authService.isAuth) {
      return const HomeScreen();
    } else {
      return const WelcomeScreen();
    }
  }
}