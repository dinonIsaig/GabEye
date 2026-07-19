import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';



class GabEyeTheme {

  static final ThemeData  lightTheme = ThemeData (
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFFFFFFF),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black
      )
    )
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkMode,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white
      )
    )
  );


}


