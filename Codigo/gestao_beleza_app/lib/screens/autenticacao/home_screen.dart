import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/autenticacao_service/auth_service.dart';
import '../../theme/theme_notifier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Página Inicial'),
            actions: [
              IconButton(
                icon: Icon(
                  themeNotifier.getThemeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined, 
                ),
                onPressed: () {
                  themeNotifier.toggleTheme();
                },
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  Provider.of<AuthService>(context, listen: false).logout();
                },
              ),
            ],
          ),
          body: const Center(
            child: Text('Você está logado!'),
          ),
        );
      },
    );
  }
}