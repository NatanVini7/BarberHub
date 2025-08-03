import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import './profile_menu.dart';
import '../estabelecimento/listar_estabelecimento_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa o usuário atual para pegar informações como nome e email
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              //FOTO DE PERFIL COM BOTÃO DE EDITAR
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    // TODO: Adicionar a imagem do usuário aqui
                    // backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 3,
                          color: colorScheme.surface,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: Adicionar lógica para editar a foto
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              //NOME DO USUÁRIO
              Text(
                user?.displayName ?? 'Nome do Usuário',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ProfileMenuOption(
                icon: Icons.person_outline,
                title: 'Perfil',
                onTap: () {},
              ),
              ProfileMenuOption(
                icon: Icons.content_cut,
                title: 'Salão',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ListarEstabelecimentoScreen(),
                    ),
                  );
                },
              ),
              ProfileMenuOption(
                icon: Icons.favorite_border,
                title: 'Favoritos',
                onTap: () {},
              ),
              ProfileMenuOption(
                icon: Icons.payment_outlined,
                title: 'Opções de Pagamentos',
                onTap: () {},
              ),
              ProfileMenuOption(
                icon: Icons.lock_outline,
                title: 'Mudar Senha',
                onTap: () {},
              ),
              ProfileMenuOption(
                icon: Icons.help_outline,
                title: 'Central de Ajuda',
                onTap: () {},
              ),
              ProfileMenuOption(
                icon: Icons.shield_outlined,
                title: 'Política de Privacidade',
                onTap: () {},
              ),
              ProfileMenuOption(
                icon: Icons.settings_outlined,
                title: 'Configurações',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              // Opção de Logout com cor de destaque
              ProfileMenuOption(
                icon: Icons.logout,
                title: 'Sair',
                textColor: colorScheme.error,
                onTap: () {
                  Provider.of<AuthService>(context, listen: false).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
