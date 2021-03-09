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

import 'package:flutter/painting.dart';
import 'tinycolor.dart';

/// Extends the Color class to allow direct TinyColor manipulation nativly
extension TinyColorExtension on Color {
  /// Converts standard Color to TinyColor object
  TinyColor toTinyColor() => TinyColor(this);

  HSVColor toHsv() => TinyColor(this).toHsv();

  HslColor toHsl() => TinyColor(this).toHsl();

  /// Lighten the color a given amount, from 0 to 100. Providing 100 will always return white.
  Color lighten([int amount = 10]) => TinyColor(this).lighten(amount).color;

  /// Brighten the color a given amount, from 0 to 100.
  Color brighten([int amount = 10]) => TinyColor(this).brighten(amount).color;

  /// Darken the color a given amount, from 0 to 100. Providing 100 will always return black.
  Color darken([int amount = 10]) => TinyColor(this).darken(amount).color;

  /// Mix the color with pure white, from 0 to 100. Providing 0 will do nothing, providing 100 will always return white.
  Color tint([int amount = 10]) => TinyColor(this).tint(amount).color;

  /// Mix the color with pure black, from 0 to 100. Providing 0 will do nothing, providing 100 will always return black.
  Color shade([int amount = 10]) => TinyColor(this).shade(amount).color;

  /// Desaturate the color a given amount, from 0 to 100. Providing 100 will is the same as calling greyscale.
  Color desaturate([int amount = 10]) =>
      TinyColor(this).desaturate(amount).color;

  /// Saturate the color a given amount, from 0 to 100.
  Color saturate([int amount = 10]) => TinyColor(this).saturate(amount).color;

  /// Completely desaturates a color into greyscale. Same as calling desaturate(100).
  Color get greyscale => TinyColor(this).greyscale().color;

  /// Spin the hue a given amount, from -360 to 360. Calling with 0, 360, or -360 will do nothing (since it sets the hue back to what it was before).
  Color spin([double amount = 0]) => TinyColor(this).spin(amount).color;

  /// Returns the perceived brightness of a color, from 0-255, as defined by Web Content Accessibility Guidelines (Version 1.0).Returns the perceived brightness of a color, from 0-255, as defined by Web Content Accessibility Guidelines (Version 1.0).
  double get brightness => TinyColor(this).getBrightness();

  /// Return the perceived luminance of a color, a shorthand for flutter Color.computeLuminance
  double get luminance => TinyColor(this).getLuminance();

  /// Return a boolean indicating whether the color's perceived brightness is light.
  bool get isLight => TinyColor(this).isLight();

  /// Return a boolean indicating whether the color's perceived brightness is dark.
  bool get isDark => TinyColor(this).isDark();

  /// Returns the Complimentary Color for dynamic matching
  Color get compliment => TinyColor(this).complement().color;

  /// Blends the color with another color a given amount, from 0 - 100, default 50.
  Color mix(Color toColor, [int amount = 50]) =>
      TinyColor(this).mix(input: toColor, amount: amount).color;
}
