import 'package:fpdart/fpdart.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/model/error_detail.dart';

class BarcodeService {
  final BarcodeScanner _scanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  TaskEither<ErrorDetail, String?> readFirstCode({required String imagePath}) {
    return tryCatchE(() async {
      final codes = await _scanner.processImage(InputImage.fromFilePath(imagePath));

      return right(codes.isEmpty ? null : codes.first.rawValue);
    }, (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace));
  }

  Future<void> dispose() => _scanner.close();
}
