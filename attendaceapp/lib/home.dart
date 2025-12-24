import 'dart:convert';
import 'dart:typed_data';

import 'package:attendaceapp/analysis.dart';
import 'package:attendaceapp/attendanceshow.dart';
import 'package:attendaceapp/config/api.dart';
import 'package:attendaceapp/main.dart';
import 'package:attendaceapp/profileshow.dart';
import 'package:attendaceapp/qrscan.dart';
import 'package:attendaceapp/services/gust_auth_service.dart';
import 'package:attendaceapp/session_manager.dart';
import 'package:attendaceapp/study.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  Uint8List? _profileImageBytes;
  bool _isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      var userId = UserSession.index;
      var uri = Uri.parse("$API_URL/profilewith/$userId");

      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          if (data['profileimage'] != null) {
            _profileImageBytes = base64Decode(data['profileimage']);
          }
          _isProfileLoading = false;
        });
      } else {
        print("Failed to fetch profile: ${response.statusCode}");
        setState(() => _isProfileLoading = false);
      }
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() => _isProfileLoading = false);
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      final token = UserSession.accessToken;

      final response = await http.post(
        Uri.parse('$API_URL/gust_logout'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": UserSession.email?.trim()}),
      );

      if (response.statusCode == 200) {
        UserSession.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage()),
        );
      } else {
        print("Logout failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  String getTodayDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    int day = now.day;
    String suffix = "th";
    if (day == 1 || day == 21 || day == 31)
      suffix = "st";
    else if (day == 2 || day == 22)
      suffix = "nd";
    else if (day == 3 || day == 23)
      suffix = "rd";

    return "$day$suffix of ${months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 81, 255),
      body: Stack(
        children: [
          // 🔵 BLUE TOP BACKGROUND
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            color: const Color.fromARGB(255, 0, 81, 255),
          ),

          // ⚪ WHITE BOTTOM CONTAINER
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 25, right: 15),
                child: Column(
                  children: [
                    Container(
                      width: 400,
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(217, 213, 213, 213),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyQrPage(),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/images/qricon.png",
                              width: 50,
                              height: 50,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyAnalysisPage(),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/images/analysis.png",
                              width: 50,
                              height: 50,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentGrade(),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/images/study.png",
                              width: 50,
                              height: 50,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowAttendance(),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/images/time.png",
                              width: 50,
                              height: 50,
                            ),
                          ),

                          GestureDetector(
                            onTap: () async {
                              await logoutUser(context);
                            },
                            child: Image.asset(
                              "assets/images/logout.png",
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🖼 CONTENT ON TOP
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 75, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row for user & profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${UserSession.index}",
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );

                          // Auto refresh profile when coming back
                          setState(() => _isProfileLoading = true);
                          await _loadProfile();
                        },

                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImageBytes != null
                              ? MemoryImage(_profileImageBytes!)
                                    as ImageProvider
                              : null,
                          child: _isProfileLoading
                              ? const CircularProgressIndicator()
                              : (_profileImageBytes == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.grey,
                                      )
                                    : null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 400,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 15,
                          right: 20,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Working Schedule",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  getTodayDate(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "09.00 - 18.00",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
