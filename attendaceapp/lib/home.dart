import 'package:attendaceapp/session_manager.dart';
import 'package:flutter/material.dart';

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top blue rectangle
          Container(
            height: MediaQuery.of(context).size.height * 0.5, // half of screen
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 0, 81, 255),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),

            child: Padding(
              padding: EdgeInsetsGeometry.only(left: 15, top: 75,right: 15),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcom",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${UserSession.index}",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(100))
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Optional: Add content over the blue rectangle
          Align(
            alignment: Alignment.center,
            child: Text(
              'Dashboard Content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
