import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class Pushnotificationprovider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Manejar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=== onMessage ===');
      print('Datos del mensaje en primer plano: ${message.data}');
    });

    // Manejar clic en notificación cuando la app está en segundo plano o primer plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('=== onMessageOpenedApp ===');
      print('¡Clic detectado en notificación! Datos: ${message.data}');
      handleMessage(message);
    });

    // Manejar clic en notificación cuando la app está cerrada
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('=== getInitialMessage ===');
      print('¡Clic detectado en notificación con app cerrada! Datos: ${initialMessage.data}');
      handleMessage(initialMessage);
    }
  }

  void handleMessage(RemoteMessage message) {
    final data = message.data;
    print('Procesando mensaje en handleMessage. Datos: $data');
    if (data.containsKey('screen')) {
      final screen = data['welcome'];
      print('Navegando a: $screen');
      Get.toNamed(screen);
    } else {
      print('No se encontró "screen", navegando a /welcome por defecto');
      Get.toNamed('/welcome');
    }
  }
}