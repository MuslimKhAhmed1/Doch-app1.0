// lib/screens/main_screen.dart
import 'package:doch_frontend/Screens/3dModelPage.dart';
import 'package:doch_frontend/Screens/blog_page.dart';
import 'package:doch_frontend/Screens/drawer.dart';
import 'package:doch_frontend/Screens/moodel.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'place_page.dart';
import 'modelPage.dart';

class MainScreen extends StatefulWidget {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color.fromARGB(255, 3, 90, 105),

    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0x00035a69),
      elevation: 0,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0x00035a69),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(backgroundColor: Color(0x00035a69), elevation: 0),
  );

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MapPage(),
    PlacePage(),
    ModelsPage(),
    BlogsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 3, 90, 105),
        toolbarHeight: 70,
        title: Text(
          localizations?.translate('app_name') ?? 'DoCH Mobile App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArtifactDetail()),
              );
            },
            icon: Icon(Icons.abc),
          ),
        ],
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 3, 63, 73),
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations?.translate('home') ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: localizations?.translate('map') ?? 'Map',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.museum),
            label: localizations?.translate('place') ?? 'Place',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.threed_rotation),
            label: localizations?.translate('3D model') ?? '3D model',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article),
            label: localizations?.translate('Blog') ?? 'Blog',
          ),
        ],
      ),
    );
  }
}
