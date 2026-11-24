import 'package:flutter/material.dart';

import '../data/auth.dart';
import '../data/repositorio.dart';

/// Abre a tela de login se ninguém estiver logado.
/// Devolve true quando, ao final, há um usuário logado.
Future<bool> exigirLogin(BuildContext context, {String? motivo}) async {
  final repo = Repositorio.instancia;
  if (repo.logado) return true;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => LoginScreen(motivo: motivo)),
  );
  return repo.logado;
}

class LoginScreen extends StatefulWidget {
  /// Texto explicando por que o login foi pedido (ex.: "para avaliar").
  final String? motivo;

  const LoginScreen({super.key, this.motivo});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _auth = Repositorio.instancia.auth;

  bool _criandoConta = false;
  bool _enviando = false;

  /// Depois da primeira tentativa, revalida cada campo enquanto o usuário corrige.
  AutovalidateMode _validacao = AutovalidateMode.disabled;
  bool _senhaVisivel = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _validacao = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      if (_criandoConta) {
        await _auth.criarConta(_nome.text, _email.text, _senha.text);
      } else {
        await _auth.entrar(_email.text, _senha.text);
      }
      if (mounted) Navigator.of(context).pop();
    } on ErroAuth catch (e) {
      setState(() => _erro = e.mensagem);
    } catch (_) {
      setState(() => _erro = 'Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _esqueciSenha() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _erro = 'Digite seu e-mail acima para redefinir a senha.');
      return;
    }
    try {
      await _auth.redefinirSenha(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviamos um link de redefinição para $email.')),
      );
    } on ErroAuth catch (e) {
      setState(() => _erro = e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(_criandoConta ? 'Criar conta' : 'Entrar')),
      body: Form(
        key: _formKey,
        autovalidateMode: _validacao,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.handshake_outlined, size: 56, color: cores.primary),
            const SizedBox(height: 8),
            Text('BicoLocal', textAlign: TextAlign.center, style: texto.headlineSmall),
            const SizedBox(height: 4),
            Text(
              widget.motivo ?? 'Entre para oferecer serviços, avaliar e salvar favoritos.',
              textAlign: TextAlign.center,
              style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (_criandoConta) ...[
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Seu nome', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                  labelText: 'E-mail', border: OutlineInputBorder()),
              validator: (v) {
                final e = (v ?? '').trim();
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)
                    ? null
                    : 'Informe um e-mail válido';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _senha,
              obscureText: !_senhaVisivel,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
                  icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                ),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'A senha deve ter pelo menos 6 caracteres'
                  : null,
              onFieldSubmitted: (_) => _enviar(),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(_erro!, style: TextStyle(color: cores.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_criandoConta ? 'Criar conta' : 'Entrar'),
            ),
            if (!_criandoConta)
              TextButton(onPressed: _esqueciSenha, child: const Text('Esqueci minha senha')),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _criandoConta = !_criandoConta;
                _erro = null;
              }),
              child: Text(_criandoConta
                  ? 'Já tenho conta – entrar'
                  : 'Ainda não tenho conta – criar agora'),
            ),
          ],
        ),
      ),
    );
  }
}
