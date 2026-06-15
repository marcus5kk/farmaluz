import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import '../models/banner_item.dart';
import '../models/subcategoria.dart';
import '../services/api_service.dart';
import '../providers/carrinho_provider.dart';
import '../utils/dialog_utils.dart';
import '../widgets/produto_card.dart';
import '../widgets/categoria_bubble.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/cart_icon_badge.dart';
import 'search_screen.dart';
import 'categoria_detalhe_screen.dart';
import 'carrinho_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Categoria> _categorias = [];
  List<Subcategoria> _subcategorias = [];
  List<BannerItem> _banners = [];
  List<Produto> _destaques = [];
  List<Produto> _ofertas = [];
  String? _logoUrl;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final results = await Future.wait([
      ApiService.getFarmacia(),
      ApiService.getCategorias(),
      ApiService.getSubcategorias(),
      ApiService.getBanners(),
      ApiService.getProdutos(destaques: true),
      ApiService.getProdutos(ofertas: true),
    ]);

    final farmacia = results[0] as Map<String, dynamic>?;
    final logo = farmacia?['logo'];

    final corApi = farmacia?['cor_principal']?.toString() ?? '';
    if (corApi.isNotEmpty) {
      AppConfig.corPrimaria = corApi;
    }

    if (mounted) {
      setState(() {
        _logoUrl = (logo != null && logo.toString().isNotEmpty)
            ? 'https://api.appfarmacias.com.br/uploads/logos/$logo'
            : null;
        _categorias = results[1] as List<Categoria>;
        _subcategorias = results[2] as List<Subcategoria>;
        _banners = results[3] as List<BannerItem>;
        _destaques = results[4] as List<Produto>;
        _ofertas = results[5] as List<Produto>;
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
        _buildHeader(corPrimaria),
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _barraPesquisa(corPrimaria),
                        const SizedBox(height: 4),

                        if (_categorias.isNotEmpty) ...[
                          _secaoTitulo('Categorias'),
                          _listaCategorias(),
                        ],

                        if (_banners.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: BannerCarousel(banners: _banners),
                          ),
                        ],

                        if (_subcategorias.isNotEmpty) ...[
                          _secaoTitulo('Subcategorias'),
                          _listaSubcategorias(corPrimaria),
                        ],

                        if (_destaques.isNotEmpty) ...[
                          _secaoTitulo('Destaques'),
                          _listaProdutosHorizontal(_destaques),
                        ],

                        if (_ofertas.isNotEmpty) ...[
                          _secaoTitulo('Ofertas'),
                          _listaProdutosHorizontal(_ofertas),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(Color corPrimaria) {
    return Container(
      color: corPrimaria,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
          child: Row(
            children: [
              _logoWidget(),
              const Spacer(),
              CartIconBadge(onTap: _abrirCarrinho),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoWidget() {
    if (_logoUrl != null) {
      return CachedNetworkImage(
        imageUrl: _logoUrl!,
        height: 38,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => _logoTexto(),
      );
    }
    return _logoTexto();
  }

  Widget _logoTexto() {
    return Text(
      AppConfig.nomeFarmacia,
      style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _barraPesquisa(Color corPrimaria) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search, color: Colors.grey[500], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Pesquise aqui',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              ),
              Icon(Icons.qr_code_scanner, color: Colors.grey[500], size: 22),
              const SizedBox(width: 8),
              Icon(Icons.mic_none, color: Colors.grey[500], size: 22),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(titulo,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222))),
    );
  }

  Widget _listaCategorias() {
    return SizedBox(
      height: 106,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categorias.length,
        itemBuilder: (_, i) {
          final cat = _categorias[i];
          return CategoriaBubble(
            categoria: cat,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CategoriaDetalheScreen(categoria: cat)),
            ),
          );
        },
      ),
    );
  }

  Widget _listaSubcategorias(Color corPrimaria) {
    return SizedBox(
      height: 106,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _subcategorias.length,
        itemBuilder: (_, i) {
          final sub = _subcategorias[i];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: corPrimaria.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: corPrimaria.withOpacity(0.3), width: 1.5),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: sub.iconeUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Icon(Icons.label_outline,
                            color: corPrimaria, size: 28),
                        errorWidget: (_, __, ___) => Icon(
                            Icons.label_outline,
                            color: corPrimaria,
                            size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sub.nome,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _listaProdutosHorizontal(List<Produto> produtos) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: produtos.length,
        itemBuilder: (_, i) => ProdutoCard(produto: produtos[i]),
      ),
    );
  }
}
