import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../providers/carrinho_provider.dart';
import '../utils/dialog_utils.dart';
import '../screens/produto_screen.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback? onTap;
  final bool inGrid;

  const ProdutoCard(
      {super.key, required this.produto, this.onTap, this.inGrid = false});

  @override
  Widget build(BuildContext context) {
    final corPrimaria =
        Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    int? descPct;
    if (produto.temPromocao) {
      descPct = ((produto.preco - produto.precoPromocional!) /
              produto.preco *
              100)
          .round();
    }

    return GestureDetector(
      onTap: onTap ??
          () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => ProdutoScreen(produto: produto)),
              ),
      child: Container(
        width: inGrid ? null : 160,
        margin: inGrid ? null : const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: produto.imagemUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: produto.imagemUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 120,
                            color: Colors.grey[100],
                            child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => _semImagem(),
                        )
                      : _semImagem(),
                ),
                if (descPct != null && descPct > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-$descPct%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (produto.temPromocao) ...[
                              Text(
                                'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'R\$ ${produto.precoPromocional!.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: corPrimaria,
                                ),
                              ),
                            ] else
                              Text(
                                'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: corPrimaria),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CarrinhoController.instance.adicionar(produto);
                          DialogUtils.mostrarAdicionadoAoCarrinho(context);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: corPrimaria,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _semImagem() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[100],
      child: const Icon(Icons.medication_outlined,
          size: 40, color: Colors.grey),
    );
  }
}
