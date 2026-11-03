import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../widgets/prestador_card.dart';
import 'cadastro_screen.dart';
import 'detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = Repositorio.instancia;
  final _buscaController = TextEditingController();
  String? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_atualizar);
  }

  @override
  void dispose() {
    _repo.removeListener(_atualizar);
    _buscaController.dispose();
    super.dispose();
  }

  void _atualizar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final resultados = _repo.buscar(
      texto: _buscaController.text,
      categoriaId: _categoriaSelecionada,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('BicoLocal'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Sobre',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'BicoLocal',
              applicationVersion: '0.1.0',
              children: const [
                Text('Conecta prestadores de serviços autônomos a clientes de Rio do Sul e região. '
                    'Projeto de Extensão – Unidavi.'),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _buscaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar serviço, nome ou bairro',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: _categoriaSelecionada == null,
                    onSelected: (_) => setState(() => _categoriaSelecionada = null),
                  ),
                ),
                for (final c in _repo.categorias)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      avatar: Icon(c.icone, size: 18),
                      label: Text(c.nome),
                      selected: _categoriaSelecionada == c.id,
                      onSelected: (_) => setState(() => _categoriaSelecionada = c.id),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: resultados.isEmpty
                ? const Center(child: Text('Nenhum prestador encontrado.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: resultados.length,
                    itemBuilder: (context, i) => PrestadorCard(
                      prestador: resultados[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetalheScreen(prestador: resultados[i]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CadastroScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Oferecer serviço'),
      ),
    );
  }
}
