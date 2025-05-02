// // lib/screens/models_page.dart
// import 'package:doch_frontend/Screens/3dModelPage.dart';
// import 'package:doch_frontend/service/Service.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ModelsPage extends StatefulWidget {
//   const ModelsPage({super.key});

//   @override
//   State<ModelsPage> createState() => _ModelsPageState();
// }

// class _ModelsPageState extends State<ModelsPage> {
//   late Future<List<ChModel>> _modelsFuture;
//   final Map<int, String> _categoryNames = {}; // Cache for category names

//   @override
//   void initState() {
//     super.initState();
//     _modelsFuture = _fetchModels();
//     _fetchCategories();
//   }

//   Future<List<ChModel>> _fetchModels() async {
//     final response = await http.get(Uri.parse('${ApiService.baseUrl}/models'));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> models = data['models'];
//       return models.map((json) => ChModel.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load models');
//     }
//   }

//   Future<void> _fetchCategories() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiService.baseUrl}/categories'),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> categories = data['categories'];

//         setState(() {
//           for (var category in categories) {
//             _categoryNames[category['id']] = category['name'];
//           }
//         });
//       }
//     } catch (e) {
//       print('Error fetching categories: $e');
//     }
//   }

//   Future<void> _refreshModels() async {
//     setState(() {
//       _modelsFuture = _fetchModels();
//     });
//   }

//   String _getCategoryName(int? categoryId) {
//     if (categoryId == null) return 'Uncategorized';
//     return _categoryNames[categoryId] ?? 'Category $categoryId';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _refreshModels,
//         child: FutureBuilder<List<ChModel>>(
//           future: _modelsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 60, color: Colors.red[700]),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Error loading models',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: _refreshModels,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.remove_from_queue,
//                       size: 60,
//                       color: Colors.grey[600],
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'No models available',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             final models = snapshot.data!;

//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     '3D Models',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: GridView.builder(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 16,
//                             mainAxisSpacing: 16,
//                             childAspectRatio: 0.75,
//                           ),
//                       itemCount: models.length,
//                       itemBuilder: (context, index) {
//                         final model = models[index];
//                         return _buildModelCard(context, model);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildModelCard(BuildContext context, ChModel model) {
//     return GestureDetector(
//       onTap: () {
//         // Navigate to ArtifactDetailPage when clicked
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => ArtifactDetailPage(
//                   modelData: model,
//                   siteName: model.currentLocation ?? 'Unknown Location',
//                 ),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // Display thumbnail or placeholder
//                     model.thumbnail != null && model.thumbnail!.isNotEmpty
//                         ? Image.network(
//                           '${ApiService.baseUrl}${model.thumbnail}',
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return _buildPlaceholderImage(model);
//                           },
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 value:
//                                     loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress
//                                                 .cumulativeBytesLoaded /
//                                             loadingProgress.expectedTotalBytes!
//                                         : null,
//                               ),
//                             );
//                           },
//                         )
//                         : _buildPlaceholderImage(model),
//                     // Category badge
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Theme.of(
//                             context,
//                           ).primaryColor.withOpacity(0.8),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           _getCategoryName(model.categoryId),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       model.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       model.currentLocation ?? 'Unknown Location',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceholderImage(ChModel model) {
//     // Get first letter of model name for the placeholder
//     final firstLetter =
//         model.name.isNotEmpty ? model.name[0].toUpperCase() : '?';

//     return Container(
//       color: Colors.grey[200],
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor.withOpacity(0.7),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   firstLetter,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               '3D Model',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// @override
// Widget build(BuildContext context, dynamic modelData) {
//   // You should have your own implementation of this page
//   return Scaffold(
//     appBar: AppBar(title: Text(modelData.name)),
//     body: Center(child: Text('Artifact Detail Page for ${modelData.name}')),
//   );
// }

import 'package:doch_frontend/localization/appLocalizations.dart';
// import 'package:doch_frontend/service/Service.dart';
// import 'package:flutter/material.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart';

// class ArtifactDetailPage extends StatefulWidget {
//   final ChModel modelData;
//   final String siteName;

//   const ArtifactDetailPage({
//     Key? key,
//     required this.modelData,
//     required this.siteName,
//   }) : super(key: key);

//   @override
//   _ArtifactDetailPageState createState() => _ArtifactDetailPageState();
// }

// class _ArtifactDetailPageState extends State<ArtifactDetailPage> {
//   bool isExpanded = false;
//   final String baseUrl = ApiService.baseUrl;
//   // final String baseUrl = 'http://127.0.0.1:37140/';

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final localizations = AppLocalizations.of(context);
//     final model = widget.modelData;
//     String model1 = "http://192.168.1.234:8080/api/model/${model.id}";

//     return Scaffold(
//       backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
//       appBar: AppBar(
//         centerTitle: true,
//         foregroundColor: Colors.white,
//         backgroundColor: Color.fromARGB(255, 3, 90, 105),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: isDarkMode ? Colors.white : Colors.black,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           isExpanded ? model.name : model.name,
//           style: TextStyle(
//             // color: isDarkMode ? Colors.white : Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: [
//           if (!isExpanded) ...[
//             IconButton(
//               icon: Icon(
//                 Icons.bookmark_border,
//                 // color: isDarkMode ? Colors.white : Colors.black,
//               ),
//               onPressed: () {},
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.share,
//                 // color: isDarkMode ? Colors.white : Colors.black,
//               ),
//               onPressed: () {},
//             ),
//           ],
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Stack(
//               children: [
//                 // 3D Model Viewer
//                 SizedBox(
//                   width: double.infinity,
//                   height: isExpanded ? MediaQuery.of(context).size.height : 400,
//                   child: ModelViewer(
//                     alt: "No model found",

//                     src: '$baseUrl/${model.path}',
//                     backgroundColor: isDarkMode ? Colors.black54 : Colors.white,
//                     ar: false,
//                     autoRotate: true,
//                     cameraControls: true,
//                     loading: Loading.eager,
//                   ),
//                 ),

//                 // Expand/Collapse button
//                 Positioned(
//                   right: 16,
//                   bottom: 16,
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isExpanded = !isExpanded;
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (!isExpanded) ...[
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         model.name,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on, color: Colors.grey),
//                           SizedBox(width: 8),
//                           Text(
//                             widget.siteName,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: isDarkMode ? Colors.white : Colors.black,
//                             ),
//                           ),
//                           Spacer(),
//                           if (model.currentLocation != null)
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color:
//                                     isDarkMode
//                                         ? Colors.grey[800]
//                                         : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 model.currentLocation!,
//                                 style: TextStyle(
//                                   color:
//                                       isDarkMode
//                                           ? Colors.white70
//                                           : Colors.black87,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 16),

//                       // Artifact details section
//                       _buildDetailItem(
//                         isDarkMode,
//                         'Description',
//                         model.description,
//                       ),

//                       if (model.originDate != null)
//                         _buildDetailItem(
//                           isDarkMode,
//                           'Origin Date',
//                           model.originDate!,
//                         ),

//                       if (model.originCountry != null)
//                         _buildDetailItem(
//                           isDarkMode,
//                           'Origin Country',
//                           model.originCountry!,
//                         ),

//                       // Technical details
//                       SizedBox(height: 16),
//                       Text(
//                         localizations?.translate('technical_details') ??
//                             'Technical Details',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 8),

//                       if (model.scanningMethod != null)
//                         _buildDetailItem(
//                           isDarkMode,
//                           'Scanning Method',
//                           model.scanningMethod!,
//                         ),

//                       if (model.scanDate != null)
//                         _buildDetailItem(
//                           isDarkMode,
//                           'Scan Date',
//                           model.scanDate!,
//                         ),

//                       if (model.softwareUsed != null)
//                         _buildDetailItem(
//                           isDarkMode,
//                           'Software Used',
//                           model.softwareUsed!,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem(bool isDarkMode, String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white70 : Colors.black87,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             content,
//             style: TextStyle(
//               fontSize: 15,
//               color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
