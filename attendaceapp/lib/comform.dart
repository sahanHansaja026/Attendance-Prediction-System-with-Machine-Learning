import 'package:attendaceapp/config/api.dart';
import 'package:attendaceapp/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class ConfirmAttendancePage extends StatefulWidget {
  final String sessionId;
  final String tokenId;

  const ConfirmAttendancePage({
    super.key,
    required this.sessionId,
    required this.tokenId,
  });

  @override
  State<ConfirmAttendancePage> createState() => _ConfirmAttendancePageState();
}

class _ConfirmAttendancePageState extends State<ConfirmAttendancePage> {
  List<Map<String, String>> sessionDataList = [];
  bool isLoading = true;
  final Dio dio = Dio();
  bool isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSession();
  }

  /// 🔥 GET SESSION DATA
  Future<void> fetchSession() async {
    try {
      final response = await dio.get(
        '$API_URL/get_session/${widget.sessionId}',
      );
      final data = response.data;

      setState(() {
        sessionDataList = [
          {"field": "Module Name", "value": data['module_name'] ?? ""},
          {"field": "Location", "value": data['location_name'] ?? ""},
          {"field": "Start Time", "value": data['start_time'] ?? ""},
          {"field": "End Time", "value": data['end_time'] ?? ""},
          {
            "field": "Created At",
            "value": formatDate(data['created_at'] ?? ""),
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching session: $e");
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load session data")),
      );
    }
  }

  /// 🟦 Format Date
  String formatDate(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year} ${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  // --------------------------------------------------------
  // 🔥🔥 GET USER LOCATION
  // --------------------------------------------------------
  Future<Position?> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check GPS enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services")),
      );
      return null;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission is permanently denied"),
        ),
      );
      return null;
    }

    // Get location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // --------------------------------------------------------
  //  🔥🔥 MARK ATTENDANCE
  // --------------------------------------------------------
  Future<void> markAttendance() async {
    Position? pos = await getLocation();
    if (pos == null) return;

    setState(() {
      isButtonLoading = true; // Start loading
    });

    try {
      final response = await dio.post(
        '$API_URL/mark_attendance',
        data: {
          "session_id": widget.sessionId,
          "student_id": UserSession.index,
          "latitude": pos.latitude.toString(),
          "longitude": pos.longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance marked successfully!"),
            backgroundColor: Color.fromARGB(255, 45, 0, 244),
          ),
        );

        // Optional: add delay for buffering before navigation
        await Future.delayed(const Duration(seconds: 1));

        Navigator.pop(context); // Or navigate to Home()
      }
    } catch (e) {
      print("Attendance Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to mark attendance"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isButtonLoading = false; // Stop loading
      });
    }
  }

  // --------------------------------------------------------

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
        title: const Text(
          "Session Info",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      // ---------------- BODY ----------------
      body: Container(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            : buildSessionContent(),
      ),
    );
  }

  // UI TABLE + BUTTON
  Widget buildSessionContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text("Field", style: TextStyle(fontSize: 18)),
                    ),
                    DataColumn(
                      label: Text("Value", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                  rows: sessionDataList.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data["field"] ?? "")),
                        DataCell(Text(data["value"] ?? "")),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isButtonLoading ? null : markAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                    minimumSize: const Size(double.infinity, 50), // full width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isButtonLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "Confirm My Attendance",
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
