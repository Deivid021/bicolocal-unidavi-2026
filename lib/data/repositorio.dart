import 'dart:async';

import 'package:flutter/material.dart';

import '../models/avaliacao.dart';
import '../models/categoria.dart';
import '../models/prestador.dart';
import '../models/usuario.dart';
import 'auth.dart';
import 'fonte_dados.dart';

/// Ponto único de acesso aos dados para as telas.
/// Mantém em cache a lista de prestadores, o usuário logado e seus favoritos,
/// e avisa as telas (ChangeNotifier) quando algo muda na fonte de dados.
class Repositorio extends ChangeNotifier {
  Repositorio({required this.fonte, required this.auth, this.modoDemonstracao = false}) {
    _subPrestadores = fonte.prestadores().listen((lista) {
      _prestadores = lista;
      carregando = false;
      notifyListeners();
    }, onError: (Object e) {
      erro = 'Não foi possível carregar os prestadores.';
      carregando = false;
      notifyListeners();
    });
    _subAuth = auth.mudancas().listen(_aoMudarUsuario);
  }

  /// Instância usada pelo app, criada em main.dart.
  static late Repositorio instancia;

  final FonteDados fonte;
  final ServicoAuth auth;

  /// true quando o Firebase não foi configurado e os dados ficam só em memória.
  final bool modoDemonstracao;

  List<Prestador> _prestadores = [];
  Set<String> _favoritos = {};
  Usuario? _usuario;
  bool carregando = true;
  String? erro;

  late final StreamSubscription<List<Prestador>> _subPrestadores;
  late final StreamSubscription<Usuario?> _subAuth;
  StreamSubscription<Set<String>>? _subFavoritos;

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

  // ---------- Usuário ----------

  Usuario? get usuario => _usuario;
  bool get logado => _usuario != null;

  void _aoMudarUsuario(Usuario? u) {
    final trocou = u?.uid != _usuario?.uid;
    _usuario = u;
    if (trocou) {
      _subFavoritos?.cancel();
      _favoritos = {};
      if (u != null) {
        _subFavoritos = fonte.favoritos(u.uid).listen((f) {
          _favoritos = f;
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }

  Usuario _exigirUsuario() {
    final u = _usuario;
    if (u == null) throw const ErroAuth('Entre na sua conta para continuar.');
    return u;
  }

  // ---------- Prestadores ----------

  List<Prestador> get prestadores => List.unmodifiable(_prestadores);

  Prestador? prestadorPorId(String id) {
    for (final p in _prestadores) {
      if (p.id == id) return p;
    }
    return null;
  }

  Categoria categoriaPorId(String id) =>
      categorias.firstWhere((c) => c.id == id, orElse: () => categorias.first);

  /// Busca por nome, descrição, bairro ou categoria, com filtro opcional por
  /// categoria e por favoritos. Ordena por avaliação (melhores primeiro);
  /// anúncios sem avaliação vão para o fim.
  List<Prestador> buscar({
    String texto = '',
    String? categoriaId,
    bool somenteFavoritos = false,
  }) {
    final termo = texto.trim().toLowerCase();
    return _prestadores.where((p) {
      final okCategoria = categoriaId == null || p.categoriaId == categoriaId;
      final okFavorito = !somenteFavoritos || _favoritos.contains(p.id);
      final okTexto = termo.isEmpty ||
          p.nome.toLowerCase().contains(termo) ||
          p.descricao.toLowerCase().contains(termo) ||
          p.bairro.toLowerCase().contains(termo) ||
          categoriaPorId(p.categoriaId).nome.toLowerCase().contains(termo);
      return okCategoria && okFavorito && okTexto;
    }).toList()
      ..sort((a, b) {
        final porNota = b.avaliacao.compareTo(a.avaliacao);
        return porNota != 0 ? porNota : a.nome.compareTo(b.nome);
      });
  }

  /// Anúncios publicados pelo usuário logado.
  List<Prestador> get meusAnuncios {
    final uid = _usuario?.uid;
    if (uid == null) return const [];
    return _prestadores.where((p) => p.donoUid == uid).toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  bool ehDono(Prestador p) => _usuario != null && p.donoUid == _usuario!.uid;

  Future<String> adicionar(Prestador p) {
    final u = _exigirUsuario();
    return fonte.adicionar(p.copyWith(donoUid: u.uid));
  }

  Future<void> atualizar(Prestador p) {
    _garantirDono(p.id);
    return fonte.atualizar(p);
  }

  Future<void> definirDisponivel(Prestador p, bool disponivel) =>
      atualizar(p.copyWith(disponivel: disponivel));

  Future<void> remover(String prestadorId) {
    _garantirDono(prestadorId);
    return fonte.remover(prestadorId);
  }

  void _garantirDono(String prestadorId) {
    final u = _exigirUsuario();
    final p = prestadorPorId(prestadorId);
    if (p == null || p.donoUid != u.uid) {
      throw StateError('Apenas o dono pode alterar este anúncio.');
    }
  }

  Future<void> popularExemplos() => fonte.popularExemplos(_exigirUsuario().uid);

  // ---------- Avaliações ----------

  Stream<List<Avaliacao>> avaliacoes(String prestadorId) => fonte.avaliacoes(prestadorId);

  Future<void> avaliar(String prestadorId, int nota, String comentario) {
    final u = _exigirUsuario();
    if (nota < 1 || nota > 5) throw ArgumentError('A nota deve ser de 1 a 5.');
    final p = prestadorPorId(prestadorId);
    if (p != null && p.donoUid == u.uid) {
      throw StateError('Você não pode avaliar o próprio anúncio.');
    }
    return fonte.avaliar(
      prestadorId,
      Avaliacao(
        autorUid: u.uid,
        autorNome: u.nome,
        nota: nota,
        comentario: comentario.trim(),
        data: DateTime.now(),
      ),
    );
  }

  // ---------- Favoritos ----------

  Set<String> get favoritos => Set.unmodifiable(_favoritos);

  bool ehFavorito(String prestadorId) => _favoritos.contains(prestadorId);

  Future<void> alternarFavorito(String prestadorId) {
    final u = _exigirUsuario();
    final marcar = !_favoritos.contains(prestadorId);
    // Atualização otimista: o ícone muda na hora; a fonte confirma em seguida.
    marcar ? _favoritos.add(prestadorId) : _favoritos.remove(prestadorId);
    notifyListeners();
    return fonte.definirFavorito(u.uid, prestadorId, marcar);
  }

  @override
  void dispose() {
    _subPrestadores.cancel();
    _subAuth.cancel();
    _subFavoritos?.cancel();
    super.dispose();
  }
}
