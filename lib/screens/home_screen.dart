import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../widgets/prestador_card.dart';
import 'cadastro_screen.dart';
import 'detalhe_screen.dart';
import 'login_screen.dart';
import 'meus_anuncios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = Repositorio.instancia;
  final _buscaController = TextEditingController();
  String? _categoriaSelecionada;
  bool _somenteFavoritos = false;

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

  Future<void> _oferecerServico() async {
    if (!await exigirLogin(context, motivo: 'Entre para publicar seu serviço.')) return;
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CadastroScreen()));
  }

  Future<void> _alternarFiltroFavoritos() async {
    if (!_somenteFavoritos &&
        !await exigirLogin(context, motivo: 'Entre para ver seus favoritos.')) {
      return;
    }
    setState(() => _somenteFavoritos = !_somenteFavoritos);
  }

  void _menuConta(String opcao) {
    switch (opcao) {
      case 'anuncios':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MeusAnunciosScreen()));
      case 'sair':
        _repo.auth.sair();
        setState(() => _somenteFavoritos = false);
      case 'sobre':
        showAboutDialog(
          context: context,
          applicationName: 'BicoLocal',
          applicationVersion: '1.0.0',
          children: const [
            Text('Conecta prestadores de serviços autônomos a clientes de Rio do Sul e região. '
                'Projeto de Extensão – Unidavi.'),
          ],
        );
    }
  }

  Widget _acaoConta() {
    final usuario = _repo.usuario;
    if (usuario == null) {
      return TextButton.icon(
        onPressed: () => exigirLogin(context),
        icon: const Icon(Icons.login),
        label: const Text('Entrar'),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Minha conta',
      icon: CircleAvatar(
        radius: 16,
        child: Text(usuario.nome.isEmpty ? '?' : usuario.nome[0].toUpperCase()),
      ),
      onSelected: _menuConta,
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Text('Olá, ${usuario.nome}'),
        ),
        const PopupMenuItem(
          value: 'anuncios',
          child: ListTile(leading: Icon(Icons.storefront), title: Text('Meus anúncios')),
        ),
        const PopupMenuItem(
          value: 'sobre',
          child: ListTile(leading: Icon(Icons.info_outline), title: Text('Sobre')),
        ),
        const PopupMenuItem(
          value: 'sair',
          child: ListTile(leading: Icon(Icons.logout), title: Text('Sair')),
        ),
      ],
    );
  }

  Widget _corpoLista() {
    if (_repo.carregando) return const Center(child: CircularProgressIndicator());
    if (_repo.erro != null) return Center(child: Text(_repo.erro!));

    final resultados = _repo.buscar(
      texto: _buscaController.text,
      categoriaId: _categoriaSelecionada,
      somenteFavoritos: _somenteFavoritos,
    );

    if (resultados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _somenteFavoritos
                    ? 'Você ainda não tem favoritos.\nToque no coração de um prestador para salvar.'
                    : 'Nenhum prestador encontrado.',
                textAlign: TextAlign.center,
              ),
              // Banco recém-criado: em modo debug, oferece carregar os exemplos.
              if (kDebugMode && _repo.prestadores.isEmpty && _repo.logado) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _repo.popularExemplos,
                  child: const Text('Carregar dados de exemplo'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: resultados.length,
      itemBuilder: (context, i) => PrestadorCard(
        prestador: resultados[i],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetalheScreen(prestadorId: resultados[i].id)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BicoLocal'),
        centerTitle: false,
        actions: [_acaoConta(), const SizedBox(width: 8)],
      ),
      body: Column(
        children: [
          if (_repo.modoDemonstracao)
            Container(
              width: double.infinity,
              color: cores.tertiaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Modo demonstração: dados de exemplo, salvos só neste aparelho.',
                style: TextStyle(fontSize: 12, color: cores.onTertiaryContainer),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _buscaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar serviço, nome ou bairro',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_buscaController.clear),
                      ),
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
                  child: FilterChip(
                    avatar: Icon(
                      _somenteFavoritos ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: Colors.red,
                    ),
                    showCheckmark: false,
                    label: const Text('Favoritos'),
                    selected: _somenteFavoritos,
                    onSelected: (_) => _alternarFiltroFavoritos(),
                  ),
                ),
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
          Expanded(child: _corpoLista()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _oferecerServico,
        icon: const Icon(Icons.add),
        label: const Text('Oferecer serviço'),
      ),
    );
  }
}
