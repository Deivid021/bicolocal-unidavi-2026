import 'dart:async';

import '../models/avaliacao.dart';
import '../models/prestador.dart';
import 'dados_exemplo.dart';
import 'fonte_dados.dart';

/// Implementação em memória da [FonteDados]. Usada nos testes automatizados e
/// no modo demonstração (quando o Firebase não está configurado).
class FonteMemoria implements FonteDados {
  FonteMemoria({bool comExemplos = true}) {
    if (comExemplos) {
      for (final p in prestadoresExemplo) {
        _prestadores[p.id] = p;
      }
    }
  }

  final Map<String, Prestador> _prestadores = {};
  final Map<String, Map<String, Avaliacao>> _avaliacoes = {};
  final Map<String, Set<String>> _favoritos = {};
  int _seq = 100;

  final _mudouPrestadores = StreamController<void>.broadcast();
  final _mudouAvaliacoes = StreamController<String>.broadcast();
  final _mudouFavoritos = StreamController<String>.broadcast();

  List<Prestador> get _lista => _prestadores.values.toList();

  @override
  Stream<List<Prestador>> prestadores() async* {
    yield _lista;
    yield* _mudouPrestadores.stream.map((_) => _lista);
  }

  @override
  Future<String> adicionar(Prestador p) async {
    final id = 'p${_seq++}';
    _prestadores[id] = p.copyWith(id: id, somaNotas: 0, totalAvaliacoes: 0);
    _mudouPrestadores.add(null);
    return id;
  }

  @override
  Future<void> atualizar(Prestador p) async {
    final atual = _prestadores[p.id];
    if (atual == null) throw StateError('Anúncio não encontrado');
    _prestadores[p.id] =
        p.copyWith(somaNotas: atual.somaNotas, totalAvaliacoes: atual.totalAvaliacoes);
    _mudouPrestadores.add(null);
  }

  @override
  Future<void> remover(String prestadorId) async {
    _prestadores.remove(prestadorId);
    _avaliacoes.remove(prestadorId);
    _mudouPrestadores.add(null);
  }

  List<Avaliacao> _avaliacoesDe(String id) =>
      (_avaliacoes[id]?.values.toList() ?? [])..sort((a, b) => b.data.compareTo(a.data));

  @override
  Stream<List<Avaliacao>> avaliacoes(String prestadorId) async* {
    yield _avaliacoesDe(prestadorId);
    yield* _mudouAvaliacoes.stream
        .where((id) => id == prestadorId)
        .map(_avaliacoesDe);
  }

  @override
  Future<void> avaliar(String prestadorId, Avaliacao a) async {
    final p = _prestadores[prestadorId];
    if (p == null) throw StateError('Anúncio não encontrado');
    final porAutor = _avaliacoes.putIfAbsent(prestadorId, () => {});
    final anterior = porAutor[a.autorUid];
    porAutor[a.autorUid] = a;
    _prestadores[prestadorId] = p.copyWith(
      somaNotas: p.somaNotas - (anterior?.nota ?? 0) + a.nota,
      totalAvaliacoes: p.totalAvaliacoes + (anterior == null ? 1 : 0),
    );
    _mudouAvaliacoes.add(prestadorId);
    _mudouPrestadores.add(null);
  }

  @override
  Stream<Set<String>> favoritos(String uid) async* {
    yield {...?_favoritos[uid]};
    yield* _mudouFavoritos.stream.where((u) => u == uid).map((_) => {...?_favoritos[uid]});
  }

  @override
  Future<void> definirFavorito(String uid, String prestadorId, bool favorito) async {
    final set = _favoritos.putIfAbsent(uid, () => {});
    favorito ? set.add(prestadorId) : set.remove(prestadorId);
    _mudouFavoritos.add(uid);
  }

  @override
  Future<void> popularExemplos(String donoUid) async {
    for (final p in prestadoresExemplo) {
      final id = 'p${_seq++}';
      _prestadores[id] = p.copyWith(id: id, donoUid: donoUid);
    }
    _mudouPrestadores.add(null);
  }
}
