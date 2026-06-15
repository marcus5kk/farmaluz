import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../providers/favoritos_provider.dart';
import 'produto_screen.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Favoritos',
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
            child: ValueListenableBuilder<List<Produto>>(
              valueListenable: FavoritosController.instance.items,
              builder: (context, favoritos, _) {
                if (favoritos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Nenhum favorito ainda',
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 275,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: favoritos.length,
                  itemBuilder: (context, i) =>
                      _favoritoCard(context, favoritos[i], corPrimaria),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoritoCard(
      BuildContext context, Produto p, Color corPrimaria) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProdutoScreen(produto: p))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: p.imagemUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: p.imagemUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _semImagem(),
                    )
                  : _semImagem(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                p.nome,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: OutlinedButton(
                  onPressed: () =>
                      FavoritosController.instance.remover(p.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Remover dos favoritos',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _semImagem() {
    return Container(
      height: 130,
      width: double.infinity,
      color: Colors.grey[100],
      child: const Icon(Icons.medication_outlined,
          size: 40, color: Colors.grey),
    );
  }
}
