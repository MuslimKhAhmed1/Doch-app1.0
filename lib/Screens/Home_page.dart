import 'package:doch_frontend/Provider/theme_provider.dart';
import 'package:doch_frontend/Screens/blog_page.dart';
import 'package:doch_frontend/Screens/detailBlog.dart';
import 'package:doch_frontend/Screens/detail_place_screen.dart';
import 'package:doch_frontend/Screens/drawer.dart';
import 'package:doch_frontend/Screens/map_page.dart';
import 'package:doch_frontend/Screens/modelPage.dart';
import 'package:doch_frontend/Screens/place_page.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:doch_frontend/service/Service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doch_frontend/service/blog_service.dart'; // Import the blog service

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  final BlogService _blogService = BlogService();
  bool _showAboutApp = false;
  List<Site> _sites = [];
  List<BlogModel> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sites = await _apiService.fetchSites();
      final blogs = await _blogService.getBlogs();

      setState(() {
        _sites = sites;
        _blogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Display Widget
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.translate('interactive_map') ??
                          'Interactive Map',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Map page (index 1 in BottomNavigationBar)
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => const MainScreen(initialPage: 1),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/cap.JPG'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: () {},
                                child: const Icon(Icons.my_location),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  localizations?.translate('erbil_city') ??
                                      'Erbil City',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3D Model Display Widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.translate('3d_models') ?? '3D Models',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/arr.JPG'),
                          fit: BoxFit.cover,
                        ),
                        color:
                            themeProvider.isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to 3D Models page (index 3 in BottomNavigationBar)
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const MainScreen(initialPage: 3),
                                  ),
                                );
                              },
                              child: Text(
                                localizations?.translate('load_model') ??
                                    'Load Model',
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // About App Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAboutApp = !_showAboutApp;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 3, 90, 105),

                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations?.translate('about_app') ??
                                  'About the App',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.white,
                              ),
                            ),
                            Icon(
                              _showAboutApp
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showAboutApp)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(top: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          localizations?.translate('app_info') ??
                              'About the App',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Popular Places Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations?.translate('popular_place') ??
                              'Popular Place',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to Places page (index 2 in BottomNavigationBar)
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MainScreen(initialPage: 2),
                              ),
                            );
                          },
                          child: Text(
                            localizations?.translate('see_more') ?? 'See more',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sites.isEmpty
                        ? Center(
                          child: Text(
                            localizations?.translate('no_places') ??
                                'No places available',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: _buildPlaceCard(
                                _sites.isNotEmpty ? _sites[0] : null,
                                themeProvider.isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPlaceCard(
                                _sites.length > 1 ? _sites[1] : null,
                                themeProvider.isDarkMode,
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),

              // Blogs Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations?.translate('latest_blogs') ??
                              'Latest Blogs',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to Blogs page (index 4 in BottomNavigationBar)
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MainScreen(initialPage: 4),
                              ),
                            );
                          },
                          child: Text(
                            localizations?.translate('see_all') ?? 'See all',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _blogs.isEmpty
                        ? Center(
                          child: Text(
                            localizations?.translate('no_blogs') ??
                                'No blogs available',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                            ),
                          ),
                        )
                        : SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _blogs.length > 3 ? 3 : _blogs.length,
                            itemBuilder: (context, index) {
                              final blog = _blogs[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < _blogs.length - 1 ? 16.0 : 0,
                                ),
                                child: _buildBlogCard(blog),
                              );
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildPlaceCard(Site? site, bool isDark) {
    if (site == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No place available',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      );
    }

    String imageUrl =
        site.galleries.isNotEmpty ? site.galleries.first.path : '';
    bool hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Navigate to place details
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(siteId: site.id),
          ),
        );
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          image:
              hasImage
                  ? DecorationImage(
                    image: NetworkImage('http://46.101.224.211$imageUrl'),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child: Stack(
          children: [
            // Dark overlay for better text visibility
            if (hasImage)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.name,
                    style: TextStyle(
                      color: hasImage ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    site.city,
                    style: TextStyle(
                      color: hasImage ? Colors.white70 : null,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.bookmark_border,
                color: hasImage ? Colors.white : null,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(BlogModel blog) {
    bool hasImage = blog.image.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Navigate to blog details
        Navigator.of(context).pushNamed('/blog-details', arguments: blog.id);
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image:
              hasImage
                  ? DecorationImage(
                    image: NetworkImage('http://46.101.224.211${blog.image}'),
                    fit: BoxFit.cover,
                  )
                  : null,
          color:
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[200],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                blog.author,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              // Text(
              //   '${blog.date} · ${blog.readTime}',
              //   style: const TextStyle(fontSize: 12, color: Colors.white60),
              // ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to blog details
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlogDetailPage(blog: blog),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('read_more') ??
                          'Read more',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Update MainScreen to accept an initialPage parameter
class MainScreen extends StatefulWidget {
  final int initialPage;

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color.fromARGB(255, 3, 90, 105),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color.fromARGB(255, 3, 90, 105),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(backgroundColor: Colors.grey[900], elevation: 0),
  );

  const MainScreen({super.key, this.initialPage = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const PlacePage(),
    const ModelsPage(),
    const BlogsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 3, 90, 105),
        toolbarHeight: 60,
        title: Text(
          localizations?.translate('app_name') ?? 'DoCH Mobile App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
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
