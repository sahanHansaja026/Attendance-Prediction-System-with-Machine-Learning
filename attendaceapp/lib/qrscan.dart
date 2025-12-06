import 'dart:convert';
import 'dart:io';

import 'package:attendaceapp/config/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MyQrPage extends StatefulWidget {
  const MyQrPage({super.key});

  @override
  State<MyQrPage> createState() => _MyQrPageState();
}

class _MyQrPageState extends State<MyQrPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = '';
  String sessionPin = ''; // The 4-digit PIN acts as session ID

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) controller?.pauseCamera();
    controller?.resumeCamera();
  }

  // Send session PIN as session_id to backend
  Future<void> _verifyAttendance(int sessionId) async {
    final url = Uri.parse('$API_URL/attendance/verify');
    print("Sending POST request with sessionId=$sessionId");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"session_id": sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Verified: ${data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance verified!")),
        );
      } else {
        final data = jsonDecode(response.body);
        print("Error: ${data['detail']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['detail'])),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error")),
      );
    }
  }

  void _handleQrScan(String qr) {
    final scannedPin = int.tryParse(qr);
    if (scannedPin != null) {
      setState(() {
        sessionPin = qr;
      });
      _verifyAttendance(scannedPin);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid QR code")),
      );
    }
  }

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
        title: const SizedBox(),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 0, 81, 255),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Scanner frame
            SizedBox(
              width: 300,
              height: 300,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 20,
                  borderLength: 30,
                  borderWidth: 8,
                  cutOutSize: 300,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4-digit PIN input (manual session ID)
            PinCodeTextField(
              appContext: context,
              length: 4,
              onChanged: (value) {
                sessionPin = value;
              },
              onCompleted: (value) {
                sessionPin = value;
                print("Entered session PIN: $sessionPin");
              },
              keyboardType: TextInputType.number,
              textStyle: const TextStyle(color: Colors.white, fontSize: 20),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 60,
                fieldWidth: 60,
                activeFillColor: Colors.white.withOpacity(0.2),
                inactiveFillColor: Colors.white.withOpacity(0.1),
                selectedFillColor: Colors.white.withOpacity(0.3),
                activeColor: Colors.white,
                selectedColor: Colors.white,
                inactiveColor: Colors.white70,
              ),
              cursorColor: Colors.white,
              enableActiveFill: true,
            ),

            const SizedBox(height: 20),

            // Enter button
            ElevatedButton(
              onPressed: () {
                final sessionId = int.tryParse(sessionPin);
                if (sessionId == null || sessionPin.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid 4-digit PIN")),
                  );
                  return;
                }
                _verifyAttendance(sessionId);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "Enter",
                style: TextStyle(color: Color.fromARGB(255, 0, 81, 255), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        qrText = scanData.code!;
        _handleQrScan(qrText); // auto verify on scan
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
