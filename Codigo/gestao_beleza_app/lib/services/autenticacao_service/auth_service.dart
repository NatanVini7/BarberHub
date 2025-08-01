import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String _baseUrl = 'http://10.0.2.2:3000'; 
  User? _user;
  late StreamSubscription<User?> _authSubscription;

  AuthService() {
    _authSubscription = _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isAuth => _user != null;

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners(); 
  }

  Future<void> login(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

      if (userCredential.user != null) {
      final idToken = await userCredential.user!.getIdToken();
      print('====================== TOKEN PARA USAR NO THUNDER CLIENT ======================');
      print(idToken);
      print('=============================================================================');
    }
  }

  Future<void> register(String name, String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    // Adiciona o nome do usuário ao perfil do Firebase
    await userCredential.user?.updateDisplayName(name);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Retorna o Token de ID do Firebase para o usuário logado.
  Future<String?> getFirebaseIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final idToken = await user.getIdToken();
      return idToken;
    }
    return null;
  }

  /// Busca os dados do perfil do usuário na sua API NestJS.
  Future<Map<String, dynamic>> getDadosPerfil() async {
    final token = await getFirebaseIdToken();
    if (token == null) {
      throw 'Nenhum usuário logado. Faça o login novamente.';
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        '$_baseUrl/auth/profile', // Endpoint protegido no NestJS
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Envia o token para autorização
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Não foi possível buscar os dados do perfil.';
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
