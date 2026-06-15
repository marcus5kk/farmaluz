import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../models/categoria.dart';
import '../services/api_service.dart';
import '../providers/carrinho_provider.dart';
import '../utils/dialog_utils.dart';
import '../widgets/cart_icon_badge.dart';
import '../providers/app_nav.dart';
import 'categoria_detalhe_screen.dart';
import 'carrinho_screen.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> _categorias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final cats = await ApiService.getCategorias();
    if (mounted) {
      setState(() {
        _categorias = cats;
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

    return Column(
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
                    onPressed: () => AppNav.goHome(),
                  ),
                  const Expanded(
                    child: Text(
                      'Categorias',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  CartIconBadge(onTap: _abrirCarrinho),
                ],
              ),
            ),
          ),
        ),
        if (_carregando)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'Confira abaixo as principais categorias de produtos disponíveis em todo nosso app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _categorias.length,
                    itemBuilder: (_, i) =>
                        _categoriaCard(_categorias[i], context, corPrimaria),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _categoriaCard(
      Categoria cat, BuildContext context, Color corPrimaria) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CategoriaDetalheScreen(categoria: cat)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: cat.iconeUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: cat.iconeUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            color: Colors.grey[100],
                            child: Icon(Icons.grid_view,
                                color: corPrimaria.withOpacity(0.4),
                                size: 40)),
                        errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: Icon(Icons.grid_view,
                                color: corPrimaria.withOpacity(0.4),
                                size: 40)),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(Icons.grid_view,
                            color: corPrimaria.withOpacity(0.4), size: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cat.totalProdutos} produto${cat.totalProdutos != 1 ? 's' : ''}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
