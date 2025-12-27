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

  // ================= API =================

  Future<void> fetchMLRecommendation() async {
    try {
      final userId = UserSession.index;
      final uri = Uri.parse("$API_URL/recommend/$userId");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          _mlResult = decoded;
          _isLoading = false;
        });
      } else {
        _setEmpty();
      }
    } catch (e) {
      debugPrint("Error fetching ML data: $e");
      _setEmpty();
    }
  }

  void _setEmpty() {
    setState(() {
      _mlResult = {
        "relevance": 0,
        "confidence": 0.0,
        "recommended_courses": [],
      };
      _isLoading = false;
    });
  }

  // ================= URL LAUNCH =================

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // 🔥 opens browser
      );
    } else {
      debugPrint("Could not launch $url");
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final courses =
        (_mlResult?['recommended_courses'] is List)
            ? List.from(_mlResult!['recommended_courses'])
            : [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 81, 255),
        title: const Text(
          "Learning Recommendations",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _userInfoCard(),
                  const SizedBox(height: 16),
                  Expanded(child: _coursesView(courses)),
                ],
              ),
            ),
    );
  }

  Widget _userInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${UserSession.email ?? 'N/A'}"),
            const SizedBox(height: 6),
            Text("Index: ${UserSession.index}"),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    "Relevance: ${_mlResult?['relevance'] ?? 0}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(
                    "Confidence: ${((_mlResult?['confidence'] ?? 0) * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coursesView(List courses) {
    if (courses.isEmpty) {
      return _emptyState("No learning resources found");
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];

        return GestureDetector(
          onTap: () => _launchURL(course['url']),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.open_in_new,
                        color: Color.fromARGB(255, 0, 81, 255),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course['course_name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(course['snippet'] ?? ''),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied,
              size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
