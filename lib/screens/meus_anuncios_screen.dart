import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/prestador.dart';
import '../widgets/nota_estrelas.dart';
import 'cadastro_screen.dart';
import 'detalhe_screen.dart';

/// Anúncios do usuário logado: editar, pausar (disponível/ocupado) e remover.
class MeusAnunciosScreen extends StatefulWidget {
  const MeusAnunciosScreen({super.key});

  @override
  State<MeusAnunciosScreen> createState() => _MeusAnunciosScreenState();
}

class _MeusAnunciosScreenState extends State<MeusAnunciosScreen> {
  final _repo = Repositorio.instancia;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_atualizar);
  }

  @override
  void dispose() {
    _repo.removeListener(_atualizar);
    super.dispose();
  }

  void _atualizar() => setState(() {});

  void _aviso(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  void _editar(Prestador p) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => CadastroScreen(editando: p)));

  Future<void> _remover(Prestador p) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover anúncio?'),
        content: Text('O anúncio de "${p.nome}" deixará de aparecer para os clientes. '
            'Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _repo.remover(p.id);
      if (mounted) _aviso('Anúncio removido.');
    } catch (_) {
      if (mounted) _aviso('Não foi possível remover o anúncio.');
    }
  }

  Future<void> _alternarDisponivel(Prestador p, bool valor) async {
    try {
      await _repo.definirDisponivel(p, valor);
    } catch (_) {
      if (mounted) _aviso('Não foi possível atualizar a disponibilidade.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final anuncios = _repo.meusAnuncios;
    return Scaffold(
      appBar: AppBar(title: const Text('Meus anúncios')),
      body: anuncios.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Você ainda não publicou nenhum serviço.\n'
                    'Use "Oferecer serviço" na tela inicial.',
                    textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: anuncios.length,
              itemBuilder: (context, i) {
                final p = anuncios[i];
                final categoria = _repo.categoriaPorId(p.categoriaId);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(categoria.icone),
                        title: Text(p.nome),
                        subtitle: Text('${categoria.nome} • ${p.bairro}'),
                        trailing: NotaResumo(prestador: p),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => DetalheScreen(prestadorId: p.id))),
                      ),
                      SwitchListTile(
                        dense: true,
                        title: Text(p.disponivel ? 'Disponível' : 'Ocupado (pausado)'),
                        value: p.disponivel,
                        onChanged: (v) => _alternarDisponivel(p, v),
                      ),
                      OverflowBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _remover(p),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remover'),
                          ),
                          TextButton.icon(
                            onPressed: () => _editar(p),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
