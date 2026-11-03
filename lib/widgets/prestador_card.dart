import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/prestador.dart';

class PrestadorCard extends StatelessWidget {
  final Prestador prestador;
  final VoidCallback onTap;

  const PrestadorCard({super.key, required this.prestador, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final categoria = Repositorio.instancia.categoriaPorId(prestador.categoriaId);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cores.primaryContainer,
          child: Text(prestador.iniciais),
        ),
        title: Text(prestador.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${categoria.nome} • ${prestador.bairro}\n${prestador.faixaPreco}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              Text(prestador.avaliacao.toStringAsFixed(1)),
            ]),
            const SizedBox(height: 4),
            Text(
              prestador.disponivel ? 'Disponível' : 'Ocupado',
              style: TextStyle(
                fontSize: 12,
                color: prestador.disponivel ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
