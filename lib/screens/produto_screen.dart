import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../providers/carrinho_provider.dart';
import '../providers/favoritos_provider.dart';
import '../utils/dialog_utils.dart';
import '../widgets/cart_icon_badge.dart';
import 'search_screen.dart';
import 'carrinho_screen.dart';

class ProdutoScreen extends StatefulWidget {
  final Produto produto;
  const ProdutoScreen({super.key, required this.produto});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  int _quantidade = 1;

  void _comprar() {
    CarrinhoController.instance
        .adicionar(widget.produto, quantidade: _quantidade);
    DialogUtils.mostrarAdicionadoAoCarrinho(context);
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
    final p = widget.produto;

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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(child: _barraPesquisa()),
                    CartIconBadge(onTap: _abrirCarrinho),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      p.nome,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222)),
                    ),
                  ),
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: p.imagemUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: p.imagemUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                    color: Colors.grey[100],
                                    child: const Center(
                                        child: CircularProgressIndicator())),
                                errorWidget: (_, __, ___) =>
                                    _semImagem(),
                              )
                            : _semImagem(),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: ValueListenableBuilder<List<Produto>>(
                          valueListenable: FavoritosController.instance.items,
                          builder: (_, __, ___) {
                            final isFav = FavoritosController.instance
                                .isFavorito(p.id);
                            return GestureDetector(
                              onTap: () =>
                                  FavoritosController.instance.toggle(p),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6)
                                  ],
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (p.temPromocao) ...[
                                Text(
                                  'R\$ ${p.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough),
                                ),
                                Text(
                                  'R\$ ${p.precoPromocional!.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: corPrimaria),
                                ),
                              ] else
                                Text(
                                  'R\$ ${p.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: corPrimaria),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _btnQtd(Icons.remove, () {
                              if (_quantidade > 1) {
                                setState(() => _quantidade--);
                              }
                            }, corPrimaria),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('$_quantidade',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            _btnQtd(Icons.add,
                                () => setState(() => _quantidade++),
                                corPrimaria),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _comprar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corPrimaria,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Comprar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  if (p.descricao != null && p.descricao!.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text('Descrição',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF222222))),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Text(p.descricao!,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5)),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
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

  Widget _btnQtd(IconData icon, VoidCallback onTap, Color cor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: cor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: cor),
      ),
    );
  }

  Widget _semImagem() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
          child: Icon(Icons.medication_outlined, size: 60, color: Colors.grey)),
    );
  }
}
