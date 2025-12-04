import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

Future<void> LoginUser(String email, String password) async {
  final url = Uri.parse('http://YOUR_BACKEND_IP:8000/login');

  try {
    final response = await http.post(
      url,
      headers: {"content-type": "appication/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    if (response.statusCode == 200) {
      // Login successful
      final data = jsonDecode(response.body);
      print("Login success: $data");
    } else {
      // Login failed
      print("Error: ${response.statusCode} ${response.body}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Makes screen scrollable when keyboard appears
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align left
              children: [
                SizedBox(height: 0),
                // image input
                Center(
                  // image want to in center
                  child: Image.asset(
                    'assets/images/login.png',
                    width: 300,
                    height: 300,
                  ),
                ),

                // text field // left
                Text(
                  "Welcome To SLTC ",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                  textAlign: TextAlign.left,
                ),

                SizedBox(height: 5),

                Text(
                  "Attendance Management System",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                  textAlign: TextAlign.left,
                ),

                // input field
                SizedBox(height: 20.0),

                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                  ),
                ),

                SizedBox(height: 20.0),

                // password input
                TextField(
                  controller: passwordController,
                  obscureText: true, // hide text like dots
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                ),

                SizedBox(height: 50),

                // button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      String email = textController.text;
                      String password =passwordController.text;

                      LoginUser(email, password); // call the API
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                      minimumSize: Size(400, 50),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ), // padding in button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // border redius
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
