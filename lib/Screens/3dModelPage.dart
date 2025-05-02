import 'dart:convert';
import 'dart:io';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class ArtifactDetailPages extends StatefulWidget {
  final int modelId;
  final String siteName;

  const ArtifactDetailPages({
    Key? key,
    required this.modelId,
    required this.siteName,
  }) : super(key: key);

  @override
  _ArtifactDetailPageState createState() => _ArtifactDetailPageState();
}

class _ArtifactDetailPageState extends State<ArtifactDetailPages> {
  bool isExpanded = false;
  bool isLoading = true;
  String? modelFilePath;
  ModelData? modelData;
  final String baseUrl = 'http://46.101.224.211';

  @override
  void initState() {
    super.initState();
    fetchModelData();
  }

  Future<void> fetchModelData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/models/${widget.modelId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          modelData = ModelData.fromJson(data);
        });

        // Convert base64 to GLB file
        await _saveGlbFile(modelData!.base64);
      } else {
        // Handle error
        print('Failed to load model data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching model data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveGlbFile(String base64String) async {
    try {
      // Decode Base64 string to bytes
      final bytes = base64Decode(base64String);
      // Get the directory to save the file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/model_${widget.modelId}.glb';
      // Write bytes to a file
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      setState(() {
        modelFilePath = filePath;
      });
      print('File saved to $filePath');
    } catch (e) {
      print('Error saving GLB file: $e');
    }
  }

  Future<void> downloadModel() async {
    if (modelData == null) return;

    try {
      // Save the file to a shareable location
      final directory =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/${modelData!.name}_${widget.modelId}.glb';

      // Create the file
      final file = File(filePath);
      await file.writeAsBytes(base64Decode(modelData!.base64));

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Model downloaded to $filePath')));
    } catch (e) {
      print('Error downloading model: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download model: $e')));
    }
  }

  Future<void> shareModel() async {
    if (modelFilePath == null) return;

    try {
      final file = XFile(modelFilePath!);
      await Share.shareXFiles([
        file,
      ], text: 'Sharing 3D model: ${modelData?.name}');
    } catch (e) {
      print('Error sharing model: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share model: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
          backgroundColor: Color.fromARGB(255, 3, 90, 105),
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (modelData == null || modelFilePath == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: Color.fromARGB(255, 3, 90, 105),
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text('Failed to load model data')),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 3, 90, 105),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          modelData!.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          if (!isExpanded) ...[
            IconButton(
              icon: Icon(Icons.download),
              onPressed: downloadModel,
              tooltip: 'Download 3D model',
            ),
            IconButton(icon: Icon(Icons.bookmark_border), onPressed: () {}),
            IconButton(icon: Icon(Icons.share), onPressed: shareModel),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 3D Model Viewer
                SizedBox(
                  width: double.infinity,
                  height: isExpanded ? MediaQuery.of(context).size.height : 400,
                  child: ModelViewer(
                    alt: "No model found",
                    src: 'file://$modelFilePath',
                    backgroundColor: isDarkMode ? Colors.black54 : Colors.white,
                    ar: false,
                    autoRotate: true,
                    cameraControls: true,
                    loading: Loading.eager,
                  ),
                ),

                // Expand/Collapse button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isExpanded) ...[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modelData!.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            widget.siteName,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          Spacer(),
                          if (modelData!.currentLocation != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                modelData!.currentLocation!,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Artifact details section
                      _buildDetailItem(
                        isDarkMode,
                        'Description',
                        modelData!.description,
                      ),

                      if (modelData!.originDate != null)
                        _buildDetailItem(
                          isDarkMode,
                          'Origin Date',
                          modelData!.originDate!,
                        ),

                      if (modelData!.originCountry != null)
                        _buildDetailItem(
                          isDarkMode,
                          'Origin Country',
                          modelData!.originCountry!,
                        ),

                      // Technical details
                      SizedBox(height: 16),
                      Text(
                        localizations?.translate('technical_details') ??
                            'Technical Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),

                      if (modelData!.scanningMethod != null)
                        _buildDetailItem(
                          isDarkMode,
                          'Scanning Method',
                          modelData!.scanningMethod!,
                        ),

                      if (modelData!.scanDate != null)
                        _buildDetailItem(
                          isDarkMode,
                          'Scan Date',
                          modelData!.scanDate!,
                        ),

                      if (modelData!.softwareUsed != null)
                        _buildDetailItem(
                          isDarkMode,
                          'Software Used',
                          modelData!.softwareUsed!,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(bool isDarkMode, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Model class to parse the API response
class ModelData {
  final String name;
  final String description;
  final String base64;
  final String? location;
  final String? originDate;
  final String? originCountry;
  final String? currentLocation;
  final String? category;
  final String? scanningMethod;
  final String? scanDate;
  final String? softwareUsed;

  ModelData({
    required this.name,
    required this.description,
    required this.base64,
    this.location,
    this.originDate,
    this.originCountry,
    this.currentLocation,
    this.category,
    this.scanningMethod,
    this.scanDate,
    this.softwareUsed,
  });

  factory ModelData.fromJson(Map<String, dynamic> json) {
    return ModelData(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      base64: json['base64'] ?? '',
      location: json['location'],
      originDate: json['origin_date'],
      originCountry: json['origin_country'],
      currentLocation: json['current_location'],
      category: json['category'],
      scanningMethod: json['scanning_method'],
      scanDate: json['scan_date'],
      softwareUsed: json['software_used'],
    );
  }
}
