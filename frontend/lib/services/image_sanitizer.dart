import 'dart:typed_data';

import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image/image.dart' as img;

import 'ocr_image_source.dart';

class ImageSanitizer {
  // ============================================================
  // LIMITS
  // ============================================================

  static const int maxInputBytes =
      15 * 1024 * 1024;

  static const int maxPixels =
      12 * 1000 * 1000;

  static const int jpegQuality = 95;

  // Extra pixels around a detected sensitive word.
  static const int redactionPadding = 8;

  // Words whose vertical centers are within this distance
  // are treated as belonging to the same OCR line.
  static const int lineGroupingTolerance = 15;

  // ============================================================
  // MAIN SANITIZATION
  // ============================================================

  static Future<Uint8List> sanitize(
    Uint8List imageBytes,
  ) async {
    print("========================================");
    print("SANITIZATION STARTED");
    print("========================================");

    // ==========================================================
    // BASIC VALIDATION
    // ==========================================================

    if (imageBytes.isEmpty) {
      throw Exception(
        "Sanitization failed: image is empty.",
      );
    }

    if (imageBytes.length > maxInputBytes) {
      throw Exception(
        "Sanitization failed: image is too large.",
      );
    }

    // ==========================================================
    // DECODE IMAGE
    // ==========================================================

    final image = img.decodeJpg(
      imageBytes,
    );

    if (image == null) {
      throw Exception(
        "Sanitization failed: invalid JPEG image.",
      );
    }

    if (image.width <= 0 ||
        image.height <= 0) {
      throw Exception(
        "Sanitization failed: invalid image dimensions.",
      );
    }

    final pixelCount =
        image.width * image.height;

    if (pixelCount > maxPixels) {
      throw Exception(
        "Sanitization failed: image resolution is too large.",
      );
    }

    print(
      "Image size: "
      "${image.width} x ${image.height}",
    );

    // ==========================================================
    // CREATE OCR INPUT
    // ==========================================================

    final ocrInput =
        await OcrImageSource.create(
      imageBytes,
    );

    try {
      // ========================================================
      // RUN OCR
      // ========================================================

      print(
        "Running local OCR for sanitization...",
      );

      final hocr =
          await FlutterTesseractOcr.extractHocr(
        ocrInput,
        language: "eng",
        args: {
          "preserve_interword_spaces": "1",

          // Required by the Web implementation.
          "tessjs_create_hocr": "1",
        },
      );

      if (hocr.trim().isEmpty) {
        throw Exception(
          "Sanitization failed: OCR returned empty HOCR.",
        );
      }

      print(
        "HOCR length: ${hocr.length}",
      );

      if (!hocr.contains("ocrx_word")) {
        throw Exception(
          "Sanitization failed: OCR did not return "
          "word bounding boxes.",
        );
      }

      print(
        "OCR returned word bounding boxes.",
      );

      // ========================================================
      // FIND SENSITIVE REGIONS
      // ========================================================

      final regions =
          _findSensitiveRegions(
        hocr,
      );

      print(
        "Sensitive regions detected: "
        "${regions.length}",
      );

      // ========================================================
      // REDACT SENSITIVE REGIONS
      // ========================================================

      for (final region in regions) {
        final left =
            _clamp(
          region.left - redactionPadding,
          0,
          image.width - 1,
        );

        final top =
            _clamp(
          region.top - redactionPadding,
          0,
          image.height - 1,
        );

        final right =
            _clamp(
          region.right + redactionPadding,
          0,
          image.width - 1,
        );

        final bottom =
            _clamp(
          region.bottom + redactionPadding,
          0,
          image.height - 1,
        );

        if (right <= left ||
            bottom <= top) {
          continue;
        }

        img.fillRect(
          image,
          x1: left,
          y1: top,
          x2: right,
          y2: bottom,
          color: img.ColorRgb8(
            0,
            0,
            0,
          ),
          alphaBlend: false,
        );

        print(
          "Redacted region: "
          "($left, $top) -> ($right, $bottom)",
        );
      }

      // ========================================================
      // ENCODE SANITIZED IMAGE
      // ========================================================

      final encoded =
          img.encodeJpg(
        image,
        quality: jpegQuality,
      );

      if (encoded.isEmpty) {
        throw Exception(
          "Sanitization failed: could not encode image.",
        );
      }

      final sanitized =
          Uint8List.fromList(
        encoded,
      );

      print(
        "Original bytes: "
        "${imageBytes.length}",
      );

      print(
        "Sanitized bytes: "
        "${sanitized.length}",
      );

      print("========================================");

      if (regions.isEmpty) {
        print(
          "SANITIZATION COMPLETED",
        );

        print(
          "No configured sensitive information "
          "was detected.",
        );
      } else {
        print(
          "SANITIZATION COMPLETED",
        );

        print(
          "Redacted "
          "${regions.length} sensitive region(s).",
        );
      }

      print(
        "The sanitized image is the image "
        "that should be sent over the network.",
      );

      print("========================================");

      return sanitized;
    } finally {
      await OcrImageSource.dispose(
        ocrInput,
      );
    }
  }

  // ============================================================
  // FIND SENSITIVE REGIONS
  // ============================================================

  static List<_SensitiveRegion>
      _findSensitiveRegions(
    String hocr,
  ) {
    final words =
        _parseWords(
      hocr,
    );

    if (words.isEmpty) {
      print(
        "OCR returned no usable words.",
      );

      return [];
    }

    print(
      "OCR words parsed: "
      "${words.length}",
    );

    // ----------------------------------------------------------
    // SORT WORDS
    //
    // First by vertical position, then by horizontal position.
    // ----------------------------------------------------------

    words.sort(
      (a, b) {
        final vertical =
            a.top.compareTo(
          b.top,
        );

        if (vertical != 0) {
          return vertical;
        }

        return a.left.compareTo(
          b.left,
        );
      },
    );

    // ----------------------------------------------------------
    // GROUP WORDS INTO APPROXIMATE LINES
    // ----------------------------------------------------------

    final lines =
        <List<_OcrWord>>[];

    for (final word in words) {
      List<_OcrWord>? matchingLine;

      for (final line in lines) {
        if (_belongsToLine(
          word,
          line,
        )) {
          matchingLine = line;
          break;
        }
      }

      if (matchingLine == null) {
        lines.add([
          word,
        ]);
      } else {
        matchingLine.add(
          word,
        );
      }
    }

    // Keep words left-to-right inside every line.
    for (final line in lines) {
      line.sort(
        (a, b) =>
            a.left.compareTo(
          b.left,
        ),
      );
    }

    print(
      "OCR lines reconstructed: "
      "${lines.length}",
    );

    // ----------------------------------------------------------
    // ANALYZE EACH LINE
    // ----------------------------------------------------------

    final regions =
        <_SensitiveRegion>[];

    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }

      final lineText =
          line
              .map(
                (word) => word.text,
              )
              .join(" ");

      print(
        "OCR line: $lineText",
      );

      final sensitiveMatches =
          _findSensitiveMatches(
        lineText,
      );

      if (sensitiveMatches.isEmpty) {
        continue;
      }

      // --------------------------------------------------------
      // Build character positions for every OCR word.
      // --------------------------------------------------------

      int textPosition = 0;

      for (final word in line) {
        final start =
            textPosition;

        final end =
            start + word.text.length;

        for (final match
            in sensitiveMatches) {
          if (_rangesOverlap(
            start,
            end,
            match.start,
            match.end,
          )) {
            regions.add(
              _SensitiveRegion(
                left: word.left,
                top: word.top,
                right: word.right,
                bottom: word.bottom,
              ),
            );

            break;
          }
        }

        textPosition =
            end + 1;
      }
    }

    return _mergeRegions(
      regions,
    );
  }

  // ============================================================
  // PARSE OCR WORDS
  // ============================================================

  static List<_OcrWord>
      _parseWords(
    String hocr,
  ) {
    final result =
        <_OcrWord>[];

    /*
     * We intentionally parse OCR words directly rather than
     * trying to parse nested <ocr_line> elements.
     *
     * HOCR structure is commonly:
     *
     * <span class='ocr_line'>
     *   <span class='ocrx_word' ...>Phone:</span>
     *   <span class='ocrx_word' ...>080-12345678</span>
     * </span>
     *
     * Parsing individual words avoids nested-span regex problems.
     */

    final wordRegex =
        RegExp(
      r'''<span[^>]*class=['"][^'"]*\bocrx_word\b[^'"]*['"][^>]*title=['"]([^'"]*)['"][^>]*>(.*?)</span>''',
      dotAll: true,
      caseSensitive: false,
    );

    for (final match
        in wordRegex.allMatches(
      hocr,
    )) {
      final title =
          match.group(1) ?? "";

      final rawText =
          match.group(2) ?? "";

      final text =
          _stripHtml(
        rawText,
      ).trim();

      if (text.isEmpty) {
        continue;
      }

      final bbox =
          _parseBoundingBox(
        title,
      );

      if (bbox == null) {
        continue;
      }

      result.add(
        _OcrWord(
          text: text,
          left: bbox[0],
          top: bbox[1],
          right: bbox[2],
          bottom: bbox[3],
        ),
      );
    }

    return result;
  }

  // ============================================================
  // DETERMINE WHETHER WORD BELONGS TO OCR LINE
  // ============================================================

  static bool _belongsToLine(
    _OcrWord word,
    List<_OcrWord> line,
  ) {
    if (line.isEmpty) {
      return false;
    }

    final wordCenterY =
        (word.top + word.bottom) /
            2;

    for (final existing
        in line) {
      final existingCenterY =
          (existing.top +
                  existing.bottom) /
              2;

      final difference =
          (wordCenterY -
                  existingCenterY)
              .abs();

      if (difference <=
          lineGroupingTolerance) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // BOUNDING BOX
  // ============================================================

  static List<int>? _parseBoundingBox(
    String title,
  ) {
    final match =
        RegExp(
      r'''\bbbox\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\b''',
      caseSensitive: false,
    ).firstMatch(
      title,
    );

    if (match == null) {
      return null;
    }

    return [
      int.parse(
        match.group(1)!,
      ),
      int.parse(
        match.group(2)!,
      ),
      int.parse(
        match.group(3)!,
      ),
      int.parse(
        match.group(4)!,
      ),
    ];
  }

  // ============================================================
  // SENSITIVE PATTERNS
  // ============================================================

  static List<Match>
      _findSensitiveMatches(
    String text,
  ) {
    final matches =
        <Match>[];

    // ==========================================================
    // EMAIL ADDRESS
    // ==========================================================

    matches.addAll(
      RegExp(
        r'''\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b''',
        caseSensitive: false,
      ).allMatches(
        text,
      ),
    );

    // ==========================================================
    // UPI ID
    //
    // Examples:
    //
    // name@oksbi
    // user123@upi
    // person@paytm
    // ==========================================================

    matches.addAll(
      RegExp(
        r'''\b[A-Z0-9._-]+@[A-Z0-9._-]+\b''',
        caseSensitive: false,
      ).allMatches(
        text,
      ),
    );

    // ==========================================================
    // PHONE NUMBER
    //
    // Only activate when the line contains a phone/contact
    // label. This avoids accidentally redacting ordinary
    // receipt dates and prices.
    // ==========================================================

    final hasPhoneLabel =
        RegExp(
      r'''\b(phone|mobile|contact|tel|telephone|whatsapp)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasPhoneLabel) {
      matches.addAll(
        RegExp(
          r'''(?<!\d)\+?\d[\d\s().-]{7,}\d(?!\d)''',
        ).allMatches(
          text,
        ),
      );
    }

    // ==========================================================
    // CREDIT / DEBIT CARD
    // ==========================================================

    final hasCardLabel =
        RegExp(
      r'''\b(card|credit card|debit card|card no|card number)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasCardLabel) {
      matches.addAll(
        RegExp(
          r'''(?<!\d)(?:\d[ -]?){13,19}(?!\d)''',
        ).allMatches(
          text,
        ),
      );
    }

    // ==========================================================
    // AADHAAR
    // ==========================================================

    final hasAadhaarLabel =
        RegExp(
      r'''\b(aadhaar|aadhar|uid|uidai)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasAadhaarLabel) {
      matches.addAll(
        RegExp(
          r'''(?<!\d)\d{4}[\s-]?\d{4}[\s-]?\d{4}(?!\d)''',
        ).allMatches(
          text,
        ),
      );
    }

    // ==========================================================
    // PAN
    // ==========================================================

    final hasPanLabel =
        RegExp(
      r'''\b(pan|permanent account number)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasPanLabel) {
      matches.addAll(
        RegExp(
          r'''\b[A-Z]{5}\d{4}[A-Z]\b''',
          caseSensitive: false,
        ).allMatches(
          text,
        ),
      );
    }

    // ==========================================================
    // BANK ACCOUNT
    // ==========================================================

    final hasAccountLabel =
        RegExp(
      r'''\b(account|account no|account number|bank account)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasAccountLabel) {
      matches.addAll(
        RegExp(
          r'''(?<!\d)\d{9,18}(?!\d)''',
        ).allMatches(
          text,
        ),
      );
    }

    // ==========================================================
    // UPI TRANSACTION ID
    // ==========================================================

    final hasUpiTransactionLabel =
        RegExp(
      r'''\b(upi transaction|upi transaction id|upi ref|upi reference)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasUpiTransactionLabel) {
      matches.addAll(
        RegExp(
          r'''(?<!\d)\d{6,30}(?!\d)''',
        ).allMatches(
          text,
        ),
      );
    }

    // ==========================================================
    // BANK REFERENCE / TRANSACTION REFERENCE
    // ==========================================================

    final hasReferenceLabel =
        RegExp(
      r'''\b(bank ref|bank reference|reference no|reference number|ref no|ref number|transaction id|transaction number|transaction no|rrn)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasReferenceLabel) {
      matches.addAll(
        RegExp(
          r'''(?<!\d)\d{6,30}(?!\d)''',
        ).allMatches(
          text,
        ),
      );
    }

    // ==========================================================
    // CVV / CVC
    // ==========================================================

    final hasCvvLabel =
        RegExp(
      r'''\b(cvv|cvc|security code)\b''',
      caseSensitive: false,
    ).hasMatch(
      text,
    );

    if (hasCvvLabel) {
      matches.addAll(
        RegExp(
          r'''(?<!\d)\d{3,4}(?!\d)''',
        ).allMatches(
          text,
        ),
      );
    }

    return matches;
  }

  // ============================================================
  // RANGE OVERLAP
  // ============================================================

  static bool _rangesOverlap(
    int aStart,
    int aEnd,
    int bStart,
    int bEnd,
  ) {
    return aStart < bEnd &&
        bStart < aEnd;
  }

  // ============================================================
  // HTML CLEANING
  // ============================================================

  static String _stripHtml(
    String value,
  ) {
    return value
        .replaceAll(
          RegExp(
            r'<[^>]+>',
          ),
          '',
        )
        .replaceAll(
          '&amp;',
          '&',
        )
        .replaceAll(
          '&lt;',
          '<',
        )
        .replaceAll(
          '&gt;',
          '>',
        )
        .replaceAll(
          '&quot;',
          '"',
        )
        .replaceAll(
          '&#39;',
          "'",
        )
        .replaceAll(
          '&#x27;',
          "'",
        )
        .replaceAll(
          '&nbsp;',
          ' ',
        );
  }

  // ============================================================
  // MERGE OVERLAPPING REGIONS
  // ============================================================

  static List<_SensitiveRegion>
      _mergeRegions(
    List<_SensitiveRegion> regions,
  ) {
    if (regions.isEmpty) {
      return [];
    }

    regions.sort(
      (a, b) {
        final topCompare =
            a.top.compareTo(
          b.top,
        );

        if (topCompare != 0) {
          return topCompare;
        }

        return a.left.compareTo(
          b.left,
        );
      },
    );

    final merged =
        <_SensitiveRegion>[];

    for (final region
        in regions) {
      if (merged.isEmpty) {
        merged.add(
          region,
        );
        continue;
      }

      final previous =
          merged.last;

      final overlaps =
          region.left <=
              previous.right &&
          region.right >=
              previous.left &&
          region.top <=
              previous.bottom &&
          region.bottom >=
              previous.top;

      if (overlaps) {
        merged[
            merged.length - 1] =
            _SensitiveRegion(
          left:
              previous.left <
                      region.left
                  ? previous.left
                  : region.left,

          top:
              previous.top <
                      region.top
                  ? previous.top
                  : region.top,

          right:
              previous.right >
                      region.right
                  ? previous.right
                  : region.right,

          bottom:
              previous.bottom >
                      region.bottom
                  ? previous.bottom
                  : region.bottom,
        );
      } else {
        merged.add(
          region,
        );
      }
    }

    return merged;
  }

  // ============================================================
  // CLAMP
  // ============================================================

  static int _clamp(
    int value,
    int min,
    int max,
  ) {
    if (value < min) {
      return min;
    }

    if (value > max) {
      return max;
    }

    return value;
  }
}

// ============================================================
// OCR WORD
// ============================================================

class _OcrWord {
  final String text;

  final int left;
  final int top;
  final int right;
  final int bottom;

  const _OcrWord({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

// ============================================================
// SENSITIVE REGION
// ============================================================

class _SensitiveRegion {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const _SensitiveRegion({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}