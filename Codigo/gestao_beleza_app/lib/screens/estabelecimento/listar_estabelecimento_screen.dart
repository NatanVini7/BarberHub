import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/estabelecimento_service.dart';
import './criar_estabelecimento_screen.dart';
import '../usuario/home_screen_admin.dart';

class Estabelecimento {
  final int id;
  final String nome;
  final String perfil;
  //final String fotoUrl;

  Estabelecimento({
    required this.id,
    required this.nome,
    required this.perfil,
    //required this.fotoUrl,
  });

  factory Estabelecimento.fromJson(Map<String, dynamic> json) {
    return Estabelecimento(
      id: json['estabelecimento']['id'],
      nome: json['estabelecimento']['nome_fantasia'],
      perfil: json['perfil'],
    );
  }
}

class ListarEstabelecimentoScreen extends StatefulWidget {
  const ListarEstabelecimentoScreen({super.key});

  @override
  State<ListarEstabelecimentoScreen> createState() =>
      _ListarEstabelecimentoScreenState();
}

class _ListarEstabelecimentoScreenState
    extends State<ListarEstabelecimentoScreen> {
  //LISTA DE DADOS DE EXEMPLO (MOCK)
  late Future<List<dynamic>> _futureEstabelecimentos;

  @override
  void initState() {
    super.initState();
    _futureEstabelecimentos = Provider.of<EstabelecimentoService>(
      context,
      listen: false,
    ).listarMeusEstabelecimentos();
  }

  // TODO: Adicionar lógica de loading e tratamento de erros ao buscar dados reais.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Perfis e Vínculos'), // Título mais claro
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined),
            tooltip: 'Cadastrar novo estabelecimento',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CriarEstabelecimentoScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureEstabelecimentos,
        builder: (context, snapshot) {
          // ENQUANTO ESTÁ CARREGANDO
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // SE OCORREU UM ERRO
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          // SE TERMINOU, MAS NÃO HÁ DADOS
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum estabelecimento encontrado.\nCadastre um novo clicando no ícone "+".',
                textAlign: TextAlign.center,
              ),
            );
          }

          // SE DEU TUDO CERTO, CONSTRÓI A LISTA
          final vinculos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: vinculos.length,
            itemBuilder: (context, index) {
              // Converte o JSON de cada item para o nosso modelo de dados
              final estabelecimento = Estabelecimento.fromJson(vinculos[index]);

              // Aqui você usaria seu widget customizado para exibir o item
              return Card(
                // Exemplo simples com Card
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    estabelecimento.perfil == 'admin'
                        ? Icons.admin_panel_settings
                        : Icons.person,
                  ),
                  title: Text(estabelecimento.nome),
                  subtitle: Text('Meu perfil: ${estabelecimento.perfil}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreenAdmin(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
