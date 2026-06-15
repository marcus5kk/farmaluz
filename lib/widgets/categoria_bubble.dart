import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_config.dart';
import '../models/categoria.dart';

class CategoriaBubble extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback? onTap;

  const CategoriaBubble({super.key, required this.categoria, this.onTap});

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    return GestureDetector(
      onTap: onTap,
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
                border: Border.all(color: corPrimaria.withOpacity(0.3), width: 1.5),
              ),
              child: ClipOval(
                child: categoria.iconeUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: categoria.iconeUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _iconePadrao(corPrimaria),
                        errorWidget: (_, __, ___) => _iconePadrao(corPrimaria),
                      )
                    : _iconePadrao(corPrimaria),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              categoria.nome,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF444444)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconePadrao(Color cor) {
    return Icon(Icons.category_outlined, color: cor, size: 28);
  }
}
