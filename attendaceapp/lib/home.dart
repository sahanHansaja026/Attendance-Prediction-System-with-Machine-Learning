import 'dart:convert';

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
  @override
  Future<void> logoutUser(BuildContext context) async {
    try {
      final token = UserSession.accessToken;

      final response = await http.post(
        Uri.parse('$API_URL/gust_logout'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": UserSession.email?.trim(), // send email in JSON body
        }),
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

    // List of month names
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

    // Get day with suffix (st, nd, rd, th)
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
                padding: EdgeInsets.only(left: 15, top: 25, right: 15),
                child: Column(
                  children: [
                    Container(
                      width: 400,
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(217, 213, 213, 213),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      // set of icons
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 10),

                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyQrPage(),
                                  ),
                                );
                              },

                              // icon for qrcode
                              child: Image.asset(
                                "assets/images/qricon.png",
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 10),
                            child: GestureDetector(
                              onTap: () async {
                                await logoutUser(context);
                              },
                              // icon for logout
                              child: Image.asset(
                                "assets/images/analysis.png",
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentGrade(),
                                  ),
                                );
                              },

                              // icon for grade
                              child: Image.asset(
                                "assets/images/study.png",
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 10),
                            child: GestureDetector(
                              child: Image.asset(
                                "assets/images/time.png",
                                width: 50,
                                height: 50,
                              ),
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
                      // user welcome
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${UserSession.index}",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to another page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage.ProfileEditPage(),
                            ), // replace with your page
                          );
                        },
                        // profile circle
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 400,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, top: 15, right: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Working Schedule",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                // todya date like this format
                                Text(
                                  getTodayDate(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "09.00 - 18.00",
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
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
