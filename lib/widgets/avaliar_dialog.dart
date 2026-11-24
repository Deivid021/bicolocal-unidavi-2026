import 'package:flutter/material.dart';

import 'nota_estrelas.dart';

/// Diálogo para o cliente dar nota (1–5) e um comentário opcional.
/// Devolve null se o usuário cancelar.
Future<({int nota, String comentario})?> mostrarAvaliarDialog(
  BuildContext context, {
  required String nomePrestador,
  int notaInicial = 0,
  String comentarioInicial = '',
}) {
  return showDialog(
    context: context,
    builder: (_) => _AvaliarDialog(
      nomePrestador: nomePrestador,
      notaInicial: notaInicial,
      comentarioInicial: comentarioInicial,
    ),
  );
}

class _AvaliarDialog extends StatefulWidget {
  final String nomePrestador;
  final int notaInicial;
  final String comentarioInicial;

  const _AvaliarDialog({
    required this.nomePrestador,
    required this.notaInicial,
    required this.comentarioInicial,
  });

  @override
  State<_AvaliarDialog> createState() => _AvaliarDialogState();
}

class _AvaliarDialogState extends State<_AvaliarDialog> {
  late int _nota = widget.notaInicial;
  late final _comentario = TextEditingController(text: widget.comentarioInicial);

  static const _rotulos = ['', 'Ruim', 'Regular', 'Bom', 'Muito bom', 'Excelente'];

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Avaliar ${widget.nomePrestador}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Estrelas(nota: _nota, tamanho: 36, aoEscolher: (n) => setState(() => _nota = n)),
            SizedBox(height: 20, child: Text(_rotulos[_nota])),
            const SizedBox(height: 12),
            TextField(
              controller: _comentario,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Comentário (opcional)',
                hintText: 'Como foi o serviço?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _nota == 0
              ? null
              : () => Navigator.pop(context, (nota: _nota, comentario: _comentario.text)),
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
