import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../providers/carrinho_provider.dart';
import '../utils/dialog_utils.dart';
import '../widgets/cart_icon_badge.dart';
import '../providers/app_nav.dart';
import 'carrinho_screen.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final corPrimaria =
        Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    void abrirCarrinho() {
      if (CarrinhoController.instance.totalTipos == 0) {
        DialogUtils.mostrarCarrinhoVazio(context);
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CarrinhoScreen()));
      }
    }

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
                      'Pedidos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  CartIconBadge(onTap: abrirCarrinho),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: corPrimaria.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text('Meus Pedidos',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333))),
                const SizedBox(height: 8),
                const Text('Seus pedidos aparecerão aqui.',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
