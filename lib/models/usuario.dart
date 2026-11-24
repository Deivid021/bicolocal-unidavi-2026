/// Usuário autenticado (cliente ou prestador; o mesmo login serve para os dois papéis).
class Usuario {
  final String uid;
  final String email;
  final String nome;

  const Usuario({required this.uid, required this.email, required this.nome});
}
