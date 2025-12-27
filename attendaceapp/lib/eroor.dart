import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;

  const ErrorPage({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // deep blue background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/error.png", // your big error image
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Oops!",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D47A1),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Go Back",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
