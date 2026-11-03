import 'package:flutter/material.dart';

import '../data/repositorio.dart';
import '../models/prestador.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = Repositorio.instancia;

  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _descricao = TextEditingController();
  final _preco = TextEditingController();
  String? _categoriaId;
  String? _bairro;

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

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final digitos = _telefone.text.replaceAll(RegExp(r'\D'), '');
    _repo.adicionar(Prestador(
      id: _repo.proximoId(),
      nome: _nome.text.trim(),
      categoriaId: _categoriaId!,
      descricao: _descricao.text.trim(),
      bairro: _bairro!,
      telefone: '55$digitos',
      avaliacao: 0,
      totalAvaliacoes: 0,
      faixaPreco: _preco.text.trim().isEmpty ? 'A combinar' : _preco.text.trim(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço cadastrado com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oferecer serviço')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nome,
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
              value: _categoriaId,
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
              value: _bairro,
              decoration: const InputDecoration(
                labelText: 'Bairro de atendimento', border: OutlineInputBorder()),
              items: [
                for (final b in _repo.bairros)
                  DropdownMenuItem(value: b, child: Text(b)),
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
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Publicar serviço'),
            ),
          ],
        ),
      ),
    );
  }
}
