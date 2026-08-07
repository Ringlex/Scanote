import 'package:fpdart/fpdart.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:note/core/fpdarts.dart';
import 'package:note/data/model/error_detail.dart';

/// Reads the text off a photo, on the device itself.
class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  /// One entry per line the recogniser found, top to bottom.
  TaskEither<ErrorDetail, List<String>> readLines({required String imagePath}) {
    return tryCatchE(
      () async {
        final recognized = await _recognizer.processImage(InputImage.fromFilePath(imagePath));

        return right([
          for (final block in recognized.blocks)
            for (final line in block.lines) line.text,
        ]);
      },
      (error, stackTrace) => ErrorDetail.fatal(throwable: error, stackTrace: stackTrace),
    );
  }

  Future<void> dispose() => _recognizer.close();
}
