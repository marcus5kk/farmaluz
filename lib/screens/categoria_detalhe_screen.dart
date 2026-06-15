import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/categoria.dart';
import '../models/subcategoria.dart';
import '../services/api_service.dart';
import 'produtos_lista_screen.dart';

class CategoriaDetalheScreen extends StatefulWidget {
  final Categoria categoria;
  const CategoriaDetalheScreen({super.key, required this.categoria});

  @override
  State<CategoriaDetalheScreen> createState() =>
      _CategoriaDetalheScreenState();
}

class _CategoriaDetalheScreenState extends State<CategoriaDetalheScreen> {
  List<Subcategoria> _subcategorias = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final subs =
        await ApiService.getSubcategoriasPorCategoria(widget.categoria.id);
    if (mounted) {
      setState(() {
        _subcategorias = subs;
        _carregando = false;
      });
    }
  }

  void _abrirLista({String? titulo, int? subcategoriaId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProdutosListaScreen(
          titulo: titulo ?? 'Produtos',
          categoriaId:
              subcategoriaId == null ? widget.categoria.id : null,
          subcategoriaId: subcategoriaId,
        ),
      ),
    );
  }

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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        widget.categoria.nome,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
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
          if (_carregando)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                children: [
                  _itemLista(
                    titulo: 'Todos os produtos',
                    quantidade: widget.categoria.totalProdutos,
                    onTap: () => _abrirLista(
                        titulo:
                            'Todos os produtos – ${widget.categoria.nome}'),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ..._subcategorias
                      .map((sub) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _itemLista(
                                titulo: sub.nome,
                                quantidade: sub.totalProdutos,
                                onTap: () => _abrirLista(
                                    titulo: sub.nome,
                                    subcategoriaId: sub.id),
                              ),
                              const Divider(
                                  height: 1,
                                  color: Color(0xFFEEEEEE)),
                            ],
                          ))
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _itemLista(
      {required String titulo,
      required int quantidade,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222))),
                  const SizedBox(height: 2),
                  Text(
                      '$quantidade produto${quantidade != 1 ? 's' : ''}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
