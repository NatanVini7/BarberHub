import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // O Stream que o Wrapper já está ouvindo.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Método de login usando o Firebase
  Future<void> login(String email, String password) async {
    // O try/catch agora está dentro do _submit da tela de login,
    // então podemos simplesmente deixar a exceção subir.
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Não precisamos do notifyListeners(), o stream authStateChanges cuida disso.
  }

  // Método de registro usando o Firebase
  Future<void> register(String name, String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Opcional: Salva o nome do usuário no perfil do Firebase
    await userCredential.user?.updateDisplayName(name);
  }
  
  // Método de logout usando o Firebase
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    // O stream authStateChanges vai emitir 'null' automaticamente.
  }
}