import 'dart:convert';
import 'package:attendaceapp/config/api.dart';
import 'package:attendaceapp/mymap.dart';
import 'package:attendaceapp/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class Attendance {
  final String locationName;
  final String courseName;
  final String latitude;
  final String longitude;
  final DateTime markAt;

  Attendance({
    required this.locationName,
    required this.courseName,
    required this.latitude,
    required this.longitude,
    required this.markAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      locationName: json['location_name'],
      courseName: json['course_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      markAt: DateTime.parse(json['mark_at']),
    );
  }
}

Future<List<Attendance>> fetchAttendance(String studentId) async {
  final url = Uri.parse('${API_URL}/attendance_info/$studentId');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((att) => Attendance.fromJson(att)).toList();
  } else {
    throw Exception("Failed to load attendance");
  }
}

class ShowAttendance extends StatefulWidget {
  const ShowAttendance({super.key});

  @override
  State<ShowAttendance> createState() => _ShowAttendanceState();
}

class _ShowAttendanceState extends State<ShowAttendance> {
  late Future<List<Attendance>> futureAttendance;

  @override
  void initState() {
    super.initState();
    final String studentId = UserSession.index ?? "default_id";
    futureAttendance = fetchAttendance(studentId);
  }

  void openMapPage(String latitude, String longitude) {
    final double lat = double.tryParse(latitude) ?? 0.0;
    final double lng = double.tryParse(longitude) ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyMap(latitude: lat, longitude: lng),
      ),
    );
  }

  // Format date like "4th July 2025" and time like "14:30"
  String formatDateTime(DateTime dt) {
    final daySuffix = (int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    };

    final formattedDate =
        "${dt.day}${daySuffix(dt.day)} ${DateFormat('MMMM yyyy').format(dt)}";
    final formattedTime = DateFormat('HH:mm').format(dt);

    return "$formattedDate, $formattedTime";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        title: const Text(
          "Attendance Records",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Attendance>>(
        future: futureAttendance,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance found'));
          } else {
            final attendances = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: attendances.map((att) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 92, 92, 92).withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_city,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        att.courseName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.place,
                                size: 16,
                                color: Color.fromARGB(255, 78, 78, 78),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(
                                att.locationName,
                                style: const TextStyle(color: Color.fromARGB(255, 78, 78, 78)),
                              )),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color.fromARGB(255, 78, 78, 78),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatDateTime(att.markAt),
                                style: const TextStyle(color: Color.fromARGB(255, 78, 78, 78)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () =>
                            openMapPage(att.latitude, att.longitude),
                        icon: const Icon(Icons.location_pin, color: Colors.white),
                        label: const Text(
                          "Map",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}


