import 'package:bicolocal/data/repositorio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = Repositorio.instancia;

  test('busca por categoria retorna apenas a categoria', () {
    final r = repo.buscar(categoriaId: 'eletrica');
    expect(r, isNotEmpty);
    expect(r.every((p) => p.categoriaId == 'eletrica'), isTrue);
  });

  test('busca por bairro ignora maiúsculas', () {
    final r = repo.buscar(texto: 'centro');
    expect(r.any((p) => p.bairro == 'Centro'), isTrue);
  });

  test('resultados ordenados por avaliação', () {
    final r = repo.buscar();
    for (var i = 1; i < r.length; i++) {
      expect(r[i - 1].avaliacao >= r[i].avaliacao, isTrue);
    }
  });
}
