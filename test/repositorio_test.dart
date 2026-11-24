import 'package:bicolocal/data/auth.dart';
import 'package:bicolocal/data/fonte_memoria.dart';
import 'package:bicolocal/data/repositorio.dart';
import 'package:bicolocal/models/prestador.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deixa os streams da fonte em memória entregarem os eventos pendentes.
Future<void> processar() => Future<void>.delayed(Duration.zero);

Prestador novoAnuncio({String nome = 'Teste Silva'}) => Prestador(
      id: '',
      nome: nome,
      categoriaId: 'reformas',
      descricao: 'Pequenas reformas',
      bairro: 'Centro',
      telefone: '5547999998888',
      faixaPreco: 'A combinar',
      donoUid: '',
    );

void main() {
  late Repositorio repo;
  late AuthMemoria auth;

  setUp(() async {
    auth = AuthMemoria();
    repo = Repositorio(fonte: FonteMemoria(), auth: auth);
    await processar();
  });

  tearDown(() => repo.dispose());

  group('busca e filtros', () {
    test('busca por categoria retorna apenas a categoria', () {
      final r = repo.buscar(categoriaId: 'eletrica');
      expect(r, isNotEmpty);
      expect(r.every((p) => p.categoriaId == 'eletrica'), isTrue);
    });

    test('busca por bairro ignora maiúsculas', () {
      final r = repo.buscar(texto: 'centro');
      expect(r.any((p) => p.bairro == 'Centro'), isTrue);
    });

    test('busca pelo nome da categoria', () {
      final r = repo.buscar(texto: 'hidráulica');
      expect(r.map((p) => p.nome), contains('Carlos Schmitt'));
    });

    test('resultados ordenados por avaliação', () {
      final r = repo.buscar();
      for (var i = 1; i < r.length; i++) {
        expect(r[i - 1].avaliacao >= r[i].avaliacao, isTrue);
      }
    });
  });

  group('login', () {
    test('criar conta, sair e entrar de novo', () async {
      await auth.criarConta('Kaue', 'kaue@exemplo.com', '123456');
      await processar();
      expect(repo.usuario?.nome, 'Kaue');
      await auth.sair();
      await processar();
      expect(repo.logado, isFalse);
      await auth.entrar('KAUE@exemplo.com', '123456');
      await processar();
      expect(repo.logado, isTrue);
    });

    test('senha errada gera ErroAuth', () async {
      await auth.criarConta('Kaue', 'kaue@exemplo.com', '123456');
      await auth.sair();
      expect(() => auth.entrar('kaue@exemplo.com', 'errada'), throwsA(isA<ErroAuth>()));
    });

    test('ações que exigem login falham sem usuário', () {
      expect(() => repo.adicionar(novoAnuncio()), throwsA(isA<ErroAuth>()));
      expect(() => repo.alternarFavorito('1'), throwsA(isA<ErroAuth>()));
      expect(() => repo.avaliar('1', 5, ''), throwsA(isA<ErroAuth>()));
    });
  });

  group('anúncios do prestador', () {
    setUp(() async {
      await auth.criarConta('Deivid', 'deivid@exemplo.com', '123456');
      await processar();
    });

    test('publicar, editar e remover o próprio anúncio', () async {
      final id = await repo.adicionar(novoAnuncio());
      await processar();
      expect(repo.meusAnuncios.map((p) => p.id), [id]);
      expect(repo.prestadorPorId(id)!.semAvaliacoes, isTrue);

      await repo.atualizar(repo.prestadorPorId(id)!.copyWith(faixaPreco: 'R\$ 50/hora'));
      await repo.definirDisponivel(repo.prestadorPorId(id)!, false);
      await processar();
      expect(repo.prestadorPorId(id)!.faixaPreco, 'R\$ 50/hora');
      expect(repo.prestadorPorId(id)!.disponivel, isFalse);

      await repo.remover(id);
      await processar();
      expect(repo.prestadorPorId(id), isNull);
      expect(repo.meusAnuncios, isEmpty);
    });

    test('não é possível alterar anúncio de outra pessoa', () {
      expect(() => repo.remover('1'), throwsStateError);
      expect(() => repo.atualizar(repo.prestadorPorId('1')!), throwsStateError);
    });

    test('não é possível avaliar o próprio anúncio', () async {
      final id = await repo.adicionar(novoAnuncio());
      await processar();
      expect(() => repo.avaliar(id, 5, ''), throwsStateError);
    });
  });

  group('avaliações', () {
    test('média recalculada e nova nota do mesmo cliente substitui a anterior', () async {
      await auth.criarConta('Dono', 'dono@exemplo.com', '123456');
      await processar();
      final id = await repo.adicionar(novoAnuncio());

      await auth.criarConta('Cliente A', 'a@exemplo.com', '123456');
      await processar();
      await repo.avaliar(id, 5, 'Ótimo');

      await auth.criarConta('Cliente B', 'b@exemplo.com', '123456');
      await processar();
      await repo.avaliar(id, 3, '');
      await processar();
      expect(repo.prestadorPorId(id)!.totalAvaliacoes, 2);
      expect(repo.prestadorPorId(id)!.avaliacao, 4.0);

      await repo.avaliar(id, 4, 'Mudei de ideia');
      await processar();
      expect(repo.prestadorPorId(id)!.totalAvaliacoes, 2);
      expect(repo.prestadorPorId(id)!.avaliacao, 4.5);

      final lista = await repo.avaliacoes(id).first;
      expect(lista, hasLength(2));
      expect(lista.first.comentario, 'Mudei de ideia');
    });

    test('nota fora de 1 a 5 é rejeitada', () async {
      await auth.criarConta('Cliente', 'c@exemplo.com', '123456');
      await processar();
      expect(() => repo.avaliar('1', 6, ''), throwsArgumentError);
    });
  });

  group('favoritos', () {
    test('marcar, filtrar e desmarcar', () async {
      await auth.criarConta('Cliente', 'c@exemplo.com', '123456');
      await processar();
      await repo.alternarFavorito('3');
      await processar();
      expect(repo.ehFavorito('3'), isTrue);
      expect(repo.buscar(somenteFavoritos: true).map((p) => p.id), ['3']);

      await repo.alternarFavorito('3');
      await processar();
      expect(repo.buscar(somenteFavoritos: true), isEmpty);
    });

    test('favoritos são de cada usuário', () async {
      await auth.criarConta('A', 'a@exemplo.com', '123456');
      await processar();
      await repo.alternarFavorito('1');
      await auth.criarConta('B', 'b@exemplo.com', '123456');
      await processar();
      expect(repo.favoritos, isEmpty);
    });
  });
}
