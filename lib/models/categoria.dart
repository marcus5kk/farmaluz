class Categoria {
  final int id;
  final String nome;
  final String? icone;
  final int totalProdutos;

  Categoria({
    required this.id,
    required this.nome,
    this.icone,
    this.totalProdutos = 0,
  });

  String get iconeUrl {
    if (icone == null || icone!.isEmpty) return '';
    return 'https://api.appfarmacias.com.br/uploads/categorias/$icone';
  }

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
      icone: json['icone'],
      totalProdutos: int.parse((json['total_produtos'] ?? 0).toString()),
    );
  }
}
