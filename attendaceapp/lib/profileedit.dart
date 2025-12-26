import 'dart:io';
import 'dart:convert';
import 'package:attendaceapp/config/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:attendaceapp/session_manager.dart';
import 'dart:typed_data'; // for Uint8List
import 'dart:convert'; // for base64Decode

class MyProfileEdit extends StatefulWidget {
  const MyProfileEdit({super.key});

  @override
  State<MyProfileEdit> createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _graduationYearController =
      TextEditingController();
  final TextEditingController _careerGoalController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();

  // State variables
  File? _imageFile;
  String? selectedIndex;
  List<String> skills = [];
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Uint8List? _imageFileBytes; // Add this as a state variable

  Future<void> _loadProfile() async {
    try {
      var userId = UserSession.index; // e.g., "22ug2-0035"
      var uri = Uri.parse("$API_URL/profilewith/$userId");

      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          _fullNameController.text = data['full_name'] ?? "";
          _graduationYearController.text =
              data['current_year']?.toString() ?? "";
          _careerGoalController.text = data['career_goal'] ?? "";
          skills = (data['skills'] ?? "").split(",");
          selectedIndex = data['degree_program']?.trim();

          // Decode the base64 image
          if (data['profileimage'] != null) {
            _imageFileBytes = base64Decode(data['profileimage']);
            _imageFile = null; // clear local image if any
          }
        });
      } else {
        print("Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      profileImageUrl = null; // Clear network image when picking local
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: this.context, // <-- fix type error
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(this.context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(this.context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // Update profile
  Future<void> updateProfile() async {
    try {
      var uri = Uri.parse("$API_URL/update/${UserSession.index}");

      var request = http.MultipartRequest('PUT', uri);

      if (selectedIndex != null)
        request.fields['degree_program'] = selectedIndex!;
      if (_graduationYearController.text.isNotEmpty) {
        request.fields['current_year'] = _graduationYearController.text;
      }
      if (_fullNameController.text.isNotEmpty) {
        request.fields['full_name'] = _fullNameController.text;
      }
      if (skills.isNotEmpty) request.fields['skills'] = skills.join(',');
      if (_careerGoalController.text.isNotEmpty) {
        request.fields['career_goal'] = _careerGoalController.text;
      }
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileimage',
            _imageFile!.path,
            filename: basename(_imageFile!.path),
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Profile updated successfully");
        ScaffoldMessenger.of(
          this.context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated")));
      } else {
        print("Failed to update profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // Helper for text fields
  Widget _buildTextFieldCard(
    String label,
    String hint,
    TextEditingController? controller, {
    bool readOnly = false,
  }) {
    return Card(
      elevation: 3,
      color: const Color.fromARGB(255, 0, 81, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 0, 81, 255),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const SizedBox(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_imageFileBytes != null
                              ? MemoryImage(_imageFileBytes!) as ImageProvider
                              : null),
                    child: _imageFile == null && _imageFileBytes == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color.fromARGB(255, 90, 93, 102),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Tap to change profile picture"),
            const SizedBox(height: 30),

            _buildTextFieldCard(
              "Full Name",
              "Enter your full name",
              _fullNameController,
            ),
            const SizedBox(height: 30),
            _buildTextFieldCard(
              "Index Number",
              "${UserSession.index}",
              null,
              readOnly: true,
            ),
            const SizedBox(height: 30),

            // Degree Program Dropdown
            Card(
              elevation: 3,
              color: const Color.fromARGB(255, 0, 81, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: selectedIndex,
                  dropdownColor: Colors.white,
                  hint: const Text(
                    "Select Degree Program",
                    style: TextStyle(color: Colors.black54),
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 0, 81, 255),
                      ),
                    ),
                  ),
                  items:
                      [
                            // Engineering
                            "Software Engineering",
                            "Mechanical Engineering",
                            "Civil Engineering",
                            "Electrical Engineering",
                            // IT
                            "Computer Science",
                            "Information Technology",
                            "Cyber Security",
                            "Data Science",
                            // Medicine
                            "Medicine",
                            "Nursing",
                            "Pharmacy",
                            "Dentistry",
                            // Arts
                            "Music",
                            "Visual Arts",
                            "Performing Arts",
                            "Literature",
                            // Business
                            "Business Administration",
                            "Finance",
                            "Marketing",
                            "Economics",
                            // Science
                            "Mathematics",
                            "Biology",
                            "Chemistry",
                            "Physics",
                          ]
                          .map(
                            (program) => DropdownMenuItem(
                              value: program,
                              child: Text(program),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => selectedIndex = value),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildTextFieldCard(
              "Graduation Year",
              "Enter Your Graduation Year",
              _graduationYearController,
            ),
            const SizedBox(height: 30),

            // Skills
            Card(
              elevation: 3,
              color: const Color.fromARGB(255, 0, 81, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Skills",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skills
                                .map(
                                  (skill) => Chip(
                                    label: Text(skill),
                                    deleteIcon: const Icon(Icons.close),
                                    onDeleted: () =>
                                        setState(() => skills.remove(skill)),
                                  ),
                                )
                                .toList(),
                          ),
                          TextField(
                            controller: _skillController,
                            decoration: const InputDecoration(
                              hintText: "Type a skill and press Enter",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  skills.add(value.trim());
                                  _skillController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildTextFieldCard(
              "Career Goal",
              "Enter your Career Goal",
              _careerGoalController,
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 0, 40, 126),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Save Profile",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
