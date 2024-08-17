// buildBarcode 함수에서 url 출력하는 함수 사용 중
// 해당 함수 내부의 launchUrl 함수를 사용해 해당 url을 처리할 수 있을 것으로 보임

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // QR 코드 스캐너 패키지
import 'package:qrcode_scanner_camera/page/error/scanner_error_widget.dart'; // 스캐너 오류 처리를 위한 위젯
import 'package:url_launcher/url_launcher.dart'; // URL을 열기 위한 패키지

class BarcodeScannerSimple extends StatefulWidget {
  const BarcodeScannerSimple({super.key});

  @override
  State<BarcodeScannerSimple> createState() =>
      _BarcodeScannerSimpleState(); // State를 생성
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode; // 스캔된 바코드를 저장하는 변수

  Widget _buildBarcode(Barcode? value) {
    // 바코드를 스캔한 결과를 처리하는 함수
    if (value == null) {
      return const Text(
        'Scan something!', // 스캔된 바코드가 없을 경우 표시할 텍스트
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }
    final Uri url = Uri.parse(value.displayValue!); // 바코드의 값을 URL로 파싱
    _launchUrl(url); // URL을 열기 위한 함수 호출
    return Text(
      value.displayValue ?? 'No display value.', // 바코드의 값을 텍스트로 표시
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    // 바코드를 스캔했을 때 호출되는 함수
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull; // 첫 번째 바코드만 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI를 빌드하는 함수
    return Scaffold(
      backgroundColor: Colors.black, // 화면 배경을 검정색으로 설정
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleBarcode, // 바코드가 스캔되었을 때 호출되는 콜백 함수
            errorBuilder: (context, error, child) {
              // 스캐너 오류가 발생했을 때 호출되는 함수
              return ScannerErrorWidget(error: error); // 오류 위젯을 표시
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: Colors.black.withOpacity(0.4), // 반투명 검정색 배경
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // 자식 위젯들을 균등하게 배치
                children: [
                  Expanded(
                      child: Center(
                          child: _buildBarcode(_barcode))), // 스캔된 바코드 결과 표시
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(Uri url) async {
  // 주어진 URL을 여는 함수
  if (!await launchUrl(url)) {
    // URL을 여는 데 실패한 경우
    throw Exception('Could not launch $url'); // 예외를 발생시킴
  }
}
