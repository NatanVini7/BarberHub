import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/autenticacao_service/auth_service.dart';
import '/screens/profile_screen.dart'; // Importa a nova tela de perfil

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Você está logado!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navega para a tela de perfil ao clicar
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
                );
              },
              child: const Text('Ver Meu Perfil (API)'),
            ),
          ],
        ),
      ),
    );
  }
}