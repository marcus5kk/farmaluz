import 'package:flutter/foundation.dart';
import '../models/produto.dart';

class FavoritosController {
  FavoritosController._();
  static final FavoritosController instance = FavoritosController._();

  final ValueNotifier<List<Produto>> items = ValueNotifier([]);

  bool isFavorito(int produtoId) =>
      items.value.any((e) => e.id == produtoId);

  void toggle(Produto produto) {
    final lista = List<Produto>.from(items.value);
    final idx = lista.indexWhere((e) => e.id == produto.id);
    if (idx >= 0) {
      lista.removeAt(idx);
    } else {
      lista.add(produto);
    }
    items.value = lista;
  }

  void remover(int produtoId) {
    items.value = items.value.where((e) => e.id != produtoId).toList();
  }
}
