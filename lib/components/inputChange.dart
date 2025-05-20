import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/themeProvider.dart';

class TextFormFieldTheme {
  TextFormFieldTheme._();

  static InputDecoration customInputDecoration({
    required String? labelText,
    required BuildContext context,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    var isDark = themeProvider.isDarkMode;

    return InputDecoration(
      labelText: labelText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(
          color: isDark ? Colors.white38 : Colors.black38,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(
          color: isDark ? Colors.white : Colors.black,
          width: 1.0,
        ),
      ),
      floatingLabelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      prefixIconColor: isDark ? Colors.amber[300] : Colors.amber,
    );
  }
}
