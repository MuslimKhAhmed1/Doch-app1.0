import 'package:doch_frontend/Provider/theme_provider.dart';
import 'package:doch_frontend/home_screen.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static var darkTheme = ThemeData.dark();

  static var lightTheme = ThemeData.light();

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Custom theme classes
  static final ThemeData lightTheme = ThemeData(
    primaryColorDark: Color.fromARGB(255, 3, 90, 105),
    primaryColorLight: Color.fromARGB(255, 3, 90, 105),
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[100],
    iconTheme: IconThemeData(color: Color.fromARGB(255, 3, 90, 105)),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      foregroundColor: Colors.white,
      backgroundColor: Color.fromARGB(255, 3, 90, 105),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      // cardColor: Colors.white,
    ),
  );
  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      iconTheme: IconThemeData(color: Color.fromARGB(255, 3, 90, 105)),
      foregroundColor: Colors.white,
      backgroundColor: Color.fromARGB(255, 3, 90, 105),
    ),
    primaryColorDark: Color.fromARGB(255, 3, 90, 105),
    primaryColorLight: Color.fromARGB(255, 3, 90, 105),
    scaffoldBackgroundColor: Colors.grey[900],
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      // cardColor: Colors.grey[800],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.isDarkMode ? darkTheme : lightTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text(AppLocalizations.of(context)?.translate('home') ?? 'Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomeFake()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Top 10 Places',
              context: context,
              theme: currentTheme,
            ),
            _buildHorizontalPlaceList(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.translate('popular_places') ??
                        'Popular Places',
                    style: currentTheme.textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      AppLocalizations.of(context)?.translate('see_more') ??
                          'See more',
                      style: TextStyle(color: currentTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            _buildVerticalPlaceList(),
            _buildCategorySection(
              title: 'Best places for shopping',
              theme: currentTheme,
              context: context,
            ),
            _buildCategorySection(
              title: 'Best Place for a drink',
              theme: currentTheme,
              context: context,
            ),
            _buildCategorySection(
              title: 'Food',
              theme: currentTheme,
              context: context,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)?.translate('home') ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: AppLocalizations.of(context)?.translate('map') ?? 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label:
                AppLocalizations.of(context)?.translate('places') ?? 'Places',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label:
                AppLocalizations.of(context)?.translate('camera') ?? 'Camera',
          ),
        ],
        selectedItemColor: currentTheme.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required BuildContext context,
    required ThemeData theme,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        AppLocalizations.of(context)?.translate(title.toLowerCase()) ?? title,
        style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
      ),
    );
  }

  Widget _buildHorizontalPlaceList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder:
            (context, index) => _buildPlaceItem(
              title: 'ERbit Citadel ${index + 1}',
              location: 'Kurdistan',
              imageUrl: 'https://picsum.photos/200',
            ),
      ),
    );
  }

  Widget _buildVerticalPlaceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder:
          (context, index) => _buildVerticalPlaceItem(
            title: 'Historical Place ${index + 1}',
            description: 'Ancient heritage site',
            imageUrl: 'https://picsum.photos/200',
          ),
    );
  }

  Widget _buildPlaceItem({
    required String title,
    required String location,
    required String imageUrl,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: theme.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Image.network(imageUrl, fit: BoxFit.cover)),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  SizedBox(height: 4),
                  Text(location, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalPlaceItem({
    required String title,
    required String description,
    required String imageUrl,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(description, style: theme.textTheme.bodySmall),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required ThemeData theme,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.translate(title.toLowerCase()) ??
                title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// // Updated ThemeProvider
// class ThemeProvider with ChangeNotifier {
//   bool _isDarkMode = false;

//   bool get isDarkMode => _isDarkMode;

//   ThemeData get themeData =>
//       _isDarkMode ? HomeScreen.darkTheme : HomeScreen.lightTheme;

//   void toggleTheme() {
//     _isDarkMode = !_isDarkMode;
//     notifyListeners();
//   }
// }
