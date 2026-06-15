import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../providers/app_nav.dart';
import 'home_screen.dart';
import 'categorias_screen.dart';
import 'ofertas_screen.dart';
import 'pedidos_screen.dart';
import 'perfil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _telas = const [
    HomeScreen(),
    CategoriasScreen(),
    OfertasScreen(),
    PedidosScreen(),
    PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AppNav.register((i) => setState(() => _index = i));
  }

  @override
  Widget build(BuildContext context) {
    final corPrimaria =
        Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    return Scaffold(
      body: IndexedStack(index: _index, children: _telas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: corPrimaria,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Categorias'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer),
              label: 'Ofertas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Pedidos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}
