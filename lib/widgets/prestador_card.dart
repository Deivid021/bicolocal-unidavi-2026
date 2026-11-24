import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/prestador.dart';
import 'nota_estrelas.dart';

class PrestadorCard extends StatelessWidget {
  final Prestador prestador;
  final VoidCallback onTap;

  const PrestadorCard({super.key, required this.prestador, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final repo = Repositorio.instancia;
    final categoria = repo.categoriaPorId(prestador.categoriaId);
    final favorito = repo.ehFavorito(prestador.id);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cores.primaryContainer,
          child: Text(prestador.iniciais),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(prestador.nome,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (favorito) ...[
              const SizedBox(width: 4),
              const Icon(Icons.favorite, size: 16, color: Colors.red, semanticLabel: 'Favorito'),
            ],
          ],
        ),
        subtitle: Text('${categoria.nome} • ${prestador.bairro}\n${prestador.faixaPreco}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            NotaResumo(prestador: prestador),
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
