import 'dart:convert';
import 'package:attendaceapp/config/api.dart';
import 'package:attendaceapp/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MyAnalysisPage extends StatefulWidget {
  const MyAnalysisPage({super.key});

  @override
  State<MyAnalysisPage> createState() => _MyAnalysisPageState();
}

class _MyAnalysisPageState extends State<MyAnalysisPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _mlResult;

  @override
  void initState() {
    super.initState();
    fetchMLRecommendation();
  }

  Future<void> fetchMLRecommendation() async {
    try {
      final userId = UserSession.index;
      final uri = Uri.parse("$API_URL/recommend/$userId");
      final response = await http.get(uri);

      debugPrint("Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);

        if (decoded['recommended_courses'] is String) {
          decoded['recommended_courses'] = json.decode(decoded['recommended_courses']);
        }

        debugPrint("Decoded ML Result: $decoded");

        setState(() {
          _mlResult = decoded;
          _isLoading = false;
        });
      } else {
        setState(() {
          _mlResult = {"relevance": 0, "confidence": 0.0, "recommended_courses": []};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _mlResult = {"relevance": 0, "confidence": 0.0, "recommended_courses": []};
        _isLoading = false;
      });
      debugPrint("Error fetching ML data: $e");
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendedCourses = (_mlResult?['recommended_courses'] is List)
        ? List.from(_mlResult!['recommended_courses'])
        : [];

    final internalCourses =
        recommendedCourses.where((c) => c.containsKey('course_id')).toList();
    final externalCourses =
        recommendedCourses.where((c) => c.containsKey('url')).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("ML Course Recommendations"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    color: Colors.deepPurple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: ${UserSession.email ?? 'No Email'}"),

                          const SizedBox(height: 4),
                          Text(
                            "Index: ${UserSession.index}",
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  "Relevance: ${_mlResult?['relevance'] ?? 0}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.deepPurple,
                              ),
                              const SizedBox(width: 10),
                              Chip(
                                label: Text(
                                  "Confidence: ${((_mlResult?['confidence'] ?? 0.0) * 100).toStringAsFixed(2)}%",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.deepPurpleAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Internal Courses
                  if (internalCourses.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Recommended Courses",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ...internalCourses.map((course) {
                    final courseName = course['course_name'] ?? 'No name';
                    final category = course['category'] ?? '';
                    final skills = course['related_skills'] ?? '';

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.book, color: Colors.deepPurple),
                        title: Text(courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Category: $category\nSkills: $skills'),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  // External Courses
                  if (externalCourses.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "External Learning Resources",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ...externalCourses.map((course) {
                    final courseName = course['course_name'] ?? 'No name';
                    final url = course['url'] ?? '';
                    final snippet = course['snippet'] ?? '';

                    return GestureDetector(
                      onTap: url.isNotEmpty ? () => _launchURL(url) : null,
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.link, color: Colors.deepPurple),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      courseName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                snippet,
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // No courses
                  if (recommendedCourses.isEmpty)
                    Center(
                      child: Column(
                        children: const [
                          SizedBox(height: 50),
                          Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "No recommended courses found.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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
