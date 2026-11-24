import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/avaliacao.dart';
import '../models/prestador.dart';
import 'dados_exemplo.dart';
import 'fonte_dados.dart';

/// [FonteDados] sobre o Cloud Firestore.
///
/// Estrutura:
///   prestadores/{id}                      dados do anúncio + somaNotas/totalAvaliacoes
///   prestadores/{id}/avaliacoes/{uid}     uma avaliação por usuário
///   usuarios/{uid}                        { favoritos: [ids] }
class FonteFirestore implements FonteDados {
  FonteFirestore([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _prestadores =>
      _db.collection('prestadores');

  @override
  Stream<List<Prestador>> prestadores() => _prestadores.snapshots().map(
      (snap) => snap.docs.map((d) => Prestador.fromMap(d.id, d.data())).toList());

  @override
  Future<String> adicionar(Prestador p) async {
    final dados = p.copyWith(somaNotas: 0, totalAvaliacoes: 0).toMap()
      ..['criadoEm'] = FieldValue.serverTimestamp();
    final ref = await _prestadores.add(dados);
    return ref.id;
  }

  @override
  Future<void> atualizar(Prestador p) {
    // somaNotas/totalAvaliacoes ficam de fora: só mudam ao avaliar.
    final dados = p.toMap()
      ..remove('somaNotas')
      ..remove('totalAvaliacoes')
      ..['atualizadoEm'] = FieldValue.serverTimestamp();
    return _prestadores.doc(p.id).update(dados);
  }

  @override
  Future<void> remover(String prestadorId) => _prestadores.doc(prestadorId).delete();

  @override
  Stream<List<Avaliacao>> avaliacoes(String prestadorId) => _prestadores
      .doc(prestadorId)
      .collection('avaliacoes')
      .orderBy('data', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Avaliacao.fromMap(d.data())).toList());

  @override
  Future<void> avaliar(String prestadorId, Avaliacao a) {
    final refPrestador = _prestadores.doc(prestadorId);
    final refAvaliacao = refPrestador.collection('avaliacoes').doc(a.autorUid);
    // Transação: lê a nota anterior do autor (se houver) e ajusta a média
    // de forma atômica, mesmo com várias avaliações simultâneas.
    return _db.runTransaction((tx) async {
      final prestador = await tx.get(refPrestador);
      if (!prestador.exists) throw StateError('Anúncio não encontrado');
      final anterior = await tx.get(refAvaliacao);
      final notaAnterior = anterior.exists ? (anterior.data()!['nota'] as num).toInt() : 0;
      tx.set(refAvaliacao, a.toMap());
      tx.update(refPrestador, {
        'somaNotas': FieldValue.increment(a.nota - notaAnterior),
        'totalAvaliacoes': FieldValue.increment(anterior.exists ? 0 : 1),
      });
    });
  }

  @override
  Stream<Set<String>> favoritos(String uid) =>
      _db.collection('usuarios').doc(uid).snapshots().map((d) {
        final lista = (d.data()?['favoritos'] as List?) ?? const [];
        return lista.cast<String>().toSet();
      });

  @override
  Future<void> definirFavorito(String uid, String prestadorId, bool favorito) {
    return _db.collection('usuarios').doc(uid).set({
      'favoritos': favorito
          ? FieldValue.arrayUnion([prestadorId])
          : FieldValue.arrayRemove([prestadorId]),
    }, SetOptions(merge: true));
  }

  /// As regras exigem donoUid == uid, por isso os exemplos ficam em nome do usuário logado.
  @override
  Future<void> popularExemplos(String donoUid) async {
    final lote = _db.batch();
    for (final p in prestadoresExemplo) {
      lote.set(_prestadores.doc(), {
        ...p.copyWith(donoUid: donoUid).toMap(),
        'criadoEm': FieldValue.serverTimestamp(),
      });
    }
    await lote.commit();
  }
}
