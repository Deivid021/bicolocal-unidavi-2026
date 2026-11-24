class Prestador {
  final String id;
  final String nome;
  final String categoriaId;
  final String descricao;
  final String bairro;
  final String telefone; // formato internacional, ex.: 5547999990000
  final int somaNotas;
  final int totalAvaliacoes;
  final String faixaPreco;
  final bool disponivel;

  /// uid do usuário (Firebase Auth) que publicou o anúncio.
  final String donoUid;

  const Prestador({
    required this.id,
    required this.nome,
    required this.categoriaId,
    required this.descricao,
    required this.bairro,
    required this.telefone,
    required this.faixaPreco,
    required this.donoUid,
    this.somaNotas = 0,
    this.totalAvaliacoes = 0,
    this.disponivel = true,
  });

  /// Média das notas (0 quando ainda não há avaliações).
  double get avaliacao => totalAvaliacoes == 0 ? 0 : somaNotas / totalAvaliacoes;

  bool get semAvaliacoes => totalAvaliacoes == 0;

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  /// Telefone sem o código do país, para exibir e editar no formulário.
  String get telefoneLocal =>
      telefone.startsWith('55') ? telefone.substring(2) : telefone;

  Prestador copyWith({
    String? id,
    String? nome,
    String? categoriaId,
    String? descricao,
    String? bairro,
    String? telefone,
    int? somaNotas,
    int? totalAvaliacoes,
    String? faixaPreco,
    bool? disponivel,
    String? donoUid,
  }) {
    return Prestador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoriaId: categoriaId ?? this.categoriaId,
      descricao: descricao ?? this.descricao,
      bairro: bairro ?? this.bairro,
      telefone: telefone ?? this.telefone,
      somaNotas: somaNotas ?? this.somaNotas,
      totalAvaliacoes: totalAvaliacoes ?? this.totalAvaliacoes,
      faixaPreco: faixaPreco ?? this.faixaPreco,
      disponivel: disponivel ?? this.disponivel,
      donoUid: donoUid ?? this.donoUid,
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'categoriaId': categoriaId,
        'descricao': descricao,
        'bairro': bairro,
        'telefone': telefone,
        'somaNotas': somaNotas,
        'totalAvaliacoes': totalAvaliacoes,
        'faixaPreco': faixaPreco,
        'disponivel': disponivel,
        'donoUid': donoUid,
      };

  factory Prestador.fromMap(String id, Map<String, dynamic> m) => Prestador(
        id: id,
        nome: m['nome'] as String? ?? '',
        categoriaId: m['categoriaId'] as String? ?? '',
        descricao: m['descricao'] as String? ?? '',
        bairro: m['bairro'] as String? ?? '',
        telefone: m['telefone'] as String? ?? '',
        somaNotas: (m['somaNotas'] as num?)?.toInt() ?? 0,
        totalAvaliacoes: (m['totalAvaliacoes'] as num?)?.toInt() ?? 0,
        faixaPreco: m['faixaPreco'] as String? ?? 'A combinar',
        disponivel: m['disponivel'] as bool? ?? true,
        donoUid: m['donoUid'] as String? ?? '',
      );
}
