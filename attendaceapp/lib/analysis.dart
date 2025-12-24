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

  final PageController _pageController = PageController();
  int _currentPage = 0;

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

      if (response.statusCode == 200) {
        var decoded = json.decode(response.body);

        if (decoded['recommended_courses'] is String) {
          decoded['recommended_courses'] = json.decode(
            decoded['recommended_courses'],
          );
        }

        setState(() {
          _mlResult = decoded;
          _isLoading = false;
        });
      } else {
        _setEmpty();
      }
    } catch (e) {
      debugPrint("Error: $e");
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

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendedCourses = (_mlResult?['recommended_courses'] is List)
        ? List.from(_mlResult!['recommended_courses'])
        : [];

    final internalCourses = recommendedCourses
        .where((c) => c.containsKey('course_id'))
        .toList();

    final externalCourses = recommendedCourses
        .where((c) => c.containsKey('url'))
        .toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 81, 255),
        title: const Text(
          "Recommendations",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _userInfoCard(),
                  const SizedBox(height: 16),
                  _pageTabs(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      children: [
                        _externalCoursesView(externalCourses),
                        _internalCoursesView(internalCourses),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= UI COMPONENTS =================

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
            Text("Email: ${UserSession.email ?? 'No Email'}"),
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

  Widget _pageTabs() {
    return Row(
      children: [
        Expanded(child: _tabButton("External Resources", 0)),
        Expanded(child: _tabButton("Internal Courses", 1)),
      ],
    );
  }

  Widget _tabButton(String title, int index) {
    final selected = _currentPage == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          border: Border(
            top: const BorderSide(
              color: Color.fromARGB(255, 255, 255, 255),
              width: 3,
            ),
            left: const BorderSide(
              color: Color.fromARGB(255, 255, 255, 255),
              width: 3,
            ),
            right: const BorderSide(
              color: Color.fromARGB(255, 255, 255, 255),
              width: 3,
            ),
            bottom: BorderSide(
              color: selected
                  ? const Color.fromARGB(255, 13, 0, 255) // SELECTED
                  : const Color.fromARGB(255, 255, 255, 255), // NOT SELECTED
              width: 3,
            ),
          ),
        ),

        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================= PAGES =================

  Widget _internalCoursesView(List courses) {
    if (courses.isEmpty) {
      return _emptyState("No internal courses found");
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final c = courses[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(
              Icons.school,
              color: Color.fromARGB(255, 0, 81, 255),
            ),
            title: Text(
              c['course_name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Category: ${c['category']}\nSkills: ${c['related_skills']}",
            ),
          ),
        );
      },
    );
  }

  Widget _externalCoursesView(List courses) {
    if (courses.isEmpty) {
      return _emptyState("No external resources found");
    }

    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final c = courses[index];
        return GestureDetector(
          onTap: () => _launchURL(c['url']),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.link,
                        color: Color.fromARGB(255, 0, 81, 255),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c['course_name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(c['snippet'] ?? ''),
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
          const Icon(
            Icons.sentiment_dissatisfied,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
