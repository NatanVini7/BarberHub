import 'package:flutter/material.dart';
import '../listar_estabelecimento_screen.dart';

class EstabelecimentoListItem extends StatelessWidget {
  final Estabelecimento estabelecimento;
  final VoidCallback onTap;

  const EstabelecimentoListItem({
    super.key,
    required this.estabelecimento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.surface,
                //backgroundImage: NetworkImage(estabelecimento.fotoUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  estabelecimento.nome,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Ver mais',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}