import 'package:flutter/material.dart';

/// A single physical color cap used in the Farnsworth D-15 test.
/// Each cap carries its official Munsell notation (the standardized color
/// naming system the physical test kit uses), its display RGB value (for
/// rendering on-screen), and its CIE L*u*v* chromaticity coordinates
/// (u, v) — the values the scoring math actually operates on.
class ColorCapData {
  final int num;
  final String munsell;
  final Color rgb;
  final double u;
  final double v;

  const ColorCapData({
    required this.num,
    required this.munsell,
    required this.rgb,
    required this.u,
    required this.v,
  });
}

// Static lookup table for all 16 caps (Pilot cap 0 + movable caps 1-15),
//  from the reference Farnsworth D-15 dataset 
class ColorCap {
  ColorCap._();

  static const List<ColorCapData> allCaps = [
    ColorCapData(num: 0, munsell: '10B 5/6', rgb: Color.fromRGBO(93, 130, 160, 1), u: -21.54, v: -38.39),
    ColorCapData(num: 1, munsell: '5B 5/4', rgb: Color.fromRGBO(99, 130, 143, 1), u: -23.26, v: -25.56),
    ColorCapData(num: 2, munsell: '10BG 5/4', rgb: Color.fromRGBO(96, 132, 137, 1), u: -22.41, v: -15.53),
    ColorCapData(num: 3, munsell: '5BG 5/4', rgb: Color.fromRGBO(97, 133, 128, 1), u: -23.11, v: -7.45),
    ColorCapData(num: 4, munsell: '10G 5/4', rgb: Color.fromRGBO(99, 133, 119, 1), u: -22.45, v: 1.10),
    ColorCapData(num: 5, munsell: '5G 5/4', rgb: Color.fromRGBO(102, 133, 111, 1), u: -21.67, v: 7.35),
    ColorCapData(num: 6, munsell: '10GY 5/4', rgb: Color.fromRGBO(109, 132, 98, 1), u: -14.08, v: 18.74),
    ColorCapData(num: 7, munsell: '5GY 5/4', rgb: Color.fromRGBO(119, 128, 84, 1), u: -2.72, v: 28.13),
    ColorCapData(num: 8, munsell: '5Y 5/4', rgb: Color.fromRGBO(134, 122, 76, 1), u: 14.84, v: 31.13),
    ColorCapData(num: 9, munsell: '10YR 5/4', rgb: Color.fromRGBO(140, 117, 82, 1), u: 23.87, v: 26.35),
    ColorCapData(num: 10, munsell: '2.5YR 5/4', rgb: Color.fromRGBO(145, 113, 96, 1), u: 31.82, v: 14.76),
    ColorCapData(num: 11, munsell: '7.5R 5/4', rgb: Color.fromRGBO(146, 111, 105, 1), u: 31.42, v: 6.99),
    ColorCapData(num: 12, munsell: '2.5R 5/4', rgb: Color.fromRGBO(145, 111, 114, 1), u: 29.79, v: 0.10),
    ColorCapData(num: 13, munsell: '5RP 5/4', rgb: Color.fromRGBO(141, 112, 125, 1), u: 26.64, v: -9.38),
    ColorCapData(num: 14, munsell: '10P 5/4', rgb: Color.fromRGBO(136, 114, 135, 1), u: 22.92, v: -18.65),
    ColorCapData(num: 15, munsell: '5P 5/4', rgb: Color.fromRGBO(129, 117, 143, 1), u: 11.20, v: -24.61),
  ];

  // Convenience accessor used by the tray/pool UI and the confusion
  // diagram painter to get just the display color for a given cap number.
  static Color getVisualColor(int capNum) => allCaps[capNum].rgb;
}