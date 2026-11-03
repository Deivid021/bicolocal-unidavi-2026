import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/prestador.dart';

/// Repositório em memória usado nesta primeira etapa (protótipo).
/// Na Etapa 2 será substituído por persistência real (Firebase/API).
class Repositorio extends ChangeNotifier {
  Repositorio._();
  static final Repositorio instancia = Repositorio._();

  final List<Categoria> categorias = const [
    Categoria(id: 'eletrica', nome: 'Elétrica', icone: Icons.electrical_services),
    Categoria(id: 'hidraulica', nome: 'Hidráulica', icone: Icons.plumbing),
    Categoria(id: 'limpeza', nome: 'Limpeza', icone: Icons.cleaning_services),
    Categoria(id: 'jardinagem', nome: 'Jardinagem', icone: Icons.yard),
    Categoria(id: 'pintura', nome: 'Pintura', icone: Icons.format_paint),
    Categoria(id: 'reformas', nome: 'Reformas', icone: Icons.handyman),
    Categoria(id: 'aulas', nome: 'Aulas', icone: Icons.school),
    Categoria(id: 'fretes', nome: 'Fretes', icone: Icons.local_shipping),
  ];

  final List<String> bairros = const [
    'Centro', 'Canta Galo', 'Budag', 'Santana', 'Laranjeiras',
    'Barragem', 'Navegantes', 'Bela Aliança', 'Jardim América',
  ];

  final List<Prestador> _prestadores = [
    const Prestador(
      id: '1', nome: 'João Pereira', categoriaId: 'eletrica',
      descricao: 'Eletricista com 10 anos de experiência. Instalações residenciais, troca de disjuntores, chuveiros e tomadas.',
      bairro: 'Canta Galo', telefone: '5547999990001',
      avaliacao: 4.8, totalAvaliacoes: 32, faixaPreco: 'R\$ 80 – 150/visita'),
    const Prestador(
      id: '2', nome: 'Maria Souza', categoriaId: 'limpeza',
      descricao: 'Diarista. Limpeza residencial e pós-obra. Atendo Centro e bairros próximos.',
      bairro: 'Centro', telefone: '5547999990002',
      avaliacao: 4.9, totalAvaliacoes: 51, faixaPreco: 'R\$ 180/diária'),
    const Prestador(
      id: '3', nome: 'Carlos Schmitt', categoriaId: 'hidraulica',
      descricao: 'Encanador. Vazamentos, desentupimentos, instalação de caixa d\'água.',
      bairro: 'Budag', telefone: '5547999990003',
      avaliacao: 4.6, totalAvaliacoes: 18, faixaPreco: 'R\$ 70 – 200/serviço'),
    const Prestador(
      id: '4', nome: 'Ana Krause', categoriaId: 'aulas',
      descricao: 'Aulas particulares de matemática e física para ensino fundamental e médio.',
      bairro: 'Santana', telefone: '5547999990004',
      avaliacao: 5.0, totalAvaliacoes: 12, faixaPreco: 'R\$ 60/hora'),
    const Prestador(
      id: '5', nome: 'Pedro Hoffmann', categoriaId: 'jardinagem',
      descricao: 'Corte de grama, poda de árvores e limpeza de terrenos.',
      bairro: 'Laranjeiras', telefone: '5547999990005',
      avaliacao: 4.5, totalAvaliacoes: 22, faixaPreco: 'R\$ 100 – 250/serviço',
      disponivel: false),
    const Prestador(
      id: '6', nome: 'Lucas Ramos', categoriaId: 'fretes',
      descricao: 'Fretes e pequenas mudanças com caminhonete. Rio do Sul e região.',
      bairro: 'Navegantes', telefone: '5547999990006',
      avaliacao: 4.7, totalAvaliacoes: 27, faixaPreco: 'A combinar'),
    const Prestador(
      id: '7', nome: 'Roberto Lima', categoriaId: 'pintura',
      descricao: 'Pintura residencial interna e externa, textura e grafiato.',
      bairro: 'Barragem', telefone: '5547999990007',
      avaliacao: 4.4, totalAvaliacoes: 9, faixaPreco: 'R\$ 25/m²'),
  ];

  List<Prestador> get prestadores => List.unmodifiable(_prestadores);

  Categoria categoriaPorId(String id) =>
      categorias.firstWhere((c) => c.id == id, orElse: () => categorias.first);

  List<Prestador> buscar({String texto = '', String? categoriaId}) {
    final termo = texto.trim().toLowerCase();
    return _prestadores.where((p) {
      final okCategoria = categoriaId == null || p.categoriaId == categoriaId;
      final okTexto = termo.isEmpty ||
          p.nome.toLowerCase().contains(termo) ||
          p.descricao.toLowerCase().contains(termo) ||
          p.bairro.toLowerCase().contains(termo) ||
          categoriaPorId(p.categoriaId).nome.toLowerCase().contains(termo);
      return okCategoria && okTexto;
    }).toList()
      ..sort((a, b) => b.avaliacao.compareTo(a.avaliacao));
  }

  void adicionar(Prestador p) {
    _prestadores.add(p);
    notifyListeners();
  }

  String proximoId() => (_prestadores.length + 1).toString();
}
