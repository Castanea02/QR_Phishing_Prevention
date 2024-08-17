import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 갤러리에서 이미지를 선택하기 위한 패키지
import 'package:mobile_scanner/mobile_scanner.dart'; // QR 코드 스캐닝을 위한 패키지
import '/page/barcode_scanner_simple.dart'; // QR 코드 스캐너 화면을 정의하는 파일
import '/page/MapSample.dart'; // 지도 화면을 정의하는 파일

void main() async {
  runApp(
    const MaterialApp(
      title: 'QR Code Scan', // 애플리케이션 제목 설정
      home: BarcodeScannerScreen(), // 앱이 시작될 때 표시할 첫 화면 지정
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
    ),
  );
}

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 버튼의 크기와 스타일을 정의
    const buttonWidth = 120.0;
    const buttonHeight = 50.0;
    const buttonOpacity = 0.5; // 버튼의 투명도 설정 (50% 투명)

    return Scaffold(
      body: Stack(
        children: [
          const BarcodeScannerSimple(), // QR 코드 스캔 화면을 표시
          Positioned(
            bottom: 120, // 화면 하단에서의 위치 설정
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 버튼들 간격 조정
              children: [
                Opacity(
                  opacity: buttonOpacity, // 버튼의 투명도 적용
                  child: SizedBox(
                    width: buttonWidth, // 버튼의 너비 설정
                    height: buttonHeight, // 버튼의 높이 설정
                    child: ElevatedButton(
                      onPressed: () =>
                          imageSelect(context), // 갤러리에서 이미지 선택하는 함수 호출
                      child: const Text('Gallery'), // 버튼 텍스트
                    ),
                  ),
                ),
                Opacity(
                  opacity: buttonOpacity, // 버튼의 투명도 적용
                  child: SizedBox(
                    width: buttonWidth, // 버튼의 너비 설정
                    height: buttonHeight, // 버튼의 높이 설정
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MapSample()), // 지도 화면으로 이동
                        );
                      },
                      child: const Text('Map'), // 버튼 텍스트
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> imageSelect(BuildContext context) async {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: true, // 플래시 사용 여부 설정
    useNewCameraSelector: true, // 새로운 카메라 선택자 사용
    returnImage: true, // 이미지 반환 여부 설정
  );
  final ImagePicker picker =
      ImagePicker(); // 갤러리에서 이미지를 선택하기 위한 ImagePicker 인스턴스 생성

  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery, // 이미지를 갤러리에서 선택
  );

  if (image == null) {
    return; // 사용자가 이미지를 선택하지 않은 경우 함수 종료
  }

  final BarcodeCapture? barcodes = await controller.analyzeImage(
    image.path, // 선택한 이미지의 경로를 통해 바코드를 분석
  );
  if (!context.mounted) {
    return; // 만약 context가 유효하지 않다면 함수 종료
  }

  late final String url;
  if (barcodes != null) {
    print('-------------');
    final Uri url0 = Uri.parse(
        barcodes.barcodes.firstOrNull!.displayValue!); // 바코드의 첫 번째 값을 URL로 파싱
    url = url0.toString(); // URL 문자열로 변환
    print(url); // 콘솔에 URL 출력
    print('--------------');
  }

  // 바코드 스캔 결과에 따라 SnackBar를 표시
  final SnackBar snackbar = barcodes != null
      ? SnackBar(
          content: Text(url), // 스캔된 URL을 표시
          backgroundColor: Colors.green, // 성공 시 녹색 배경
        )
      : const SnackBar(
          content: Text('QR code를 찾을 수 없습니다.'), // 실패 시 메시지 표시
          backgroundColor: Colors.red, // 실패 시 빨간 배경
        );

  ScaffoldMessenger.of(context).showSnackBar(snackbar); // 스낵바를 화면에 표시
}
