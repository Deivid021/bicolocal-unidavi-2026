class Prestador {
  final String id;
  final String nome;
  final String categoriaId;
  final String descricao;
  final String bairro;
  final String telefone; // formato internacional, ex.: 5547999990000
  final double avaliacao;
  final int totalAvaliacoes;
  final String faixaPreco;
  final bool disponivel;

  const Prestador({
    required this.id,
    required this.nome,
    required this.categoriaId,
    required this.descricao,
    required this.bairro,
    required this.telefone,
    required this.avaliacao,
    required this.totalAvaliacoes,
    required this.faixaPreco,
    this.disponivel = true,
  });

  String get iniciais {
    final partes = nome.trim().split(' ');
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }
}
