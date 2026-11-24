import 'dart:async';

import '../models/usuario.dart';

/// Erro de autenticação com mensagem pronta para mostrar ao usuário.
class ErroAuth implements Exception {
  final String mensagem;
  const ErroAuth(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Contrato do serviço de autenticação (Firebase Auth ou memória).
abstract class ServicoAuth {
  Usuario? get atual;
  Stream<Usuario?> mudancas();
  Future<void> entrar(String email, String senha);
  Future<void> criarConta(String nome, String email, String senha);
  Future<void> redefinirSenha(String email);
  Future<void> sair();
}

/// Autenticação em memória, para testes e modo demonstração.
class AuthMemoria implements ServicoAuth {
  final Map<String, ({String senha, Usuario usuario})> _contas = {};
  final _mudancas = StreamController<Usuario?>.broadcast();
  Usuario? _atual;
  int _seq = 1;

  @override
  Usuario? get atual => _atual;

  @override
  Stream<Usuario?> mudancas() async* {
    yield _atual;
    yield* _mudancas.stream;
  }

  void _definir(Usuario? u) {
    _atual = u;
    _mudancas.add(u);
  }

  @override
  Future<void> criarConta(String nome, String email, String senha) async {
    final chave = email.trim().toLowerCase();
    if (_contas.containsKey(chave)) throw const ErroAuth('Este e-mail já está cadastrado.');
    if (senha.length < 6) throw const ErroAuth('A senha deve ter pelo menos 6 caracteres.');
    final u = Usuario(uid: 'u${_seq++}', email: chave, nome: nome.trim());
    _contas[chave] = (senha: senha, usuario: u);
    _definir(u);
  }

  @override
  Future<void> entrar(String email, String senha) async {
    final conta = _contas[email.trim().toLowerCase()];
    if (conta == null || conta.senha != senha) {
      throw const ErroAuth('E-mail ou senha incorretos.');
    }
    _definir(conta.usuario);
  }

  @override
  Future<void> redefinirSenha(String email) async {}

  @override
  Future<void> sair() async => _definir(null);
}
