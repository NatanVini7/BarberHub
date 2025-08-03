import 'package:dio/dio.dart';
import './auth_service.dart';

class EstabelecimentoService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://10.0.2.2:3000'; // URL base da sua API
  final AuthService _authService;

  // O serviço depende do AuthService para funcionar
  EstabelecimentoService(this._authService);

  Future<void> criarEstabelecimento({
    required String nomeFantasia,
    String? razaoSocial,
    String? documento,
    // File? imagem, // TODO: Lógica de upload de imagem será adicionada depois
  }) async {
    // 1. Pega o token do usuário logado
    final token = await _authService.getFirebaseIdToken();
    if (token == null) {
      throw 'Você precisa estar logado para criar um estabelecimento.';
    }

    //Monta o corpo da requisição
    final Map<String, dynamic> dados = {
      'nome_fantasia': nomeFantasia,
      if (razaoSocial != null && razaoSocial.isNotEmpty) 'razao_social': razaoSocial,
      if (documento != null && documento.isNotEmpty) 'documento': documento,
    };

    try {
      // Faz a chamada POST para a API, enviando o token no cabeçalho
      await _dio.post(
        '$_baseUrl/estabelecimentos',
        data: dados,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      //Trata possíveis erros da API e retorna uma mensagem clara
      throw e.response?.data['message'] ?? 'Ocorreu um erro desconhecido.';
    }
  }

  Future<List<dynamic>> listarMeusEstabelecimentos() async {
    final token = await _authService.getFirebaseIdToken();
    if (token == null) {
      throw 'Você precisa estar logado para ver seus estabelecimentos.';
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/estabelecimentos',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Ocorreu um erro ao buscar os estabelecimentos.';
    }
  }
}
