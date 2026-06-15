import 'produto.dart';

class CarrinhoItem {
  final Produto produto;
  final int quantidade;

  const CarrinhoItem({required this.produto, required this.quantidade});

  CarrinhoItem copyWith({int? quantidade}) => CarrinhoItem(
        produto: produto,
        quantidade: quantidade ?? this.quantidade,
      );
}
