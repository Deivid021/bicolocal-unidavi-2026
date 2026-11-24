import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/repositorio.dart';
import '../models/avaliacao.dart';
import '../models/prestador.dart';
import '../widgets/avaliar_dialog.dart';
import '../widgets/nota_estrelas.dart';
import 'cadastro_screen.dart';
import 'login_screen.dart';

class DetalheScreen extends StatefulWidget {
  final String prestadorId;

  const DetalheScreen({super.key, required this.prestadorId});

  @override
  State<DetalheScreen> createState() => _DetalheScreenState();
}

class _DetalheScreenState extends State<DetalheScreen> {
  final _repo = Repositorio.instancia;
  late final Stream<List<Avaliacao>> _avaliacoes = _repo.avaliacoes(widget.prestadorId);
  List<Avaliacao> _ultimasAvaliacoes = const [];

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

  Future<void> _abrirWhatsApp(Prestador p) async {
    final mensagem = Uri.encodeComponent(
        'Olá ${p.nome}, vi seu perfil no BicoLocal e gostaria de um orçamento.');
    final uri = Uri.parse('https://wa.me/${p.telefone}?text=$mensagem');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _aviso('Não foi possível abrir o WhatsApp.');
  }

  Future<void> _ligar(Prestador p) async {
    final ok = await launchUrl(Uri.parse('tel:+${p.telefone}'));
    if (!ok && mounted) _aviso('Não foi possível iniciar a ligação.');
  }

  Future<void> _alternarFavorito(Prestador p) async {
    if (!await exigirLogin(context, motivo: 'Entre para salvar seus favoritos.')) return;
    try {
      await _repo.alternarFavorito(p.id);
    } catch (_) {
      if (mounted) _aviso('Não foi possível atualizar os favoritos.');
    }
  }

  Future<void> _avaliar(Prestador p) async {
    if (!await exigirLogin(context, motivo: 'Entre para avaliar este prestador.')) return;
    if (!mounted) return;
    if (_repo.ehDono(p)) {
      _aviso('Você não pode avaliar o próprio anúncio.');
      return;
    }
    final uid = _repo.usuario!.uid;
    final minha = _ultimasAvaliacoes.where((a) => a.autorUid == uid).firstOrNull;
    final resultado = await mostrarAvaliarDialog(
      context,
      nomePrestador: p.nome,
      notaInicial: minha?.nota ?? 0,
      comentarioInicial: minha?.comentario ?? '',
    );
    if (resultado == null) return;
    try {
      await _repo.avaliar(p.id, resultado.nota, resultado.comentario);
      if (mounted) _aviso('Obrigado pela avaliação!');
    } catch (_) {
      if (mounted) _aviso('Não foi possível enviar a avaliação.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _repo.prestadorPorId(widget.prestadorId);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prestador')),
        body: const Center(child: Text('Este anúncio não está mais disponível.')),
      );
    }

    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final categoria = _repo.categoriaPorId(p.categoriaId);
    final favorito = _repo.ehFavorito(p.id);
    final dono = _repo.ehDono(p);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestador'),
        actions: [
          if (dono)
            IconButton(
              tooltip: 'Editar anúncio',
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CadastroScreen(editando: p)),
              ),
            ),
          IconButton(
            tooltip: favorito ? 'Remover dos favoritos' : 'Salvar nos favoritos',
            icon: Icon(favorito ? Icons.favorite : Icons.favorite_border,
                color: favorito ? Colors.red : null),
            onPressed: () => _alternarFavorito(p),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: cores.primaryContainer,
              child: Text(p.iniciais, style: texto.headlineMedium),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(p.nome, style: texto.headlineSmall)),
          const SizedBox(height: 4),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoria.icone, size: 18, color: cores.primary),
                const SizedBox(width: 4),
                Text('${categoria.nome} • ${p.bairro}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: p.semAvaliacoes
                ? const Text('Ainda sem avaliações')
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(' ${p.avaliacao.toStringAsFixed(1)} '
                          '(${p.totalAvaliacoes} '
                          '${p.totalAvaliacoes == 1 ? 'avaliação' : 'avaliações'})'),
                    ],
                  ),
          ),
          const Divider(height: 40),
          Text('Sobre o serviço', style: texto.titleMedium),
          const SizedBox(height: 8),
          Text(p.descricao),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Faixa de preço'),
            subtitle: Text(p.faixaPreco),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              p.disponivel ? Icons.check_circle : Icons.schedule,
              color: p.disponivel ? Colors.green : Colors.grey,
            ),
            title: const Text('Disponibilidade'),
            subtitle: Text(
                p.disponivel ? 'Disponível para novos serviços' : 'Agenda cheia no momento'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _abrirWhatsApp(p),
            icon: const Icon(Icons.chat),
            label: const Text('Pedir orçamento pelo WhatsApp'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _ligar(p),
            icon: const Icon(Icons.call),
            label: const Text('Ligar'),
          ),
          const Divider(height: 40),
          Row(
            children: [
              Expanded(child: Text('Avaliações', style: texto.titleMedium)),
              if (!dono)
                TextButton.icon(
                  onPressed: () => _avaliar(p),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Avaliar'),
                ),
            ],
          ),
          StreamBuilder<List<Avaliacao>>(
            stream: _avaliacoes,
            builder: (context, snap) {
              if (snap.hasError) {
                return const Text('Não foi possível carregar as avaliações.');
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              _ultimasAvaliacoes = snap.data!;
              if (_ultimasAvaliacoes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    dono
                        ? 'Seu anúncio ainda não recebeu comentários.'
                        : 'Seja o primeiro a avaliar depois de contratar.',
                    style: TextStyle(color: cores.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: [
                  for (final a in _ultimasAvaliacoes) _ItemAvaliacao(avaliacao: a),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ItemAvaliacao extends StatelessWidget {
  final Avaliacao avaliacao;

  const _ItemAvaliacao({required this.avaliacao});

  @override
  Widget build(BuildContext context) {
    final d = avaliacao.data;
    final data = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Flexible(child: Text(avaliacao.autorNome, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Estrelas(nota: avaliacao.nota, tamanho: 14),
        ],
      ),
      subtitle: Text(
        avaliacao.comentario.isEmpty ? data : '${avaliacao.comentario}\n$data',
      ),
    );
  }
}
