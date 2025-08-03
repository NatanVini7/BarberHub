import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestao_beleza_app/services/estabelecimento_service.dart';
import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart'; // TODO: Adicionar o pacote image_picker no pubspec.yaml

class CriarEstabelecimentoScreen extends StatefulWidget {
  const CriarEstabelecimentoScreen({super.key});

  @override
  State<CriarEstabelecimentoScreen> createState() =>
      _CriarEstabelecimentoScreenState();
}

class _CriarEstabelecimentoScreenState extends State<CriarEstabelecimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _razaoSocialController = TextEditingController();
  final _documentoController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nomeController.dispose();
    _razaoSocialController.dispose();
    _documentoController.dispose();
    super.dispose();
  }

  // Função placeholder para escolher a imagem
  Future<void> _pickImage() async {
    // TODO: Implementar a lógica de seleção de imagem.
    // 1. Adicione o pacote `image_picker` ao seu pubspec.yaml:
    //    dependencies:
    //      image_picker: ^1.0.4
    // 2. Rode `flutter pub get`
    // 3. Descomente o código abaixo e o import no topo do arquivo.
    /*
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
    */
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ocorreu um Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      await Provider.of<EstabelecimentoService>(
        context,
        listen: false,
      ).criarEstabelecimento(
        nomeFantasia: _nomeController.text,
        razaoSocial: _razaoSocialController.text,
        documento: _documentoController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estabelecimento cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Estabelecimento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // SELETOR DE IMAGEM
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.surface,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? Icon(
                              Icons.storefront,
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
                            color: colorScheme.background,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _nomeController,
                  labelText: 'Nome do Estabelecimento',
                  icon: Icons.store_mall_directory_outlined,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório.'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _razaoSocialController,
                  labelText: 'Razão Social',
                  icon: Icons.business_center_outlined,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _documentoController,
                  labelText: 'Documento (CPF/CNPJ)',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório.'
                      : null,
                ),
                const SizedBox(height: 40),

                // BOTÃO DE SUBMISSÃO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Salvar Estabelecimento',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
      ),
    );
  }
}
