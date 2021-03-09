// Copyright 2018 Foo Studio <developer@foostudio.mx>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart';

import 'color_from_string.dart';
import 'conversion.dart';
import 'hsl_color.dart';
import 'util.dart';

export 'color_extension.dart';
export 'hsl_color.dart';

class TinyColor {
  TinyColor(Color color) : originalColor = color {
    _color = Color.fromARGB(color.alpha, color.red, color.green, color.blue);
  }

  factory TinyColor.fromRGB(
      {required int r, required int g, required int b, int a = 100}) {
    return TinyColor(Color.fromARGB(a, r, g, b));
  }

  factory TinyColor.fromHSL(HslColor hsl) {
    return TinyColor(hslToColor(hsl));
  }

  factory TinyColor.fromHSV(HSVColor hsv) {
    return TinyColor(hsv.toColor());
  }

  factory TinyColor.fromString(String string) {
    return TinyColor(colorFromString(string));
  }

  final Color originalColor;
  late Color _color;

  bool isDark() {
    return getBrightness() < 128.0;
  }

  bool isLight() {
    return !isDark();
  }

  double getBrightness() {
    return (_color.red * 299 + _color.green * 587 + _color.blue * 114) / 1000;
  }

  double getLuminance() {
    return _color.computeLuminance();
  }

  TinyColor setAlpha(int alpha) {
    _color.withAlpha(alpha);
    return this;
  }

  TinyColor setOpacity(double opacity) {
    _color.withOpacity(opacity);
    return this;
  }

  HSVColor toHsv() {
    return colorToHsv(_color);
  }

  HslColor toHsl() {
    final hsl = rgbToHsl(
      r: _color.red.toDouble(),
      g: _color.green.toDouble(),
      b: _color.blue.toDouble(),
    );
    return HslColor(
        h: hsl.h * 360, s: hsl.s, l: hsl.l, a: _color.alpha.toDouble());
  }

  TinyColor clone() {
    return TinyColor(_color);
  }

  TinyColor lighten([int amount = 10]) {
    final hsl = toHsl();
    hsl.l += amount / 100;
    hsl.l = clamp01(hsl.l);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor brighten([int amount = 10]) {
    final color = Color.fromARGB(
      _color.alpha,
      math.max(0, math.min(255, _color.red - (255 * -(amount / 100)).round())),
      math.max(
          0, math.min(255, _color.green - (255 * -(amount / 100)).round())),
      math.max(0, math.min(255, _color.blue - (255 * -(amount / 100)).round())),
    );
    return TinyColor(color);
  }

  TinyColor darken([int amount = 10]) {
    final hsl = toHsl();
    hsl.l -= amount / 100;
    hsl.l = clamp01(hsl.l);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor tint([int amount = 10]) {
    return mix(input: Color.fromRGBO(255, 255, 255, 1.0));
  }

  TinyColor shade([int amount = 10]) {
    return mix(input: Color.fromRGBO(0, 0, 0, 1.0));
  }

  TinyColor desaturate([int amount = 10]) {
    final hsl = toHsl();
    hsl.s -= amount / 100;
    hsl.s = clamp01(hsl.s);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor saturate([int amount = 10]) {
    final hsl = toHsl();
    hsl.s += amount / 100;
    hsl.s = clamp01(hsl.s);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor greyscale() {
    return desaturate(100);
  }

  TinyColor spin(double amount) {
    final hsl = toHsl();
    final hue = (hsl.h + amount) % 360;
    hsl.h = hue < 0 ? 360 + hue : hue;
    return TinyColor.fromHSL(hsl);
  }

  TinyColor mix({required Color input, int amount = 50}) {
    final p = (amount / 100).round();
    final color = Color.fromARGB(
        (input.alpha - _color.alpha) * p + _color.alpha,
        (input.red - _color.red) * p + _color.red,
        (input.green - _color.green) * p + _color.green,
        (input.blue - _color.blue) * p + _color.blue);
    return TinyColor(color);
  }

  TinyColor complement() {
    final hsl = toHsl();
    hsl.h = (hsl.h + 180) % 360;
    return TinyColor.fromHSL(hsl);
  }

  Color get color {
    return _color;
  }
}
