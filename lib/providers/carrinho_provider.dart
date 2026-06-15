import 'package:flutter/foundation.dart';
import '../models/carrinho_item.dart';
import '../models/produto.dart';

class CarrinhoController {
  CarrinhoController._();
  static final CarrinhoController instance = CarrinhoController._();

  final ValueNotifier<List<CarrinhoItem>> items = ValueNotifier([]);

  void adicionar(Produto produto, {int quantidade = 1}) {
    final lista = List<CarrinhoItem>.from(items.value);
    final idx = lista.indexWhere((e) => e.produto.id == produto.id);
    if (idx >= 0) {
      lista[idx] = lista[idx].copyWith(quantidade: lista[idx].quantidade + quantidade);
    } else {
      lista.add(CarrinhoItem(produto: produto, quantidade: quantidade));
    }
    items.value = lista;
  }

  void aumentar(int produtoId) {
    final lista = List<CarrinhoItem>.from(items.value);
    final idx = lista.indexWhere((e) => e.produto.id == produtoId);
    if (idx >= 0) {
      lista[idx] = lista[idx].copyWith(quantidade: lista[idx].quantidade + 1);
      items.value = lista;
    }
  }

  void diminuir(int produtoId) {
    final lista = List<CarrinhoItem>.from(items.value);
    final idx = lista.indexWhere((e) => e.produto.id == produtoId);
    if (idx >= 0) {
      if (lista[idx].quantidade > 1) {
        lista[idx] = lista[idx].copyWith(quantidade: lista[idx].quantidade - 1);
      } else {
        lista.removeAt(idx);
      }
      items.value = lista;
    }
  }

  void remover(int produtoId) {
    items.value = items.value.where((e) => e.produto.id != produtoId).toList();
  }

  int get totalTipos => items.value.length;

  int get totalItens => items.value.fold(0, (sum, e) => sum + e.quantidade);

  double get subtotal =>
      items.value.fold(0.0, (sum, e) => sum + e.produto.preco * e.quantidade);

  double get total =>
      items.value.fold(0.0, (sum, e) => sum + e.produto.precoAtual * e.quantidade);

  double get economia => subtotal - total;
}
