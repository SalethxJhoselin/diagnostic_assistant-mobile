import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:medical_record_movil/components/BottonChange.dart';
import 'package:medical_record_movil/screens/home.dart';
import 'package:medical_record_movil/services/authService.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.35,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seguridad',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.login,
                          color: Colors.teal,
                          size: 30.0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      'Inicio de sesión',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildTextField(
                            'Usuario', 'Usuario', _usernameController, false),
                        const SizedBox(height: 12),
                        buildTextField('Contraseña', 'Contraseña',
                            _passwordController, true),
                        const SizedBox(height: 20),
                        BottonChange(
                            colorBack: Colors.teal,
                            colorFont: Colors.white,
                            textTile: 'Login',
                            onPressed: _login,
                            width: 300)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final username = _usernameController.text;
        final password = _passwordController.text;

        final response = await AutenticacionServices().loginUsuario(
            context: context, username: username, password: password);

        if (response != null) {
          final token = response;
          await userProvider.setToken(token);

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario o contraseña incorrectos')),
          );
        }
      } catch (e) {}
    }
  }
}

Widget buildTextField(String label, String hint,
    TextEditingController controller, bool isPassword) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color.fromARGB(255, 174, 191, 200)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.blue,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 174, 191, 200),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
    ),
    obscureText: isPassword,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Este campo no puede estar vacío';
      }
      return null;
    },
  );
}
