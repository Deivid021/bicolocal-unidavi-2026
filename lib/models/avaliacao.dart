/// Avaliação de um prestador feita por um cliente.
/// Cada usuário tem no máximo uma avaliação por prestador (o id é o uid do autor);
/// avaliar de novo substitui a avaliação anterior.
class Avaliacao {
  final String autorUid;
  final String autorNome;
  final int nota; // 1 a 5
  final String comentario;
  final DateTime data;

  const Avaliacao({
    required this.autorUid,
    required this.autorNome,
    required this.nota,
    required this.comentario,
    required this.data,
  });

  Map<String, dynamic> toMap() => {
        'autorUid': autorUid,
        'autorNome': autorNome,
        'nota': nota,
        'comentario': comentario,
        'data': data.millisecondsSinceEpoch,
      };

  factory Avaliacao.fromMap(Map<String, dynamic> m) => Avaliacao(
        autorUid: m['autorUid'] as String? ?? '',
        autorNome: m['autorNome'] as String? ?? 'Cliente',
        nota: (m['nota'] as num?)?.toInt() ?? 0,
        comentario: m['comentario'] as String? ?? '',
        data: DateTime.fromMillisecondsSinceEpoch((m['data'] as num?)?.toInt() ?? 0),
      );
}
