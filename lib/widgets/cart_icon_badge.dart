import 'package:flutter/material.dart';
import '../providers/carrinho_provider.dart';
import '../models/carrinho_item.dart';

class CartIconBadge extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;

  const CartIconBadge({super.key, this.color = Colors.white, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CarrinhoItem>>(
      valueListenable: CarrinhoController.instance.items,
      builder: (context, _, __) {
        final count = CarrinhoController.instance.totalTipos;
        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart_outlined, color: color, size: 26),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
