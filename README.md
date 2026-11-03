# BicoLocal

Aplicativo móvel (Flutter) que conecta **prestadores de serviços autônomos** ("bicos") — eletricistas, diaristas, encanadores, jardineiros, professores particulares, fretes — a **clientes de Rio do Sul e região**.

Projeto de Extensão – Desenvolvimento para Plataformas Móveis – Bacharelado em Sistemas de Informação – Unidavi (2026).

**Equipe:** Deivid Sestren · Kaue Gorges
**Professor:** Sandro Alencar Fernandes

## Estado atual (Entrega 1 – 03/11/2026)

- [x] Listagem de prestadores ordenada por avaliação
- [x] Busca por nome, serviço ou bairro
- [x] Filtro por categoria (chips)
- [x] Tela de detalhes do prestador
- [x] Contato via WhatsApp (mensagem pré-preenchida) e ligação
- [x] Cadastro de novo serviço com validação de formulário
- [ ] Persistência real (Firebase) e login — Etapa 2
- [ ] Avaliações feitas pelos clientes — Etapa 2
- [ ] Favoritos e mapa de prestadores — Etapa 2

Os dados atuais são mantidos em memória (`lib/data/repositorio.dart`).

## Estrutura

```
lib/
  main.dart                 # MaterialApp + tema
  models/                   # Categoria, Prestador
  data/repositorio.dart     # Repositório em memória (ChangeNotifier)
  screens/                  # Home, Detalhe, Cadastro
  widgets/prestador_card.dart
test/repositorio_test.dart  # testes da busca/filtro
```

## Como executar

Requer Flutter 3.22+.

```bash
flutter create . --project-name bicolocal --platforms=android,ios,web   # gera as pastas de plataforma
flutter pub get
flutter run
flutter test
```
