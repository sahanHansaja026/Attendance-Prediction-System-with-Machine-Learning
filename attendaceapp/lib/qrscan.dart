import 'dart:convert';
import 'dart:io';

import 'package:attendaceapp/comform.dart';
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
  String sessionPin = '';
  bool _isProcessingQr = false; // prevents multiple scans

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) controller?.pauseCamera();
    controller?.resumeCamera();
  }

  // Verify attendance by sending PIN to backend
  Future<void> _verifyAttendance(String pin) async {
    final url = Uri.parse('$API_URL/attendance/verify');
    print("Sending POST request with PIN=$pin");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pin": pin}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Navigate to ConfirmAttendancePage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmAttendancePage(
              sessionId: data['session_id'].toString(),
              tokenId: data['token_id'].toString(),
            ),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['detail'])));
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Network error")));
    }
  }

  // Handle scanned QR
  Future<void> _handleQrScan(String qr) async {
    if (_isProcessingQr) return; // ignore if already processing
    _isProcessingQr = true;
    await controller?.pauseCamera(); // pause camera during processing

    qr = qr.trim();
    print("Scanned QR: $qr"); // debug console

    Uri? uri = Uri.tryParse(qr);

    if (uri != null && uri.hasQuery) {
      List<String> segments = uri.pathSegments;
      String? sessionId;
      if (segments.length >= 3 && segments[segments.length - 2] == 'session') {
        sessionId = segments.last;
      }

      String? pin = uri.queryParameters['otp'];
      String? token = uri.queryParameters['token'];

      print("Parsed session_id: $sessionId, pin: $pin, token: $token");

      if (pin != null && sessionId != null) {
        setState(() => sessionPin = pin);
        await _verifyAttendance(pin);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid QR content")));
      }
    } else if (qr.length == 4 && int.tryParse(qr) != null) {
      setState(() => sessionPin = qr);
      await _verifyAttendance(qr);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid QR code")));
    }

    _isProcessingQr = false;
    await controller?.resumeCamera(); // resume camera after processing
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Container(
                color: const Color.fromARGB(255, 0, 81, 255),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 128),
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
                    const SizedBox(height: 70),
                    PinCodeTextField(
                      appContext: context,
                      length: 4,
                      onChanged: (value) => sessionPin = value,
                      onCompleted: (value) {
                        sessionPin = value;
                        print("Entered PIN: $sessionPin");
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
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        if (sessionPin.length != 4 || int.tryParse(sessionPin) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Enter a valid 4-digit PIN")),
                          );
                          return;
                        }
                        _verifyAttendance(sessionPin);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Enter",
                        style: TextStyle(color: Color.fromARGB(255, 0, 81, 255), fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
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
        _handleQrScan(scanData.code!);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
