import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImagePreprocessor {
  static Future<Uint8List> preprocess(
    Uint8List bytes,
  ) async {
    final decoded =
        img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception(
        "Could not decode image.",
      );
    }

    img.Image image =
        decoded;

    const maxWidth =
        2400;

    if (image.width >
        maxWidth) {
      image =
          img.copyResize(
        image,
        width:
            maxWidth,
      );
    }

    image =
        img.adjustColor(
      image,
      contrast:
          1.15,
    );

    image =
        img.convolution(
      image,
      filter: [
        0,
        -1,
        0,
        -1,
        5,
        -1,
        0,
        -1,
        0,
      ],
    );

    final encoded =
        img.encodeJpg(
      image,
      quality:
          92,
    );

    return Uint8List.fromList(
      encoded,
    );
  }
}