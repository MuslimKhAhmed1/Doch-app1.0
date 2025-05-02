// lib/screens/models_page.dart
import 'package:doch_frontend/Screens/3dModelPage.dart';
import 'package:doch_frontend/service/Service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  late Future<List<ChModel>> _modelsFuture;
  final Map<int, String> _categoryNames = {}; // Cache for category names
  final Map<int, String> _materialNames = {}; // Cache for material names

  // Filter states
  final Set<int> _selectedCategoryIds = {};
  final Set<int> _selectedMaterialIds = {};

  // Predefined categories and materials
  final Map<int, String> _predefinedCategories = {
    1: 'Pottery',
    2: 'Monument',
    3: 'Archaeological Site',
    4: 'Inscription',
  };

  final Map<int, String> _predefinedMaterials = {
    1: 'Stone',
    2: 'Metal',
    3: 'Wood',
    4: 'Ceramic (Pottery)',
    5: 'Ceramic (porcelain)',
    6: 'Textile',
    7: 'Paper',
    8: 'Glass',
  };

  List<ChModel> _allModels = [];
  List<ChModel> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _modelsFuture = _fetchModels();
    _fetchCategories();
    _fetchMaterials();
  }

  Future<List<ChModel>> _fetchModels() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/models'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> models = data['models'];
      _allModels = models.map((json) => ChModel.fromJson(json)).toList();
      _applyFilters(); // Initialize filtered models
      return _allModels;
    } else {
      throw Exception('Failed to load models');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/categories'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> categories = data['categories'];

        setState(() {
          for (var category in categories) {
            _categoryNames[category['id']] = category['name'];
          }

          // If API didn't return categories, use predefined ones
          if (_categoryNames.isEmpty) {
            _categoryNames.addAll(_predefinedCategories);
          }
        });
      } else {
        // Use predefined categories if API call fails
        setState(() {
          _categoryNames.addAll(_predefinedCategories);
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      // Use predefined categories as fallback
      setState(() {
        _categoryNames.addAll(_predefinedCategories);
      });
    }
  }

  Future<void> _fetchMaterials() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/materials'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> materials = data['materials'];

        setState(() {
          for (var material in materials) {
            _materialNames[material['id']] = material['name'];
          }

          // If API didn't return materials, use predefined ones
          if (_materialNames.isEmpty) {
            _materialNames.addAll(_predefinedMaterials);
          }
        });
      } else {
        // Use predefined materials if API call fails
        setState(() {
          _materialNames.addAll(_predefinedMaterials);
        });
      }
    } catch (e) {
      print('Error fetching materials: $e');
      // Use predefined materials as fallback
      setState(() {
        _materialNames.addAll(_predefinedMaterials);
      });
    }
  }

  void _applyFilters() {
    setState(() {
      if (_selectedCategoryIds.isEmpty && _selectedMaterialIds.isEmpty) {
        // If no filters selected, show all models
        _filteredModels = List.from(_allModels);
      } else {
        // Apply filters
        _filteredModels =
            _allModels.where((model) {
              bool passesCategory =
                  _selectedCategoryIds.isEmpty ||
                  (model.categoryId != null &&
                      _selectedCategoryIds.contains(model.categoryId));

              bool passesMaterial =
                  _selectedMaterialIds.isEmpty ||
                  (model.materialId != null &&
                      _selectedMaterialIds.contains(model.materialId));

              return passesCategory && passesMaterial;
            }).toList();
      }
    });
  }

  Future<void> _refreshModels() async {
    setState(() {
      _modelsFuture = _fetchModels();
    });
  }

  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return 'Uncategorized';
    return _categoryNames[categoryId] ?? 'Category $categoryId';
  }

  String _getMaterialName(int? materialId) {
    if (materialId == null) return 'Unknown Material';
    return _materialNames[materialId] ?? 'Material $materialId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshModels,
        child: FutureBuilder<List<ChModel>>(
          future: _modelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[700]),
                    const SizedBox(height: 12),
                    Text(
                      'Error loading models',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshModels,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_from_queue,
                      size: 60,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No models available',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            if (_allModels.isEmpty) {
              _allModels = snapshot.data!;
              _applyFilters();
            }

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3D Models',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  // Category filter chips
                  const Text(
                    'Categories:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  // const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryFilterChips(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Material filter chips
                  const Text(
                    'Materials:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  // const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMaterialFilterChips(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Results count
                  Text(
                    'Found ${_filteredModels.length} models',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),

                  // Grid view of models
                  Expanded(
                    child:
                        _filteredModels.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.filter_list_off,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No models match the selected filters',
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategoryIds.clear();
                                        _selectedMaterialIds.clear();
                                        _applyFilters();
                                      });
                                    },
                                    child: const Text('Clear Filters'),
                                  ),
                                ],
                              ),
                            )
                            : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: _filteredModels.length,
                              itemBuilder: (context, index) {
                                final model = _filteredModels[index];
                                return _buildModelCard(context, model);
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChips() {
    return Wrap(
      spacing: 5.0,
      runSpacing: 5.0,
      children:
          _categoryNames.entries.map((entry) {
            final categoryId = entry.key;
            final categoryName = entry.value;

            return ChoiceChip(
              label: Text(categoryName),
              selected: _selectedCategoryIds.contains(categoryId),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedCategoryIds.add(categoryId);
                  } else {
                    _selectedCategoryIds.remove(categoryId);
                  }
                  _applyFilters();
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey[300],
              labelStyle: TextStyle(
                color:
                    _selectedCategoryIds.contains(categoryId)
                        ? Colors.white
                        : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMaterialFilterChips() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children:
          _materialNames.entries.map((entry) {
            final materialId = entry.key;
            final materialName = entry.value;

            return ChoiceChip(
              label: Text(materialName),
              selected: _selectedMaterialIds.contains(materialId),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedMaterialIds.add(materialId);
                  } else {
                    _selectedMaterialIds.remove(materialId);
                  }
                  _applyFilters();
                });
              },
              selectedColor: Colors.amber[700],
              backgroundColor: Colors.grey[300],
              labelStyle: TextStyle(
                color:
                    _selectedMaterialIds.contains(materialId)
                        ? Colors.white
                        : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildModelCard(BuildContext context, ChModel model) {
    return GestureDetector(
      onTap: () {
        // Navigate to ArtifactDetailPage when clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ArtifactDetailPages(
                  modelId: model.id,
                  siteName: model.name,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Display thumbnail or placeholder
                    model.thumbnail != null && model.thumbnail!.isNotEmpty
                        ? Image.network(
                          '${ApiService.baseUrl}${model.thumbnail}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(model);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        )
                        : _buildPlaceholderImage(model),
                    // Category badge
                    // Positioned(
                    //   top: 8,
                    //   right: 8,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 8,
                    //       vertical: 4,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Theme.of(
                    //         context,
                    //       ).primaryColor.withOpacity(0.8),
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     child: Text(
                    //       _getCategoryName(model.categoryId),
                    //       style: const TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // // Material badge (new)
                    // Positioned(
                    //   top: 50, // Position below category badge
                    //   right: 8,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 8,
                    //       vertical: 4,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.amber[700]?.withOpacity(0.8),
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     child: Text(
                    //       _getMaterialName(model.materialId),
                    //       style: const TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model.currentLocation ?? 'Unknown Location',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildPlaceholderImage(ChModel model) {
    // Get first letter of model name for the placeholder
    final firstLetter =
        model.name.isNotEmpty ? model.name[0].toUpperCase() : '?';

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '3D Model',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Assuming this is used elsewhere in your code or will be implemented later
class ArtifactDetailPage extends StatelessWidget {
  final ChModel modelData;
  final String siteName;

  const ArtifactDetailPage({
    Key? key,
    required this.modelData,
    required this.siteName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(modelData.name)),
      body: Center(child: Text('Artifact Detail Page for ${modelData.name}')),
    );
  }
}

// Model class - assuming it's defined in your code but adding here for completeness
class ChModel {
  final int id;
  final String name;
  final String? description;
  final String? path;
  final String? thumbnail;
  final int? userId;
  final String? originDate;
  final String? originCountry;
  final String? currentLocation;
  final int? categoryId;
  final int? conditionId;
  final int? functionId;
  final int? materialId;
  final int? usageContextId;
  final String? scanningMethod;
  final String? scanDate;
  final String? softwareUsed;
  final String? createdAt;
  final String? updatedAt;

  ChModel({
    required this.id,
    required this.name,
    this.description,
    this.path,
    this.thumbnail,
    this.userId,
    this.originDate,
    this.originCountry,
    this.currentLocation,
    this.categoryId,
    this.conditionId,
    this.functionId,
    this.materialId,
    this.usageContextId,
    this.scanningMethod,
    this.scanDate,
    this.softwareUsed,
    this.createdAt,
    this.updatedAt,
  });

  factory ChModel.fromJson(Map<String, dynamic> json) {
    return ChModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      path: json['path'],
      thumbnail: json['thumbnail'],
      userId: json['user_id'],
      originDate: json['origin_date'],
      originCountry: json['origin_country'],
      currentLocation: json['current_location'],
      categoryId: json['category_id'],
      conditionId: json['condition_id'],
      functionId: json['function_id'],
      materialId: json['material_id'],
      usageContextId: json['usage_context_id'],
      scanningMethod: json['scanning_method'],
      scanDate: json['scan_date'],
      softwareUsed: json['software_used'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
