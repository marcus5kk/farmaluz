class BannerItem {
  final int id;
  final String imagem;
  final String? link;
  final int ordem;

  BannerItem({
    required this.id,
    required this.imagem,
    this.link,
    this.ordem = 0,
  });

  String get imagemUrl => 'https://api.appfarmacias.com.br/uploads/banners/$imagem';

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: int.parse(json['id'].toString()),
      imagem: json['imagem'] ?? '',
      link: json['link'],
      ordem: int.parse((json['ordem'] ?? 0).toString()),
    );
  }
}
