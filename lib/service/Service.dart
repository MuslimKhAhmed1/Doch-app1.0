// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.234:8080/api';
  // static const String baseUrl = 'http:///127.0.0.1:8000/api';

  Future<List<Site>> fetchSites() async {
    final response = await http.get(Uri.parse('$baseUrl/sites'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> sites = data['sites'];
      return sites.map((json) => Site.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sites');
    }
  }

  Future<Site> fetchSiteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/sites/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Site.fromJson(data['site']);
    } else {
      throw Exception('Failed to load site details');
    }
  }
}

// lib/models/site.dart
class Site {
  final int id;
  final String name;
  final int typeId;
  final String description;
  final double latitude;
  final double longitude;
  final String? status;
  final String? statusExpiration;
  final String? externalLink;
  final String? phone1;
  final String? phone2;
  final String? email;
  final String city;
  final String createdAt;
  final String updatedAt;
  final List<Gallery> galleries;
  final List<OpenHour> openHours;
  final List<dynamic> chModels;
  final SiteType siteType;

  Site({
    required this.id,
    required this.name,
    required this.typeId,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.status,
    this.statusExpiration,
    this.externalLink,
    this.phone1,
    this.phone2,
    this.email,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
    required this.galleries,
    required this.openHours,
    required this.chModels,
    required this.siteType,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      name: json['name'],
      typeId: json['type_id'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      status: json['status'],
      statusExpiration: json['status_expiration'],
      externalLink: json['external_link'],
      phone1: json['phone_1'],
      phone2: json['phone_2'],
      email: json['email'],
      city: json['city'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      galleries:
          (json['galleries'] as List).map((e) => Gallery.fromJson(e)).toList(),
      openHours:
          (json['open_hours'] as List)
              .map((e) => OpenHour.fromJson(e))
              .toList(),
      chModels:
          (json['ch_models'] as List).map((e) => ChModel.fromJson(e)).toList(),
      siteType: SiteType.fromJson(json['site_type']),
    );
  }
}

class Gallery {
  final int id;
  final int siteId;
  final String path;
  final String? createdAt;
  final String? updatedAt;

  Gallery({
    required this.id,
    required this.siteId,
    required this.path,
    this.createdAt,
    this.updatedAt,
  });

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: json['id'],
      siteId: json['site_id'],
      path: json['path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class OpenHour {
  final int id;
  final String day;
  final String openingTime;
  final String closingTime;
  final int siteId;
  final String? createdAt;
  final String? updatedAt;

  OpenHour({
    required this.id,
    required this.day,
    required this.openingTime,
    required this.closingTime,
    required this.siteId,
    this.createdAt,
    this.updatedAt,
  });

  factory OpenHour.fromJson(Map<String, dynamic> json) {
    return OpenHour(
      id: json['id'],
      day: json['day'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      siteId: json['site_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class SiteType {
  final int id;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  SiteType({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory SiteType.fromJson(Map<String, dynamic> json) {
    return SiteType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ChModel {
  final int id;
  final String name;
  final String description;
  final String path;
  final String? thumbnail;
  final int userId;
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

  ChModel({
    required this.id,
    required this.name,
    required this.description,
    required this.path,
    this.thumbnail,
    required this.userId,
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
    );
  }
}
