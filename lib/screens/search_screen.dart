import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../widgets/produto_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _speech = SpeechToText();
  Timer? _debounce;
  List<Produto> _resultados = [];
  bool _carregando = false;
  bool _escutando = false;
  bool _speechDisponivel = false;

  @override
  void initState() {
    super.initState();
    _iniciarSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  Future<void> _iniciarSpeech() async {
    _speechDisponivel = await _speech.initialize();
    if (mounted) setState(() {});
  }

  void _onTextChange(String texto) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _buscar(texto));
  }

  Future<void> _buscar(String texto, {String? codigoBarras}) async {
    if (texto.isEmpty && codigoBarras == null) {
      setState(() { _resultados = []; _carregando = false; });
      return;
    }
    setState(() => _carregando = true);
    final res = await ApiService.getProdutos(busca: texto, codigoBarras: codigoBarras);
    if (mounted) setState(() { _resultados = res; _carregando = false; });
  }

  Future<void> _abrirScanner() async {
    final codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerScreen()),
    );
    if (codigo != null && codigo.isNotEmpty) {
      _controller.text = codigo;
      await _buscar('', codigoBarras: codigo);
    }
  }

  Future<void> _iniciarVoz() async {
    if (!_speechDisponivel) return;
    if (_escutando) {
      await _speech.stop();
      setState(() => _escutando = false);
      return;
    }
    setState(() => _escutando = true);
    await _speech.listen(
      onResult: (r) {
        _controller.text = r.recognizedWords;
        _onTextChange(r.recognizedWords);
      },
      listenFor: const Duration(seconds: 10),
      localeId: 'pt_BR',
    );
    await Future.delayed(const Duration(seconds: 11));
    if (mounted) setState(() => _escutando = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    return Scaffold(
      backgroundColor: Color(int.parse(AppConfig.corFundo.replaceAll('#', '0xFF'))),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: corPrimaria,
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focus,
                              onChanged: _onTextChange,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Pesquise aqui...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.qr_code_scanner, color: Colors.grey[600], size: 22),
                            onPressed: _abrirScanner,
                            tooltip: 'Código de barras',
                          ),
                          IconButton(
                            icon: Icon(
                              _escutando ? Icons.mic : Icons.mic_none,
                              color: _escutando ? corPrimaria : Colors.grey[600],
                              size: 22,
                            ),
                            onPressed: _iniciarVoz,
                            tooltip: 'Busca por voz',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_escutando)
              Container(
                color: corPrimaria.withOpacity(0.08),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: corPrimaria, size: 18),
                    const SizedBox(width: 8),
                    const Text('Ouvindo... fale o nome do produto', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            Expanded(
              child: _controller.text.isEmpty
                  ? _telaVazia(corPrimaria)
                  : _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : _resultados.isEmpty
                          ? const Center(child: Text('Nenhum produto encontrado', style: TextStyle(color: Colors.grey)))
                          : _listaResultados(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _telaVazia(Color corPrimaria) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              _opcaoBusca(
                icon: Icons.qr_code_scanner,
                label: 'Código de barras',
                cor: corPrimaria,
                onTap: _abrirScanner,
              ),
              const SizedBox(width: 12),
              _opcaoBusca(
                icon: Icons.mic_none,
                label: 'Busca por voz',
                cor: corPrimaria,
                onTap: _iniciarVoz,
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Busca de produtos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 8),
          const Text('Digite o nome do produto na barra acima para pesquisar.', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _opcaoBusca({required IconData icon, required String label, required Color cor, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: cor, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, color: cor, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaResultados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('${_resultados.length} produto(s) encontrado(s)', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _resultados.length,
            itemBuilder: (_, i) => ProdutoCard(produto: _resultados[i]),
          ),
        ),
      ],
    );
  }
}

class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  bool _detectado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leia o código de barras'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: MobileScanner(
        onDetect: (capture) {
          if (_detectado) return;
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            _detectado = true;
            Navigator.pop(context, barcode.rawValue);
          }
        },
      ),
    );
  }
}
