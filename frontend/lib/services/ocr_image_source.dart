import 'dart:convert';
import 'dart:typed_data';

class OcrImageSource {
  // ============================================================
  // CREATE OCR INPUT
  // ============================================================

  static Future<String> create(
    Uint8List bytes,
  ) async {
    if (bytes.isEmpty) {
      throw Exception(
        "Cannot create OCR input from empty image.",
      );
    }

    /*
     * Flutter Web:
     *
     * Tesseract can receive the image as a data URL.
     *
     * The image is NOT uploaded anywhere here.
     * The bytes remain inside the browser.
     */

    final base64Image =
        base64Encode(bytes);

    return "data:image/jpeg;base64,$base64Image";
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  static Future<void> dispose(
    String source,
  ) async {
    /*
     * Nothing needs to be deleted for Web.
     *
     * The OCR input is simply a data URL held in memory.
     */
  }
}