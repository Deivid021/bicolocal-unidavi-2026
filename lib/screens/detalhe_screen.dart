import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/repositorio.dart';
import '../models/prestador.dart';

class DetalheScreen extends StatelessWidget {
  final Prestador prestador;

  const DetalheScreen({super.key, required this.prestador});

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final mensagem = Uri.encodeComponent(
        'Olá ${prestador.nome}, vi seu perfil no BicoLocal e gostaria de um orçamento.');
    final uri = Uri.parse('https://wa.me/${prestador.telefone}?text=$mensagem');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  Future<void> _ligar() async {
    await launchUrl(Uri.parse('tel:+${prestador.telefone}'));
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    final categoria = Repositorio.instancia.categoriaPorId(prestador.categoriaId);

    return Scaffold(
      appBar: AppBar(title: const Text('Prestador')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: cores.primaryContainer,
              child: Text(prestador.iniciais, style: texto.headlineMedium),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(prestador.nome, style: texto.headlineSmall)),
          const SizedBox(height: 4),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(categoria.icone, size: 18, color: cores.primary),
                const SizedBox(width: 4),
                Text('${categoria.nome} • ${prestador.bairro}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(' ${prestador.avaliacao.toStringAsFixed(1)} '
                    '(${prestador.totalAvaliacoes} avaliações)'),
              ],
            ),
          ),
          const Divider(height: 40),
          Text('Sobre o serviço', style: texto.titleMedium),
          const SizedBox(height: 8),
          Text(prestador.descricao),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Faixa de preço'),
            subtitle: Text(prestador.faixaPreco),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              prestador.disponivel ? Icons.check_circle : Icons.schedule,
              color: prestador.disponivel ? Colors.green : Colors.grey,
            ),
            title: const Text('Disponibilidade'),
            subtitle: Text(prestador.disponivel
                ? 'Disponível para novos serviços'
                : 'Agenda cheia no momento'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _abrirWhatsApp(context),
            icon: const Icon(Icons.chat),
            label: const Text('Pedir orçamento pelo WhatsApp'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _ligar,
            icon: const Icon(Icons.call),
            label: const Text('Ligar'),
          ),
        ],
      ),
    );
  }
}
