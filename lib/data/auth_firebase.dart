import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';
import 'auth.dart';

/// [ServicoAuth] com Firebase Authentication (e-mail e senha).
class AuthFirebase implements ServicoAuth {
  AuthFirebase([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Usuario? _converter(User? u) => u == null
      ? null
      : Usuario(
          uid: u.uid,
          email: u.email ?? '',
          nome: (u.displayName?.isNotEmpty ?? false)
              ? u.displayName!
              : (u.email ?? 'Usuário').split('@').first,
        );

  @override
  Usuario? get atual => _converter(_auth.currentUser);

  // userChanges (e não authStateChanges) para refletir o displayName
  // definido logo após criar a conta.
  @override
  Stream<Usuario?> mudancas() => _auth.userChanges().map(_converter);

  @override
  Future<void> entrar(String email, String senha) =>
      _traduzir(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: senha));

  @override
  Future<void> criarConta(String nome, String email, String senha) => _traduzir(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: senha);
        await cred.user?.updateDisplayName(nome.trim());
      });

  @override
  Future<void> redefinirSenha(String email) =>
      _traduzir(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> sair() => _auth.signOut();

  Future<void> _traduzir(Future<dynamic> Function() acao) async {
    try {
      await acao();
    } on FirebaseAuthException catch (e) {
      throw ErroAuth(_mensagem(e.code));
    }
  }

  static String _mensagem(String codigo) => switch (codigo) {
        'invalid-email' => 'E-mail inválido.',
        'user-disabled' => 'Esta conta foi desativada.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
        'too-many-requests' => 'Muitas tentativas. Aguarde um pouco e tente de novo.',
        'network-request-failed' => 'Sem conexão com a internet.',
        _ => 'Não foi possível concluir ($codigo).',
      };
}
