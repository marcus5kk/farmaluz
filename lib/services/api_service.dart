import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/produto.dart';
import '../models/categoria.dart';
import '../models/banner_item.dart';
import '../models/subcategoria.dart';

class ApiService {
  static final String _base = AppConfig.apiBaseUrl;
  static final String _farmaciaId = AppConfig.farmaciaId.toString();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'farmacia-id': _farmaciaId,
      };

  static Future<Map<String, dynamic>?> getFarmacia() async {
    try {
      final res =
          await http.get(Uri.parse('$_base/farmacia'), headers: _headers);
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<List<Categoria>> getCategorias() async {
    try {
      final res =
          await http.get(Uri.parse('$_base/categorias'), headers: _headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Categoria.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Subcategoria>> getSubcategorias() async {
    try {
      final res = await http.get(
          Uri.parse('$_base/subcategorias'), headers: _headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Subcategoria.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Subcategoria>> getSubcategoriasPorCategoria(
      int categoriaId) async {
    try {
      final uri = Uri.parse('$_base/subcategorias')
          .replace(queryParameters: {'categoria_id': categoriaId.toString()});
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Subcategoria.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<BannerItem>> getBanners() async {
    try {
      final res =
          await http.get(Uri.parse('$_base/banners'), headers: _headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => BannerItem.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Produto>> getProdutos({
    String? busca,
    int? categoria,
    int? subcategoria,
    bool destaques = false,
    bool ofertas = false,
    String? codigoBarras,
  }) async {
    try {
      final params = <String, String>{};
      if (busca != null && busca.isNotEmpty) params['busca'] = busca;
      if (categoria != null) params['categoria'] = categoria.toString();
      if (subcategoria != null)
        params['subcategoria'] = subcategoria.toString();
      if (destaques) params['destaques'] = '1';
      if (ofertas) params['ofertas'] = '1';
      if (codigoBarras != null && codigoBarras.isNotEmpty)
        params['codigo_barras'] = codigoBarras;
      final uri =
          Uri.parse('$_base/produtos').replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Produto.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> login(
      String email, String senha) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/clientes/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'senha': senha}),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String? telefone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/clientes'),
        headers: _headers,
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          if (telefone != null) 'telefone': telefone
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201)
        return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<void> salvarSessao(
      String token, Map<String, dynamic> cliente) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token_cliente', token);
    await prefs.setString('nome_cliente', cliente['nome'] ?? '');
    await prefs.setString('email_cliente', cliente['email'] ?? '');
    await prefs.setInt(
        'id_cliente', int.tryParse(cliente['id'].toString()) ?? 0);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token_cliente');
    await prefs.remove('nome_cliente');
    await prefs.remove('email_cliente');
    await prefs.remove('id_cliente');
  }

  static Future<bool> estaLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('token_cliente') ?? '').isNotEmpty;
  }

  static Future<String?> getNomeCliente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nome_cliente');
  }

  static Future<String?> getEmailCliente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email_cliente');
  }
}
