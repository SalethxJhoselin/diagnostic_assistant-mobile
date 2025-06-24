import 'package:asd/providers/pushNotificationProvider.dart';
import 'package:asd/screens/home.dart';
import 'package:asd/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/themeProvider.dart';
import 'providers/userProvider.dart';
import 'screens/splash.dart';
import 'screens/welcomeScreen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Inicializar Firebase en segundo plano
  print('=== onBackgroundMessage ===');
  print('Datos del mensaje: ${message.data}');
  // Llamar a la misma lógica de navegación
  final pushProvider = Pushnotificationprovider();
  pushProvider.handleMessage(message); // Llamar al manejador de navegación
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FlutterDownloader.initialize();

  // Inicializar notificaciones push
  final pushProvider = Pushnotificationprovider();
  await pushProvider.initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GetMaterialApp(
            title: 'DermAI',
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(137, 90, 135, 218),
              ),
              textTheme: GoogleFonts.nunitoTextTheme(),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF121212),
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.nunitoTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ),
            ),
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => const SplashScreen()),
              GetPage(name: '/welcome', page: () => const WelcomeScreen()),
              GetPage(name: '/login', page: () => const LoginPage()),
              GetPage(name: '/home', page: () => const HomePage()),
            ],
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
