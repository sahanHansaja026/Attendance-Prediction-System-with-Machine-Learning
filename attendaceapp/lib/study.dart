import 'dart:convert';
import 'package:attendaceapp/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendaceapp/config/api.dart'; // Make sure API_URL is defined here

class StudentGrade extends StatefulWidget {
  const StudentGrade({super.key});

  @override
  State<StudentGrade> createState() => _StudentGradeState();
}

class _StudentGradeState extends State<StudentGrade> {
  List<dynamic> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    try {
      final userId = UserSession.index;
      final uri = Uri.parse('$API_URL/student-results/$userId');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          results = data;
          isLoading = false;
        });
      } else {
        print("Failed to fetch results: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching results: $e");
      setState(() => isLoading = false);
    }
  }

  Color getGradeColor(String? grade) {
    switch (grade) {
      case "A":
        return Colors.green;
      case "B":
        return Colors.lightGreen;
      case "C":
        return Colors.orange;
      case "D":
        return Colors.redAccent;
      case "F":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 81, 255),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              
              child: const Icon(Icons.arrow_back, color: Colors.white),
            
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(child: Text("No results found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final courseName = result['course_name'] ?? "Unknown Course";
                    final marks = result['marks'] ?? "-";
                    final grade = result['grade'] ?? "-";
                    final completed = result['completed'] ?? true;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          courseName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text("CA Marks: $marks"),
                            const SizedBox(height: 3),
                            Text("Completed: ${completed ? "Yes" : "No"}"),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: getGradeColor(grade),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            grade,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
