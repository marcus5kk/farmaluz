import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import 'favoritos_screen.dart';

class PerfilScreen extends StatefulWidget {
  final bool standalone;
  const PerfilScreen({super.key, this.standalone = false});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _logado = false;
  String? _nomeCliente;
  String? _emailCliente;
  bool _carregando = true;
  bool _mostrarCadastro = false;

  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  bool _processando = false;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final logado = await ApiService.estaLogado();
    final nome = await ApiService.getNomeCliente();
    final email = await ApiService.getEmailCliente();
    if (mounted) {
      setState(() {
        _logado = logado;
        _nomeCliente = nome;
        _emailCliente = email;
        _carregando = false;
      });
    }
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _senhaCtrl.text.isEmpty) {
      setState(() => _erro = 'Preencha e-mail e senha.');
      return;
    }
    setState(() { _processando = true; _erro = ''; });
    final res =
        await ApiService.login(_emailCtrl.text.trim(), _senhaCtrl.text);
    if (res != null && res['token'] != null) {
      await ApiService.salvarSessao(res['token'], res['cliente'] ?? res);
      await _verificarSessao();
    } else {
      setState(() {
        _erro = 'E-mail ou senha incorretos.';
        _processando = false;
      });
    }
    if (mounted) setState(() => _processando = false);
  }

  Future<void> _cadastrar() async {
    if (_nomeCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _senhaCtrl.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos obrigatórios.');
      return;
    }
    setState(() { _processando = true; _erro = ''; });
    final res = await ApiService.cadastrar(
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      senha: _senhaCtrl.text,
      telefone: _telefoneCtrl.text.trim().isEmpty
          ? null
          : _telefoneCtrl.text.trim(),
    );
    if (res != null && res['token'] != null) {
      await ApiService.salvarSessao(res['token'], res['cliente'] ?? res);
      await _verificarSessao();
    } else {
      setState(() {
        _erro = res?['erro'] ?? 'Erro ao criar conta. Tente outro e-mail.';
        _processando = false;
      });
    }
    if (mounted) setState(() => _processando = false);
  }

  Future<void> _logout() async {
    await ApiService.logout();
    await _verificarSessao();
    setState(() {
      _emailCtrl.clear();
      _senhaCtrl.clear();
      _nomeCtrl.clear();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _nomeCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final corPrimaria =
        Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    if (_carregando) return const Center(child: CircularProgressIndicator());

    if (_logado) return _telaPerfil(corPrimaria);

    return _telaLoginCadastro(corPrimaria);
  }

  Widget _telaPerfil(Color corPrimaria) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: corPrimaria.withOpacity(0.15),
            child: Icon(Icons.person, size: 40, color: corPrimaria),
          ),
          const SizedBox(height: 16),
          Text(_nomeCliente ?? '',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(_emailCliente ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 32),
          _itemMenu(Icons.favorite_border, 'Meus Favoritos', corPrimaria, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FavoritosScreen()));
          }),
          _itemMenu(Icons.shopping_bag_outlined, 'Meus Pedidos', corPrimaria,
              () {}),
          _itemMenu(
              Icons.location_on_outlined, 'Meus Endereços', corPrimaria,
              () {}),
          _itemMenu(Icons.lock_outline, 'Alterar Senha', corPrimaria, () {}),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemMenu(
      IconData icon, String label, Color cor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: cor),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        trailing:
            const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _telaLoginCadastro(Color corPrimaria) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Icon(Icons.storefront_outlined, size: 56, color: corPrimaria),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: corPrimaria.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: corPrimaria.withOpacity(0.2)),
            ),
            child: Text(
              'Faça login ou crie sua conta para realizar pedidos pelo app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: corPrimaria.withOpacity(0.9),
                  height: 1.5),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _botaoOpcao(
                    'Entrar', !_mostrarCadastro, corPrimaria,
                    () => setState(
                        () { _mostrarCadastro = false; _erro = ''; })),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _botaoOpcao(
                    'Criar conta', _mostrarCadastro, corPrimaria,
                    () => setState(
                        () { _mostrarCadastro = true; _erro = ''; })),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_erro.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!)),
              child: Text(_erro,
                  style:
                      const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          if (_mostrarCadastro) ...[
            _campo('Nome completo *', _nomeCtrl, false),
            const SizedBox(height: 14),
            _campo('Telefone', _telefoneCtrl, false,
                tipo: TextInputType.phone),
          ],
          _campo('E-mail *', _emailCtrl, false,
              tipo: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _campo('Senha *', _senhaCtrl, true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _processando
                  ? null
                  : (_mostrarCadastro ? _cadastrar : _login),
              style: ElevatedButton.styleFrom(
                backgroundColor: corPrimaria,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _processando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(_mostrarCadastro ? 'Criar conta' : 'Entrar',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl, bool senha,
      {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: senha,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _botaoOpcao(
      String label, bool ativo, Color cor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ativo ? cor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cor),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ativo ? Colors.white : cor)),
      ),
    );
  }
}
