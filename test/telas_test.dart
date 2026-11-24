import 'package:bicolocal/data/auth.dart';
import 'package:bicolocal/data/fonte_memoria.dart';
import 'package:bicolocal/data/repositorio.dart';
import 'package:bicolocal/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuthMemoria auth;

  setUp(() {
    auth = AuthMemoria();
    Repositorio.instancia =
        Repositorio(fonte: FonteMemoria(), auth: auth, modoDemonstracao: true);
  });

  testWidgets('home lista prestadores e filtra por categoria', (tester) async {
    await tester.pumpWidget(const BicoLocalApp());
    await tester.pumpAndSettle();

    expect(find.text('Maria Souza'), findsOneWidget);
    expect(find.textContaining('Modo demonstração'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Elétrica'));
    await tester.pumpAndSettle();
    expect(find.text('João Pereira'), findsOneWidget);
    expect(find.text('Maria Souza'), findsNothing);
  });

  testWidgets('oferecer serviço sem login abre a tela de login', (tester) async {
    await tester.pumpWidget(const BicoLocalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oferecer serviço'));
    await tester.pumpAndSettle();
    expect(find.text('Entre para publicar seu serviço.'), findsOneWidget);
  });

  testWidgets('erro do formulário some ao corrigir o campo', (tester) async {
    await auth.criarConta('Kaue', 'kaue@exemplo.com', '123456');
    await tester.pumpWidget(const BicoLocalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oferecer serviço'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Publicar serviço'), 200,
        scrollable: find
            .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
            .first);
    await tester.tap(find.text('Publicar serviço'));
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsOneWidget); // descrição vazia

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Descreva seu serviço'), 'Pequenos reparos');
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsNothing);
  });

  testWidgets('cliente logado avalia um prestador', (tester) async {
    await auth.criarConta('Kaue', 'kaue@exemplo.com', '123456');
    await tester.pumpWidget(const BicoLocalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ana Krause'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Avaliar'), 200);
    await tester.tap(find.text('Avaliar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('4 estrelas'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'Explica muito bem');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Explica muito bem\n${_hoje()}'), findsOneWidget);
    expect(find.text('Obrigado pela avaliação!'), findsOneWidget);
    expect(Repositorio.instancia.prestadorPorId('4')!.totalAvaliacoes, 13);
  });
}

String _hoje() {
  final d = DateTime.now();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
