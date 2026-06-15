import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../providers/carrinho_provider.dart';
import '../models/carrinho_item.dart';

class CarrinhoScreen extends StatelessWidget {
  const CarrinhoScreen({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Meu Carrinho',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<CarrinhoItem>>(
              valueListenable: CarrinhoController.instance.items,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Seu carrinho está vazio',
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Meu carrinho de produtos',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222)),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: items.length,
                        itemBuilder: (context, i) =>
                            _itemCard(context, items[i], corPrimaria),
                      ),
                    ),
                    _rodape(corPrimaria),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(
      BuildContext context, CarrinhoItem item, Color corPrimaria) {
    final p = item.produto;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: p.imagemUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: p.imagemUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _semImagem(),
                  )
                : _semImagem(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333)),
                ),
                const SizedBox(height: 4),
                if (p.temPromocao) ...[
                  Text(
                    'R\$ ${p.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough),
                  ),
                  Text(
                    'R\$ ${p.precoPromocional!.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: corPrimaria),
                  ),
                ] else
                  Text(
                    'R\$ ${p.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: corPrimaria),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _btnQtd(Icons.remove,
                        () => CarrinhoController.instance.diminuir(p.id),
                        corPrimaria),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantidade}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                    _btnQtd(Icons.add,
                        () => CarrinhoController.instance.aumentar(p.id),
                        corPrimaria),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnQtd(IconData icon, VoidCallback onTap, Color cor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: cor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: cor),
      ),
    );
  }

  Widget _semImagem() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey[100],
      child: const Icon(Icons.medication_outlined, size: 28, color: Colors.grey),
    );
  }

  Widget _rodape(Color corPrimaria) {
    return ValueListenableBuilder<List<CarrinhoItem>>(
      valueListenable: CarrinhoController.instance.items,
      builder: (context, items, _) {
        final c = CarrinhoController.instance;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4))
            ],
          ),
          child: Column(
            children: [
              _linhaResumo('Subtotal', c.subtotal),
              if (c.economia > 0.01)
                _linhaResumo('Você economiza', c.economia,
                    cor: Colors.green[700]!),
              const Divider(height: 16),
              _linhaResumo('Total', c.total, bold: true),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corPrimaria,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Continuar',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _linhaResumo(String label, double valor,
      {bool bold = false, Color? cor}) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: cor ?? (bold ? const Color(0xFF222222) : Colors.grey[700]),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
              'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
              style: style),
        ],
      ),
    );
  }
}
