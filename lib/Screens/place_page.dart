// lib/screens/place_page.dart
import 'package:doch_frontend/Provider/theme_provider.dart';
import 'package:doch_frontend/Screens/detail_place_screen.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:doch_frontend/service/Service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({super.key});

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  final ApiService _apiService = ApiService();
  List<Site> _sites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final sites = await _apiService.fetchSites();
      setState(() {
        _sites = sites;
        _isLoading = false;
      });
    } catch (e) {
      _errorMessage = 'Failed to load sites: $e';
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPlaces() async {
    return _loadSites();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDarkMode;

    return Column(
      children: [
        // Header Image and Title
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            image: DecorationImage(
              image: AssetImage('assets/citadel.jpeg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  localizations?.translate('places') ?? 'Places',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Places List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshPlaces,
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _sites.length,
                      itemBuilder: (context, index) {
                        final site = _sites[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: PlaceListCard(site: site, isDark: isDark),
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }
}

class PlaceListCard extends StatelessWidget {
  final Site site;
  final bool isDark;

  const PlaceListCard({super.key, required this.site, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Get the base URL for images (removing the "/storage" part since your API likely prepends it)
    String baseUrl = 'http://46.101.224.211';
    String? imageUrl =
        site.galleries.isNotEmpty ? site.galleries[0].path : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(siteId: site.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Place Image
              Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.grey[700] : Colors.grey[200],
                ),
                child:
                    imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            baseUrl + imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color:
                                      isDark ? Colors.white54 : Colors.black38,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                          ),
                        )
                        : Center(
                          child: Icon(
                            Icons.photo_library,
                            color: isDark ? Colors.white54 : Colors.black38,
                          ),
                        ),
              ),
              SizedBox(width: 16),
              // Place Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            site.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.bookmark_border),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    ...[
                      SizedBox(height: 4),
                      Text(
                        site.siteType.name,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            site.city,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.add,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class RatingStars extends StatelessWidget {
//   final double rating;

//   const RatingStars({Key? key, required this.rating}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: List.generate(5, (index) {
//         final starValue = index + 1;
//         final isHalf = rating > index && rating < starValue;
//         final isFull = rating >= starValue;

//         return Icon(
//           isFull
//               ? Icons.star
//               : isHalf
//               ? Icons.star_half
//               : Icons.star_border,
//           size: 16,
//           color: Colors.amber,
//         );
//       }),
//     );
//   }
// }
