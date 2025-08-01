import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/autenticacao_service/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Provider.of<AuthService>(context, listen: false).getDadosPerfil(),
        builder: (ctx, snapshot) {
          // Estado de Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Estado de Erro
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Ocorreu um erro: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          // Estado de Sucesso (com dados)
          if (snapshot.hasData) {
            final profileData = snapshot.data!;
            // Extrai a lista de vínculos dos dados recebidos
            final List<dynamic> vinculos = profileData['vinculos'] ?? [];

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50), 
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Nome Completo'),
                        subtitle: Text(profileData['nome_completo'] ?? 'Não informado'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(profileData['email'] ?? 'Não informado'),
                      ),
                       const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('ID da Pessoa'),
                        subtitle: Text(profileData['id']?.toString() ?? '-'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Meus Perfis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Se não houver vínculos, mostra uma mensagem
                if (vinculos.isEmpty)
                  const Card(
                    child: ListTile(
                      title: Text('Nenhum perfil encontrado.'),
                      subtitle: Text('Crie ou se vincule a um estabelecimento.'),
                    ),
                  )
                else
                // Se houver vínculos, cria um Card para cada um
                ...vinculos.map((vinculo) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        vinculo['perfil'] == 'admin' ? Icons.admin_panel_settings_outlined 
                        : vinculo['perfil'] == 'profissional' ? Icons.work_outline 
                        : Icons.face_retouching_natural,
                      ),
                      title: Text('Perfil de ${vinculo['perfil']}'),
                      subtitle: Text('No estabelecimento: ${vinculo['estabelecimento']['nome_fantasia']}'),
                    ),
                  );
                }).toList(),
              ],
            );
          }
          // Caso padrão (não deve acontecer se a API funcionar)
          return const Center(child: Text('Nenhum dado encontrado.'));
        },
      ),
    );
  }
}
