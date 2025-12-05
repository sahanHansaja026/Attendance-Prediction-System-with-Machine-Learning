import 'dart:convert';
import 'package:attendaceapp/config/api.dart';
import 'package:attendaceapp/home.dart';
import 'package:attendaceapp/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserSession.loadSession();  

  runApp(MainApp(isLoggedIn: UserSession.isLoggedIn()));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? MyDashboard() : MyHomePage(),
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

  bool isLoading = false;
  String message = "";

  Future<void> loginUser(String email, String password) async {
    final url = Uri.parse('$API_URL/gust_login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", data["access_token"]);
        await prefs.setString("refresh_token", data["refresh_token"]);
        await prefs.setString("name", data["user"]["name"]);
        await prefs.setString("email", data["user"]["email"]);
        await prefs.setString("index", data["user"]["index"]);

        await UserSession.loadSession();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyDashboard()),
        );
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
                Center(
                  child: Image.asset(
                    'assets/images/login.png',
                    width: 250,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 20),
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
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                              message = "";
                            });

                            await loginUser(
                                emailController.text, passwordController.text);

                            setState(() => isLoading = false);
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
