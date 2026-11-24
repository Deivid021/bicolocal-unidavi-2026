import 'package:flutter/material.dart';

import '../models/prestador.dart';

/// "★ 4.8" ou, para quem ainda não foi avaliado, a etiqueta "Novo".
class NotaResumo extends StatelessWidget {
  final Prestador prestador;

  const NotaResumo({super.key, required this.prestador});

  @override
  Widget build(BuildContext context) {
    if (prestador.semAvaliacoes) {
      final cores = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: cores.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Novo',
            style: TextStyle(fontSize: 12, color: cores.onSecondaryContainer)),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star, size: 16, color: Colors.amber),
      Text(prestador.avaliacao.toStringAsFixed(1)),
    ]);
  }
}

/// Fileira de 5 estrelas. Se [aoEscolher] for informado, vira um seletor de nota.
class Estrelas extends StatelessWidget {
  final int nota;
  final double tamanho;
  final ValueChanged<int>? aoEscolher;

  const Estrelas({super.key, required this.nota, this.tamanho = 16, this.aoEscolher});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          aoEscolher == null
              ? Icon(i <= nota ? Icons.star : Icons.star_border,
                  size: tamanho, color: Colors.amber)
              : IconButton(
                  tooltip: '$i estrela${i > 1 ? 's' : ''}',
                  iconSize: tamanho,
                  onPressed: () => aoEscolher!(i),
                  icon: Icon(i <= nota ? Icons.star : Icons.star_border,
                      color: Colors.amber),
                ),
      ],
    );
  }
}
