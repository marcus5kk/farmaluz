import 'package:flutter/material.dart';
import '../screens/carrinho_screen.dart';

class DialogUtils {
  static void mostrarCarrinhoVazio(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Carrinho vazio'),
        content: const Text('Seu carrinho está vazio.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  static void mostrarAdicionadoAoCarrinho(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 22),
            SizedBox(width: 8),
            Text('Sucesso!', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text('Produto adicionado ao seu carrinho.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Continuar comprando',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CarrinhoScreen()),
              );
            },
            child: const Text('Finalizar compra'),
          ),
        ],
      ),
    );
  }
}
