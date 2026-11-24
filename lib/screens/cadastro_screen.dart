import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/prestador.dart';

/// Cadastro de um novo serviço ou edição de um anúncio existente ([editando]).
class CadastroScreen extends StatefulWidget {
  final Prestador? editando;

  const CadastroScreen({super.key, this.editando});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = Repositorio.instancia;

  late final _nome = TextEditingController(
      text: widget.editando?.nome ?? _repo.usuario?.nome ?? '');
  late final _telefone = TextEditingController(text: widget.editando?.telefoneLocal);
  late final _descricao = TextEditingController(text: widget.editando?.descricao);
  late final _preco = TextEditingController(text: widget.editando?.faixaPreco);
  late String? _categoriaId = widget.editando?.categoriaId;
  late String? _bairro = widget.editando?.bairro;
  late bool _disponivel = widget.editando?.disponivel ?? true;
  bool _salvando = false;

  bool get _editando => widget.editando != null;

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _descricao.dispose();
    _preco.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _validarTelefone(String? v) {
    final digitos = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitos.length < 10 || digitos.length > 11) {
      return 'Informe DDD + número (ex.: 47 99999-0000)';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final digitos = _telefone.text.replaceAll(RegExp(r'\D'), '');
    final preco = _preco.text.trim();
    final dados = Prestador(
      id: widget.editando?.id ?? '',
      nome: _nome.text.trim(),
      categoriaId: _categoriaId!,
      descricao: _descricao.text.trim(),
      bairro: _bairro!,
      telefone: '55$digitos',
      faixaPreco: preco.isEmpty ? 'A combinar' : preco,
      disponivel: _disponivel,
      donoUid: widget.editando?.donoUid ?? _repo.usuario?.uid ?? '',
    );

    setState(() => _salvando = true);
    final mensageiro = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    try {
      if (_editando) {
        await _repo.atualizar(dados);
      } else {
        await _repo.adicionar(dados);
      }
      mensageiro.showSnackBar(SnackBar(
        content: Text(_editando ? 'Anúncio atualizado!' : 'Serviço publicado com sucesso!'),
      ));
      navegador.pop();
    } catch (_) {
      mensageiro.showSnackBar(const SnackBar(
        content: Text('Não foi possível salvar. Verifique sua conexão e tente de novo.'),
      ));
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar anúncio' : 'Oferecer serviço')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Nome completo', border: OutlineInputBorder()),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'WhatsApp (com DDD)', border: OutlineInputBorder()),
              validator: _validarTelefone,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoriaId,
              decoration: const InputDecoration(
                  labelText: 'Categoria', border: OutlineInputBorder()),
              items: [
                for (final c in _repo.categorias)
                  DropdownMenuItem(value: c.id, child: Text(c.nome)),
              ],
              onChanged: (v) => setState(() => _categoriaId = v),
              validator: (v) => v == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _bairro,
              decoration: const InputDecoration(
                  labelText: 'Bairro de atendimento', border: OutlineInputBorder()),
              items: [
                for (final b in _repo.bairros) DropdownMenuItem(value: b, child: Text(b)),
              ],
              onChanged: (v) => setState(() => _bairro = v),
              validator: (v) => v == null ? 'Selecione um bairro' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricao,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                  labelText: 'Descreva seu serviço', border: OutlineInputBorder()),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _preco,
              decoration: const InputDecoration(
                  labelText: 'Faixa de preço (opcional)',
                  hintText: 'Ex.: R\$ 80/visita',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Disponível para novos serviços'),
              subtitle: const Text('Desligue quando a agenda estiver cheia'),
              value: _disponivel,
              onChanged: (v) => setState(() => _disponivel = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_editando ? 'Salvar alterações' : 'Publicar serviço'),
            ),
          ],
        ),
      ),
    );
  }
}
