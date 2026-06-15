import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../providers/carrinho_provider.dart';
import '../utils/dialog_utils.dart';
import '../widgets/produto_card.dart';
import '../widgets/cart_icon_badge.dart';
import '../providers/app_nav.dart';
import 'carrinho_screen.dart';

class OfertasScreen extends StatefulWidget {
  const OfertasScreen({super.key});

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {
  List<Produto> _ofertas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final res = await ApiService.getProdutos(ofertas: true);
    if (mounted) setState(() { _ofertas = res; _carregando = false; });
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
                      'Ofertas',
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
            child: _ofertas.isEmpty
                ? const Center(
                    child: Text('Nenhuma oferta disponível no momento.',
                        style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: _carregar,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 235,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _ofertas.length,
                      itemBuilder: (_, i) =>
                          ProdutoCard(produto: _ofertas[i], inGrid: true),
                    ),
                  ),
          ),
      ],
    );
  }
}
