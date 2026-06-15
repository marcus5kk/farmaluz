class Produto {
  final int id;
  final String nome;
  final String? descricao;
  final double preco;
  final double? precoPromocional;
  final int estoque;
  final String? imagem;
  final String? codigoBarras;
  final int? idCategoria;
  final String? categoriaNome;

  Produto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    this.precoPromocional,
    required this.estoque,
    this.imagem,
    this.codigoBarras,
    this.idCategoria,
    this.categoriaNome,
  });

  bool get temPromocao => precoPromocional != null && precoPromocional! > 0 && precoPromocional! < preco;

  double get precoAtual => temPromocao ? precoPromocional! : preco;

  String get imagemUrl {
    if (imagem == null || imagem!.isEmpty) return '';
    return '${_baseUrl}/uploads/produtos/$imagem';
  }

  static const String _baseUrl = 'https://api.appfarmacias.com.br';

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      preco: double.parse((json['preco'] ?? 0).toString()),
      precoPromocional: json['preco_promocional'] != null
          ? double.tryParse(json['preco_promocional'].toString())
          : null,
      estoque: int.parse((json['estoque'] ?? 0).toString()),
      imagem: json['imagem'],
      codigoBarras: json['codigo_barras'],
      idCategoria: json['id_categoria'] != null
          ? int.tryParse(json['id_categoria'].toString())
          : null,
      categoriaNome: json['categoria_nome'],
    );
  }
}
