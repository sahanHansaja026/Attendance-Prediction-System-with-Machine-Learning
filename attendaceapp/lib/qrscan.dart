import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:io';

class MyQrPage extends StatefulWidget {
  const MyQrPage({super.key});

  @override
  State<MyQrPage> createState() => _MyQrPageState();
}

class _MyQrPageState extends State<MyQrPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = '';
  String pinCode = '';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
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
            Container(
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

            // 4-digit PIN like OTP
            PinCodeTextField(
              appContext: context,
              length: 4,
              onChanged: (value) {},
              onCompleted: (value) {
                pinCode = value;
                print("Entered PIN: $pinCode");
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
                print("QR: $qrText, PIN: $pinCode");
                // TODO: navigate to results page
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
      setState(() {
        qrText = scanData.code!;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
