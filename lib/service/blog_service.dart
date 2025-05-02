// blog_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BlogService {
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String baseUrl = 'http://46.101.224.211/api';

  Future<List<BlogModel>> getBlogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blogs'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> blogsJson = data['blogs'];

        return blogsJson.map((json) => BlogModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load blogs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}

// models/blog_model.dart
class BlogModel {
  final String id;
  final String title;
  final String subtitle;
  final String author;
  final String date;
  final String readTime;
  final String views;
  final int likes;
  final int comments;
  final String image;
  final String content;

  BlogModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.date,
    required this.readTime,
    required this.views,
    required this.likes,
    required this.comments,
    required this.image,
    required this.content,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    // Extract date from created_at or use a default value
    String dateStr = 'N/A';
    if (json['created_at'] != null &&
        json['created_at'] is String &&
        json['created_at'] != 'null') {
      final DateTime dateTime = DateTime.parse(json['created_at']);
      dateStr = '${dateTime.day} ${_getMonthName(dateTime.month)}';
    }

    // Create default or placeholder values for fields not in the API
    return BlogModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled',
      subtitle: _extractSubtitle(json['content']),
      author: 'Admin', // Default author
      date: dateStr,
      readTime: '${_estimateReadTime(json['content'])} Mins Read',
      views: '${_getRandomViewCount()}k',
      likes: _getRandomNumber(50, 150),
      comments: _getRandomNumber(10, 60),
      image: json['thumbnail'] ?? '',
      content: _cleanHtmlContent(json['content'] ?? ''),
    );
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _extractSubtitle(String? content) {
    if (content == null || content.isEmpty) return 'No description available';

    // Try to extract a meaningful subtitle from the content
    // Remove HTML tags and get the first sentence or first few words
    String cleanContent = _cleanHtmlContent(content);

    // Get first sentence or first 50 characters
    String subtitle = cleanContent.split('.').first;
    if (subtitle.length > 70) {
      subtitle = subtitle.substring(0, 70) + '...';
    }

    return subtitle;
  }

  static String _cleanHtmlContent(String htmlContent) {
    // Simple HTML tag removal - for production, consider using a proper HTML parser
    return htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');
  }

  static int _estimateReadTime(String? content) {
    if (content == null || content.isEmpty) return 5;

    // Estimate read time based on content length (average reading speed: 200 words per minute)
    String cleanContent = _cleanHtmlContent(content);
    int wordCount = cleanContent.split(' ').length;
    int minutes = (wordCount / 200).ceil();

    return minutes < 5
        ? 5
        : minutes > 20
        ? 20
        : minutes;
  }

  static int _getRandomNumber(int min, int max) {
    return min + DateTime.now().millisecondsSinceEpoch % (max - min);
  }

  static double _getRandomViewCount() {
    // Generate a random view count between 10k and 100k
    return (10 + (DateTime.now().millisecondsSinceEpoch % 90)) / 10;
  }
}
