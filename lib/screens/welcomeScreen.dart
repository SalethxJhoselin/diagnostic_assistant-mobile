import 'package:flutter/material.dart';
import 'package:medical_record_movil/components/BottonChange.dart';
import 'package:medical_record_movil/screens/login.dart';
import 'package:provider/provider.dart';

import '../components/fadeThroughPageRoute.dart';
import '../providers/themeProvider.dart';
import '../utils/assets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff0e1415) : const Color(0xfff9f9ff),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.2),
                Image.asset(
                  Assets.imagesSplash,
                  scale: 2.5,
                ),
                SizedBox(height: size.height * 0.05),
                Text(
                  'Welcome to Medical Records',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: !isDark
                        ? const Color(0xff0e1415)
                        : const Color(0xfff9f9ff),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Manage your health records easily.',
                  style: TextStyle(
                    fontSize: 18,
                    color: !isDark
                        ? const Color(0xff0e1415)
                        : const Color(0xfff9f9ff),
                  ),
                ),
                SizedBox(height: size.height * 0.15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BottonChange(
                      colorBack: isDark ? Colors.white : Colors.black,
                      colorFont: isDark ? Colors.black : Colors.white,
                      textTile: 'Sign in',
                      onPressed: () {
                        Navigator.of(context).push(
                          FadeThroughPageRoute(
                            page: const LoginPage(),
                          ),
                        );
                      },
                      width: 140.0,
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
