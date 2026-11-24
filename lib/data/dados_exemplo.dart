import '../models/prestador.dart';

/// Dono fictício dos anúncios de exemplo.
const donoExemplo = 'exemplo';

/// Prestadores de exemplo (dados fictícios) usados no modo demonstração,
/// nos testes e para popular um Firestore vazio.
const prestadoresExemplo = <Prestador>[
  Prestador(
      id: '1', nome: 'João Pereira', categoriaId: 'eletrica',
      descricao: 'Eletricista com 10 anos de experiência. Instalações residenciais, troca de disjuntores, chuveiros e tomadas.',
      bairro: 'Canta Galo', telefone: '5547999990001',
      somaNotas: 154, totalAvaliacoes: 32, faixaPreco: 'R\$ 80 – 150/visita',
      donoUid: donoExemplo),
  Prestador(
      id: '2', nome: 'Maria Souza', categoriaId: 'limpeza',
      descricao: 'Diarista. Limpeza residencial e pós-obra. Atendo Centro e bairros próximos.',
      bairro: 'Centro', telefone: '5547999990002',
      somaNotas: 250, totalAvaliacoes: 51, faixaPreco: 'R\$ 180/diária',
      donoUid: donoExemplo),
  Prestador(
      id: '3', nome: 'Carlos Schmitt', categoriaId: 'hidraulica',
      descricao: 'Encanador. Vazamentos, desentupimentos, instalação de caixa d\'água.',
      bairro: 'Budag', telefone: '5547999990003',
      somaNotas: 83, totalAvaliacoes: 18, faixaPreco: 'R\$ 70 – 200/serviço',
      donoUid: donoExemplo),
  Prestador(
      id: '4', nome: 'Ana Krause', categoriaId: 'aulas',
      descricao: 'Aulas particulares de matemática e física para ensino fundamental e médio.',
      bairro: 'Santana', telefone: '5547999990004',
      somaNotas: 60, totalAvaliacoes: 12, faixaPreco: 'R\$ 60/hora',
      donoUid: donoExemplo),
  Prestador(
      id: '5', nome: 'Pedro Hoffmann', categoriaId: 'jardinagem',
      descricao: 'Corte de grama, poda de árvores e limpeza de terrenos.',
      bairro: 'Laranjeiras', telefone: '5547999990005',
      somaNotas: 99, totalAvaliacoes: 22, faixaPreco: 'R\$ 100 – 250/serviço',
      disponivel: false, donoUid: donoExemplo),
  Prestador(
      id: '6', nome: 'Lucas Ramos', categoriaId: 'fretes',
      descricao: 'Fretes e pequenas mudanças com caminhonete. Rio do Sul e região.',
      bairro: 'Navegantes', telefone: '5547999990006',
      somaNotas: 127, totalAvaliacoes: 27, faixaPreco: 'A combinar',
      donoUid: donoExemplo),
  Prestador(
      id: '7', nome: 'Roberto Lima', categoriaId: 'pintura',
      descricao: 'Pintura residencial interna e externa, textura e grafiato.',
      bairro: 'Barragem', telefone: '5547999990007',
      somaNotas: 40, totalAvaliacoes: 9, faixaPreco: 'R\$ 25/m²',
      donoUid: donoExemplo),
];
