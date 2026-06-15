import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../providers/carrinho_provider.dart';
import '../utils/dialog_utils.dart';
import '../widgets/cart_icon_badge.dart';
import '../widgets/produto_card.dart';
import 'search_screen.dart';
import 'carrinho_screen.dart';

class ProdutosListaScreen extends StatefulWidget {
  final String titulo;
  final int? categoriaId;
  final int? subcategoriaId;

  const ProdutosListaScreen({
    super.key,
    required this.titulo,
    this.categoriaId,
    this.subcategoriaId,
  });

  @override
  State<ProdutosListaScreen> createState() => _ProdutosListaScreenState();
}

class _ProdutosListaScreenState extends State<ProdutosListaScreen> {
  List<Produto> _produtos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final prods = await ApiService.getProdutos(
      categoria: widget.categoriaId,
      subcategoria: widget.subcategoriaId,
    );
    if (mounted) {
      setState(() {
        _produtos = prods;
        _carregando = false;
      });
    }
  }

  void _abrirCarrinho() {
    if (CarrinhoController.instance.totalTipos == 0) {
      DialogUtils.mostrarCarrinhoVazio(context);
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CarrinhoScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final corPrimaria =
        Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: corPrimaria,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(child: _barraPesquisa()),
                    CartIconBadge(onTap: _abrirCarrinho),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Text(
              widget.titulo,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222)),
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _produtos.isEmpty
                    ? const Center(
                        child: Text('Nenhum produto encontrado',
                            style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 235,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _produtos.length,
                        itemBuilder: (_, i) =>
                            ProdutoCard(produto: _produtos[i], inGrid: true),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _barraPesquisa() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SearchScreen())),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(Icons.search, color: Colors.grey[500], size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Pesquise aqui',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
