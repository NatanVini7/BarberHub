import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
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
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register(String name, String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.updateDisplayName(name);
  }
  
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // É crucial cancelar a inscrição do stream para evitar vazamento de memória
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}