// blogs_page.dart
import 'package:doch_frontend/Screens/detailBlog.dart';
import 'package:doch_frontend/service/Service.dart';
import 'package:doch_frontend/service/blog_service.dart';
import 'package:flutter/material.dart';
import '../localization/appLocalizations.dart';

class BlogsPage extends StatefulWidget {
  const BlogsPage({Key? key}) : super(key: key);

  @override
  State<BlogsPage> createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage> {
  final BlogService _blogService = BlogService();
  List<BlogModel> blogs = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final fetchedBlogs = await _blogService.getBlogs();
      setState(() {
        blogs = fetchedBlogs;
        isLoading = false;
      });
    } catch (e) {
      errorMessage = 'Failed to load blogs: $e';
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                AppLocalizations.of(context)?.translate('blogs') ?? 'Blogs',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(
                                context,
                              )?.translate('search_blogs') ??
                              'Search Blogs',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () {
                        // Filter functionality
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Blog list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchBlogs,
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : errorMessage.isNotEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  errorMessage,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: fetchBlogs,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                          : blogs.isEmpty
                          ? Center(
                            child: Text(
                              'No blogs available',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: blogs.length,
                            itemBuilder: (context, index) {
                              final blog = blogs[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              BlogDetailPage(blog: blog),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.grey[800]
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Blog image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          child:
                                              blog.image.isNotEmpty
                                                  ? Image.network(
                                                    'http://192.168.1.234:8080${blog.image}',
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          color: Theme.of(
                                                                context,
                                                              ).primaryColor
                                                              .withOpacity(0.3),
                                                        ),
                                                  )
                                                  : Container(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.3),
                                                  ),
                                        ),
                                      ),
                                      // Blog content
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                blog.readTime,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      isDark
                                                          ? Colors.grey[400]
                                                          : Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                blog.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Text(
                                                    blog.views,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(
                                                    Icons.thumb_up_outlined,
                                                    size: 16,
                                                    color:
                                                        isDark
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${blog.likes}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(
                                                    Icons.chat_bubble_outline,
                                                    size: 16,
                                                    color:
                                                        isDark
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${blog.comments}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          isDark
                                                              ? Colors.grey[400]
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
