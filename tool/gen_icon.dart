import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Builds launcher PNGs from `icon2.jpg`.
///
/// Adaptive icon canvas is 108 dp. Content is scaled to occupy 74 dp
/// (74/108 of the canvas) so the volcano sits inside the mask without
/// filling edge-to-edge. The remaining ring is filled with a colour
/// sampled from the source corners.
void main() {
  const String src = 'assets/Lava_Fortune_additional_assets/icon2.jpg';
  const int canvas = 1024;
  // 74 dp of a 108 dp adaptive canvas.
  final int content = (canvas * 74 / 108).round();

  final File file = File(src);
  if (!file.existsSync()) {
    stderr.writeln('Source icon not found: $src');
    exit(1);
  }

  final img.Image? decoded = img.decodeImage(file.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Failed to decode source image.');
    exit(1);
  }

  final img.Image square = _coverSquare(decoded, canvas);
  Directory('assets/generated').createSync(recursive: true);
  File('assets/generated/app_icon.png').writeAsBytesSync(img.encodePng(square));

  final img.Color bg = _cornerAverage(square);
  final img.Image foreground = img.Image(width: canvas, height: canvas);
  img.fill(foreground, color: bg);

  final img.Image scaled = img.copyResize(
    square,
    width: content,
    height: content,
    interpolation: img.Interpolation.cubic,
  );
  final int origin = ((canvas - content) / 2).round();
  img.compositeImage(foreground, scaled, dstX: origin, dstY: origin);

  File('assets/generated/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(foreground));
  File('assets/generated/app_icon_source.png')
      .writeAsBytesSync(img.encodePng(square));

  stdout.writeln(
    'Icons generated in assets/generated/ (content ${content}px / ${canvas}px = 74dp of 108dp)',
  );
}

img.Image _coverSquare(img.Image src, int size) {
  final int side = math.min(src.width, src.height);
  final int x = ((src.width - side) / 2).round();
  final int y = ((src.height - side) / 2).round();
  final img.Image cropped = img.copyCrop(src, x: x, y: y, width: side, height: side);
  return img.copyResize(
    cropped,
    width: size,
    height: size,
    interpolation: img.Interpolation.cubic,
  );
}

img.Color _cornerAverage(img.Image src) {
  final List<img.Pixel> samples = <img.Pixel>[
    src.getPixel(8, 8),
    src.getPixel(src.width - 9, 8),
    src.getPixel(8, src.height - 9),
    src.getPixel(src.width - 9, src.height - 9),
  ];
  int r = 0, g = 0, b = 0;
  for (final img.Pixel p in samples) {
    r += p.r.toInt();
    g += p.g.toInt();
    b += p.b.toInt();
  }
  return img.ColorRgb8(r ~/ 4, g ~/ 4, b ~/ 4);
}
