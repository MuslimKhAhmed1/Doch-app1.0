// import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:doch_frontend/service/Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class City {
  final String name;
  final double latitude;
  final double longitude;
  final IconData icon;

  City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.icon = Icons.location_city,
  });
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapController = MapController();
  LatLng center = const LatLng(36.1911, 44.0090);
  bool showControls = true;
  LatLng? userLocation;
  LatLng? selectedSite;
  String searchQuery = '';
  bool showSearchResults = false;
  ApiService apiService = ApiService();

  // Add this method to your _MapPageState class
  int? _getValidSiteId() {
    if (sites.isEmpty) return null;
    if (selectedSiteId == null) return sites.first.id;
    bool siteExists = sites.any((site) => site.id == selectedSiteId);
    return siteExists ? selectedSiteId : sites.first.id;
  }

  // City data with icons
  final List<City> kurdistanCities = [
    City(
      name: 'Erbil',
      latitude: 36.1911,
      longitude: 44.0090,
      icon: Icons.location_on,
    ),
    City(
      name: 'Sulaymaniyah',
      latitude: 35.5649,
      longitude: 45.4329,
      icon: Icons.location_on,
    ),
    City(
      name: 'Duhok',
      latitude: 36.8663,
      longitude: 42.9886,
      icon: Icons.location_on,
    ),
    City(
      name: 'Halabja',
      latitude: 35.1776,
      longitude: 45.9861,
      icon: Icons.location_on,
    ),
  ];

  String selectedCity = 'Erbil';
  int? selectedSiteId;
  List<Site> sites = [];
  List<Site> filteredSites = [];
  List<Marker> siteMarkers = [];

  @override
  void initState() {
    super.initState();
    fetchSites();
  }

  Future<void> fetchSites() async {
    try {
      final fetchedSites = await apiService.fetchSites();

      setState(() {
        sites = fetchedSites;
        filteredSites = sites;

        // Only set selectedSiteId if there are sites and it's null
        if (sites.isNotEmpty && selectedSiteId == null) {
          selectedSiteId = sites.first.id;
        }

        updateSiteMarkers();
      });
    } catch (e) {
      print('Error fetching sites: $e');
      // ScaffoldMessenger.of(
      //   // ignore: use_build_context_synchronously
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Failed to load sites: $e')));
    }
  }

  void updateSiteMarkers() {
    setState(() {
      siteMarkers =
          sites.map((site) {
            return Marker(
              point: LatLng(site.latitude, site.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  showSiteDetails(site);
                },
                child: Icon(
                  getIconForSiteType(site.typeId),
                  color:
                      selectedSiteId == site.name
                          ? Colors.red
                          : Colors.grey[800],
                  size: selectedSiteId == site.name ? 35 : 30,
                ),
              ),
            );
          }).toList();

      // Add city markers
      siteMarkers.addAll(
        kurdistanCities.map((city) {
          return Marker(
            point: LatLng(city.latitude, city.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCity = city.name;
                  mapController.move(LatLng(city.latitude, city.longitude), 13);
                });
              },
              child: Icon(
                city.icon,
                color: selectedCity == city.name ? Colors.blue : Colors.green,
                size: selectedCity == city.name ? 35 : 30,
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  IconData getIconForSiteType(int typeId) {
    switch (typeId) {
      case 1:
        return Icons.museum;
      case 2:
        return Icons.museum;
      case 3:
        return Icons.museum;
      case 4:
        return Icons.location_city;
      default:
        return Icons.place;
    }
  }

  void showSiteDetails(Site site) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  site.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(site.description),
                if (site.phone1 != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18),
                      const SizedBox(width: 5),
                      Text(site.phone1!),
                    ],
                  ),
                ],
                if (site.email != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 18),
                      const SizedBox(width: 5),
                      Text(site.email!),
                    ],
                  ),
                ],
              ],
            ),
          ),
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                      context,
                    )?.translate('location_permission_denied') ??
                    'Location permissions are denied',
              ),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  )?.translate('location_permission_permanently_denied') ??
                  'Location permissions are permanently denied',
            ),
            action: SnackBarAction(
              label:
                  AppLocalizations.of(context)?.translate('settings') ??
                  'Settings',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        mapController.move(userLocation!, 15);
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('location_error') ??
                'Could not get location',
          ),
        ),
      );
    }
  }

  void filterSites(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSites = sites;
        showSearchResults = false;
      } else {
        filteredSites =
            sites
                .where(
                  (site) =>
                      site.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
        showSearchResults = true;
      }
    });
  }

  void selectSite(Site site) {
    setState(() {
      selectedSiteId = site.id;
      selectedSiteId = site.id;
      showSearchResults = false;
      mapController.move(LatLng(site.latitude, site.longitude), 15);
      updateSiteMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: (_, __) {
                if (showControls) {
                  setState(() {
                    showControls = false;
                    showSearchResults = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    isDarkMode
                        ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png"
                        : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: siteMarkers),
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              mini: false,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              child: Icon(
                showControls ? Icons.close : Icons.search,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  showControls = !showControls;
                  showSearchResults = false;
                });
              },
            ),
          ),

          if (showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(
                                      context,
                                    )?.translate('search') ??
                                    'search',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              onChanged: filterSites,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showSearchResults && filteredSites.isNotEmpty)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.builder(
                          itemCount: filteredSites.length,
                          itemBuilder: (context, index) {
                            final site = filteredSites[index];
                            return ListTile(
                              leading: Icon(
                                getIconForSiteType(site.typeId),
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              title: Text(
                                site.name,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                site.city,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                ),
                              ),
                              onTap: () => selectSite(site),
                            );
                          },
                        ),
                      ),
                    if (!showSearchResults)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCity,
                                      isExpanded: true,
                                      dropdownColor:
                                          isDarkMode ? Colors.grey[800] : null,
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      items:
                                          kurdistanCities.map((City city) {
                                            return DropdownMenuItem(
                                              value: city.name,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    city.icon,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(city.name),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            selectedCity = value;
                                            final selectedCityObj =
                                                kurdistanCities.firstWhere(
                                                  (city) => city.name == value,
                                                );
                                            mapController.move(
                                              LatLng(
                                                selectedCityObj.latitude,
                                                selectedCityObj.longitude,
                                              ),
                                              13,
                                            );
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Replace the site dropdown section in your code with this:
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child:
                                      sites.isEmpty
                                          ? Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                  ),
                                              child: FittedBox(
                                                child: Text(
                                                  'Loading sites...',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          : DropdownButtonHideUnderline(
                                            child: DropdownButton<int>(
                                              value: _getValidSiteId(),
                                              isExpanded: true,
                                              dropdownColor:
                                                  isDarkMode
                                                      ? Colors.grey[800]
                                                      : null,
                                              style: TextStyle(
                                                color:
                                                    isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                              hint: FittedBox(
                                                child: Text(
                                                  AppLocalizations.of(
                                                        context,
                                                      )?.translate(
                                                        'select_site',
                                                      ) ??
                                                      'Select site',
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                              items:
                                                  sites.map((Site site) {
                                                    return DropdownMenuItem<
                                                      int
                                                    >(
                                                      value: site.id,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            getIconForSiteType(
                                                              site.typeId,
                                                            ),
                                                            color:
                                                                isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          FittedBox(
                                                            child: Text(
                                                              site.name,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    selectedSiteId = value;
                                                    final selectedSiteObj =
                                                        sites.firstWhere(
                                                          (site) =>
                                                              site.id == value,
                                                        );
                                                    mapController.move(
                                                      LatLng(
                                                        selectedSiteObj
                                                            .latitude,
                                                        selectedSiteObj
                                                            .longitude,
                                                      ),
                                                      15,
                                                    );
                                                    selectedSiteId =
                                                        selectedSiteObj
                                                            .id; // Optional: for UI display
                                                    updateSiteMarkers();
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: showControls ? 10 : 10,
            left: 10,
            child: FloatingActionButton(
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              onPressed: getCurrentLocation,
              child: Icon(
                Icons.my_location,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
