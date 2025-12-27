import 'dart:convert';
import 'package:attendaceapp/config/api.dart';
import 'package:attendaceapp/profileedit.dart';
import 'package:attendaceapp/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ================= MODEL =================
class StudentProfile {
  final String userId;
  final String degreeProgram;
  final String full_name;
  final String currentYear;
  final String email;
  final String skills;
  final String career_goal;
  final String? profileImage; // base64 string

  StudentProfile({
    required this.userId,
    required this.full_name,
    required this.degreeProgram,
    required this.currentYear,
    required this.skills,
    required this.career_goal,
    this.profileImage,
    required this.email,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      userId: json['user_id'] ?? '',
      degreeProgram: json['degree_program'] ?? '',
      currentYear: json['current_year']?.toString() ?? '',
      skills: json['skills'] ?? '',
      profileImage: json['profileimage'],
      career_goal: json['career_goal'],
      full_name: json['full_name'],
      email: '',
    );
  }
}

/// ================= SERVICE =================
class ProfileService {
  static Future<StudentProfile> getProfile(String userId) async {
    final url = Uri.parse("$API_URL/profilewith/$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return StudentProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load profile");
    }
  }
}

/// ================= PAGE =================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StudentProfile? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (UserSession.index == null) {
      debugPrint("UserSession.index is null");
      setState(() => isLoading = false);
      return;
    }

    try {
      final result = await ProfileService.getProfile(UserSession.index!);
      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 81, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: [
            /// ================= PROFILE SECTION =================
            isLoading
                ? _loadingProfile()
                : profile == null
                ? _profileNotFound()
                : _profileCard(),

            /// ================= DETAILS TABLE =================
            if (!isLoading && profile != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    _tableRow(
                      "Name",
                      profile!.full_name.isEmpty
                          ? "Not provided"
                          : profile!.full_name,
                    ),
                    _tableRow(
                      "Degree",
                      profile!.degreeProgram.isEmpty
                          ? "Not provided"
                          : profile!.degreeProgram,
                    ),
                    _tableRow(
                      "Year",
                      profile!.currentYear.isEmpty
                          ? "Not provided"
                          : profile!.currentYear,
                    ),
                    _tableRow(
                      "skills",
                      profile!.skills.isEmpty
                          ? "Not provided"
                          : profile!.skills,
                    ),
                    _tableRow(
                      "career_goal",
                      profile!.career_goal.isEmpty
                          ? "Not provided"
                          : profile!.career_goal,
                    ),
                    _tableRow("ID", profile!.userId),
                  ],
                ),
              ),

            /// ================= EDIT BUTTON =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyProfileEdit()),
                  );
                },
                child: const Text(
                  "Edit Your Profile",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= LOADING UI =================
  Widget _loadingProfile() {
    return Column(
      children: const [
        SizedBox(height: 100),
        Image(image: AssetImage("assets/images/loading.png"), height: 250),
        SizedBox(height: 15),
        CircularProgressIndicator(),
      ],
    );
  }

  /// ================= PROFILE CARD =================
  Widget _profileCard() {
    return Container(
      width: 350,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 81, 255),
            Color.fromARGB(255, 33, 114, 180),
            Color.fromARGB(255, 84, 162, 218),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          /// ================= PROFILE IMAGE =================
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: profile!.profileImage != null
                ? MemoryImage(base64Decode(profile!.profileImage!))
                : null,
            child: profile!.profileImage == null
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 8),
                child: Text(
                  profile!.userId,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${UserSession.email}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= PROFILE NOT FOUND =================
  Widget _profileNotFound() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text("Profile not found", style: TextStyle(fontSize: 16)),
    );
  }

  /// ================= TABLE ROW =================
  TableRow _tableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8), child: Text(value)),
      ],
    );
  }
}
