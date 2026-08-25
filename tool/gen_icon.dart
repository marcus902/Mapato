import 'dart:io';

import 'package:image/image.dart';

const green = 0xFF0B7A45; // brand green (AARRGGBB)

void main() {
  final bytes = File('app-icon.png').readAsBytesSync();
  final src = decodeImage(bytes);
  if (src == null) {
    stderr.writeln('Could not decode icon.png');
    exit(1);
  }

  final square = centerCrop(src);
  final transparent = removeWhite(square);

  final res = 'android/app/src/main/res';

  // Legacy launcher icons: green background + centered logo.
  const legacy = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  for (final e in legacy.entries) {
    final size = e.value;
    final img = Image(width: size, height: size);
    fill(img, color: ColorRgb8(0x0B, 0x7A, 0x45));
    blit(img, transparent, (size - (size * 0.58).round()) ~/ 2,
        (size - (size * 0.58).round()) ~/ 2, size * 0.58);
    final out = '$res/mipmap-${e.key}/ic_launcher.png';
    File(out).createSync(recursive: true);
    File(out).writeAsBytesSync(encodePng(img));
  }

  // Adaptive foreground: transparent canvas, logo within safe zone (~66%).
  const fg = {
    'mdpi': 108,
    'hdpi': 162,
    'xhdpi': 216,
    'xxhdpi': 324,
    'xxxhdpi': 432,
  };
  for (final e in fg.entries) {
    final size = e.value;
    final img = Image(width: size, height: size); // transparent by default
    blit(img, transparent, (size - (size * 0.66).round()) ~/ 2,
        (size - (size * 0.66).round()) ~/ 2, size * 0.66);
    final out = '$res/drawable-${e.key}/ic_launcher_foreground.png';
    File(out).createSync(recursive: true);
    File(out).writeAsBytesSync(encodePng(img));
  }

  // Adaptive background color.
  File('$res/values/ic_launcher_background.xml')
    ..createSync(recursive: true)
    ..writeAsStringSync('<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n'
        '    <color name="ic_launcher_background">#0B7A45</color>\n'
        '</resources>\n');

  // Adaptive icon descriptor.
  File('$res/mipmap-anydpi-v26/ic_launcher.xml')
    ..createSync(recursive: true)
    ..writeAsStringSync('<adaptive-icon '
        'xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@drawable/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n');

  stdout.writeln('Launcher icons generated.');
}

Image centerCrop(Image img) {
  if (img.width == img.height) return img;
  final side = img.width < img.height ? img.width : img.height;
  final x = (img.width - side) ~/ 2;
  final y = (img.height - side) ~/ 2;
  return copyCrop(img, x: x, y: y, width: side, height: side);
}

/// Make near-white pixels transparent so the icon does not sit on a white box.
Image removeWhite(Image img) {
  final out = Image(width: img.width, height: img.height);
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      final p = img.getPixel(x, y);
      if (p.r >= 245 && p.g >= 245 && p.b >= 245) {
        out.setPixelRgba(x, y, p.r, p.g, p.b, 0);
      } else {
        out.setPixelRgba(x, y, p.r, p.g, p.b, p.a);
      }
    }
  }
  return out;
}

/// Scale [logo] to fit within a [box] box and alpha-blend it onto [dst]
/// with its top-left at ([dx], [dy]).
void blit(Image dst, Image logo, int dx, int dy, double box) {
  final scale = box / (logo.width >= logo.height ? logo.width : logo.height);
  final w = (logo.width * scale).round();
  final h = (logo.height * scale).round();
  final resized = copyResize(logo, width: w, height: h,
      interpolation: Interpolation.average);
  for (var y = 0; y < resized.height; y++) {
    for (var x = 0; x < resized.width; x++) {
      final p = resized.getPixel(x, y);
      if (p.a == 0) continue;
      final tx = dx + x;
      final ty = dy + y;
      if (tx < 0 || ty < 0 || tx >= dst.width || ty >= dst.height) continue;
      final d = dst.getPixel(tx, ty);
      final sa = p.a / 255;
      final da = d.a / 255;
      final outA = sa + da * (1 - sa);
      if (outA <= 0) {
        dst.setPixelRgba(tx, ty, 0, 0, 0, 0);
        continue;
      }
      final r = ((p.r * sa + d.r * da * (1 - sa)) / outA).round();
      final g = ((p.g * sa + d.g * da * (1 - sa)) / outA).round();
      final b = ((p.b * sa + d.b * da * (1 - sa)) / outA).round();
      dst.setPixelRgba(tx, ty, r, g, b, (outA * 255).round());
    }
  }
}
