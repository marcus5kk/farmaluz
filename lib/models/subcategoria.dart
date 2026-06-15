class Subcategoria {
  final int id;
  final int idCategoria;
  final String nome;
  final String? icone;
  final int totalProdutos;

  Subcategoria({
    required this.id,
    required this.idCategoria,
    required this.nome,
    this.icone,
    this.totalProdutos = 0,
  });

  String get iconeUrl {
    if (icone == null || icone!.isEmpty) return '';
    return 'https://api.appfarmacias.com.br/uploads/categorias/$icone';
  }

  factory Subcategoria.fromJson(Map<String, dynamic> json) {
    return Subcategoria(
      id: int.parse(json['id'].toString()),
      idCategoria: int.parse(json['id_categoria'].toString()),
      nome: json['nome'] ?? '',
      icone: json['icone'],
      totalProdutos:
          int.tryParse((json['total_produtos'] ?? 0).toString()) ?? 0,
    );
  }
}
