import 'package:flutter/material.dart';
import 'package:gestao_beleza_app/screens/autenticacao/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/autenticacao_service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String errorCode) {
    String friendlyMessage = 'Ocorreu um erro. Tente novamente mais tarde.';

    switch (errorCode) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        friendlyMessage =
            'Email ou senha inválidos. Por favor, verifique e tente novamente.';
        break;
      case 'invalid-email':
        friendlyMessage = 'O formato do email é inválido.';
        break;
      case 'user-disabled':
        friendlyMessage = 'Esta conta de usuário foi desabilitada.';
        break;
      case 'network-request-failed':
        friendlyMessage =
            'Não foi possível conectar. Verifique sua conexão com a internet.';
        break;
      default:
        print('CÓDIGO DE ERRO NÃO TRATADO: $errorCode');
        friendlyMessage = 'Ocorreu um erro inesperado. Tente novamente.';
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro de Autenticação'),
        content: Text(friendlyMessage),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Salva os dados do formulário
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o método de login do nosso AuthService
      await Provider.of<AuthService>(
        context,
        listen: false,
      ).login(_emailController.text.trim(), _passwordController.text.trim());

      // Após o login bem-sucedido, limpamos a pilha e vamos para a HomeScreen.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.code);
    } catch (error) {
      _showErrorDialog('Erro desconhecido');
    }
    // Apenas atualiza o estado se o widget ainda estiver montado
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 33, 37, 41),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(45.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 48.0, left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 24.0),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Bem-Vindo de volta!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Ficamos felizes por ter você de volta.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 10),
                    _buildRememberMeCheckbox(),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F0F0),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o campo de Email
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: (value) {
        if (value == null || value.trim().isEmpty || !value.contains('@')) {
          return 'Por favor, insira um email válido.';
        }
        return null;
      },
    );
  }

  // Widget para o campo de Senha
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Senha',
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, insira sua senha.';
        }
        if (value.length < 8) {
          return 'A senha deve ter pelo menos 8 caracteres.';
        }
        return null;
      },
    );
  }

  // Widget para o checkbox (sem alterações)
  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (bool? value) {
            setState(() {
              _rememberMe = value!;
            });
          },
          checkColor: Colors.black, // Cor do "check"
          activeColor: Colors.white, // Cor da caixa quando marcada
          side: const BorderSide(color: Colors.white54),
        ),
        const Text(
          'Lembrar de mim',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white70),
        ),
      ],
    );
  }
}
