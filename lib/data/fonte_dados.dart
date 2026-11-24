import '../models/avaliacao.dart';
import '../models/prestador.dart';

/// Contrato da fonte de dados. O Repositório (e as telas) dependem só desta
/// interface, assim a troca entre memória (testes/modo demonstração) e
/// Cloud Firestore não exige mudanças na interface.
abstract class FonteDados {
  /// Lista de prestadores, atualizada em tempo real.
  Stream<List<Prestador>> prestadores();

  /// Cria o anúncio e devolve o id gerado.
  Future<String> adicionar(Prestador p);

  /// Atualiza os dados do anúncio (não altera as notas).
  Future<void> atualizar(Prestador p);

  Future<void> remover(String prestadorId);

  /// Avaliações de um prestador, mais recentes primeiro.
  Stream<List<Avaliacao>> avaliacoes(String prestadorId);

  /// Grava (ou substitui) a avaliação do autor e recalcula a média do prestador.
  Future<void> avaliar(String prestadorId, Avaliacao avaliacao);

  /// Ids dos prestadores favoritados pelo usuário.
  Stream<Set<String>> favoritos(String uid);

  Future<void> definirFavorito(String uid, String prestadorId, bool favorito);

  /// Cria os prestadores de exemplo em nome de [donoUid] (banco vazio, modo debug).
  Future<void> popularExemplos(String donoUid);
}
