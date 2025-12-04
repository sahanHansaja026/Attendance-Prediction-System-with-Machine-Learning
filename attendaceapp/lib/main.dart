import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove debug banner
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false; // loading state
  String message = ""; // success/error message

  // Function to call FastAPI login
  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('http://192.168.1.7:8000/gust_login'); // FastAPI endpoint

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          message = "Login success: ${data['message']}";
        });
      } else {
        setState(() {
          message = "Login failed: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Centered image
                Center(
                  child: Image.asset(
                    'assets/images/login.png',
                    width: 250,
                    height: 250,
                  ),
                ),

                const SizedBox(height: 20),

                // Welcome texts
                const Text(
                  "Welcome To SLTC",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Attendance Management System",
                  style: TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 30),

                // Email field
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                  ),
                ),

                const SizedBox(height: 20),

                // Password field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                ),

                const SizedBox(height: 30),

                // Login button with loading
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            String email = emailController.text;
                            String password = passwordController.text;

                            setState(() {
                              isLoading = true;
                              message = "";
                            });

                            await loginUser(email, password);

                            setState(() {
                              isLoading = false;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 81, 255),
                      minimumSize: const Size(400, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Message display
                if (message.isNotEmpty)
                  Center(
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
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
