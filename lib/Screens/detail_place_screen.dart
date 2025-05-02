// lib/screens/place_detail_page.dart
import 'package:doch_frontend/Provider/theme_provider.dart';
import 'package:doch_frontend/Screens/3dModelPage.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:doch_frontend/service/Service.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailPage extends StatefulWidget {
  final int siteId;

  const PlaceDetailPage({Key? key, required this.siteId}) : super(key: key);

  @override
  _PlaceDetailPageState createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;
  final ApiService _apiService = ApiService();
  Site? _site;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSiteDetails();
  }

  Future<void> _loadSiteDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final site = await _apiService.fetchSiteById(widget.siteId);
      setState(() {
        _site = site;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load site details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDarkMode;
    final String baseUrl = 'http://192.168.1.234:8080';
    // final String baseUrl = 'http://127.0.0.1:8000';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 3, 90, 105),
          title: Text('Loading...'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 3, 90, 105),
          title: Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    final site = _site!;
    final List<String> imageUrls =
        site.galleries.map((gallery) => baseUrl + gallery.path).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            AppBar(
              centerTitle: true,
              toolbarHeight: 65,

              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 3, 90, 105),
              title: Text(
                site.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              ],
            ),
            // Image Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  items:
                      imageUrls.isEmpty
                          ? [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          ]
                          : imageUrls.map((imageUrl) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color:
                                            isDark
                                                ? Colors.grey[800]
                                                : Colors.grey[200],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }).toList(),
                ),
                if (imageUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          imageUrls.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  _currentImageIndex == entry.key ? 0.9 : 0.4,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text:
                      localizations?.translate('information') ?? 'Information',
                ),
                Tab(text: localizations?.translate('3d_models') ?? '3D models'),
              ],
              labelColor: isDark ? Colors.white : Colors.black,
              unselectedLabelColor:
                  isDark ? Colors.white60 : Colors.black.withOpacity(0.5),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Information Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoCard(
                          title: site.city,
                          icon: Icons.location_city,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        InfoCard(
                          title: site.siteType.name,
                          icon: Icons.category,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        if (site.phone1 != null)
                          InfoCard(
                            title: site.phone1!,
                            icon: Icons.phone,
                            isDark: isDark,
                          ),
                        if (site.phone1 != null) const SizedBox(height: 12),
                        if (site.email != null)
                          InfoCard(
                            title: site.email!,
                            icon: Icons.email,
                            isDark: isDark,
                          ),
                        if (site.email != null) const SizedBox(height: 12),
                        if (site.externalLink != null)
                          GestureDetector(
                            onTap: () => _launchURL(site.externalLink!),
                            child: InfoCard(
                              title: 'View on Maps',
                              icon: Icons.map,
                              isDark: isDark,
                            ),
                          ),
                        if (site.externalLink != null)
                          const SizedBox(height: 12),

                        // Opening Hours Section
                        if (site.openHours.isNotEmpty) ...[
                          Text(
                            'Opening Hours',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...site.openHours
                              .map(
                                (hour) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        hour.day,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        '${hour.openingTime.substring(0, 5)} - ${hour.closingTime.substring(0, 5)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          const SizedBox(height: 16),
                        ],

                        // Description Section
                        Text(
                          site.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          site.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),

                        // Location Info
                        const SizedBox(height: 16),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Latitude: ${site.latitude}, Longitude: ${site.longitude}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 3D Models Tab - Updated to display actual models from the site
                  site.chModels.isEmpty
                      ? Center(
                        child: Text(
                          'No 3D models available for this site',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: site.chModels.length,
                        itemBuilder: (context, index) {
                          final model = site;
                          final ChModel chModel = site.chModels[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ArtifactDetailPages(
                                        siteName: site.name,
                                        modelId: index,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ModelCard(
                                title: chModel.name.toString(),
                                subtitle: chModel.description.toString(),
                                // Use thumbnail if available, otherwise use a placeholder
                                imageUrl:
                                    chModel.thumbnail != null &&
                                            chModel.thumbnail != "/storage/"
                                        ? "assets/arr.JPG"!
                                        : null,
                                isDark: isDark,
                                isNetworkImage:
                                    site.galleries[1] != null &&
                                    site.galleries[1] != "/storage/",
                              ),
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const InfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class ModelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool isDark;
  final bool isNetworkImage;

  const ModelCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.isDark,
    this.isNetworkImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              image:
                  imageUrl != null
                      ? DecorationImage(
                        image:
                            isNetworkImage
                                ? NetworkImage(imageUrl!)
                                : AssetImage(imageUrl!) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                      : null,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            child:
                imageUrl == null
                    ? Center(
                      child: Icon(
                        Icons.view_in_ar,
                        size: 30,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
