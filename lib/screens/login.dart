import 'package:asd/components/BottonChange.dart';
import 'package:asd/services/authService.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../components/SelectOrganizationPage.dart';
import '../providers/userProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricSupported = false;
  bool _isLoading = false;
  bool _showBiometricButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false);
    });
    _initAuth();
  }

  Future<void> _initAuth() async {
    await _checkBiometricSupport();
    if (_isBiometricSupported) {
      await _checkTokenAndBiometrics();
    }
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final canAuthenticate =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      setState(() => _isBiometricSupported = canAuthenticate);
    } catch (e) {
      setState(() => _isBiometricSupported = false);
    }
  }

  Future<void> _checkTokenAndBiometrics() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final hasToken = await userProvider.hasStoredToken();
      final credentials = await userProvider.getCredentials();
      final hasCredentials = credentials != null;

      setState(() {
        _showBiometricButton = hasToken && hasCredentials;
      });

      if (_showBiometricButton) {
        await _tryAutoLoginWithBiometrics();
      }
    } catch (e) {}
  }

  Future<void> _tryAutoLoginWithBiometrics() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Autentícate para acceder',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (!isAuthenticated) {
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final credentials = await userProvider.getCredentials();

      if (credentials == null ||
          credentials['email'] == null ||
          credentials['ci'] == null) {
        return;
      }

      setState(() => _isLoading = true);
      _emailController.text = credentials['email']!;
      _ciController.text = credentials['ci']!;

      await _login();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en autenticación: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                    SizedBox(height: size.height * 0.35),
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
                        Icon(Icons.login, color: Colors.teal, size: 30.0),
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
                          'Email',
                          'ej@mail.com',
                          _emailController,
                          false,
                        ),
                        const SizedBox(height: 12),
                        buildTextField('CI', '12345678', _ciController, true),
                        const SizedBox(height: 20),
                        BottonChange(
                          colorBack: Colors.teal,
                          colorFont: Colors.white,
                          textTile: 'Login',
                          onPressed: _isLoading ? null : _login,
                          width: 300,
                        ),
                        if (_isBiometricSupported) ...[
                          const SizedBox(height: 20),
                          _buildBiometricButton(),
                        ],
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

  Widget _buildBiometricButton() {
    if (!_showBiometricButton) return const SizedBox.shrink();
    return Column(
      children: [
        const Text('O usa tu huella', style: TextStyle(color: Colors.grey)),
        IconButton(
          icon: const Icon(Icons.fingerprint, size: 50, color: Colors.teal),
          onPressed: _isLoading ? null : _tryAutoLoginWithBiometrics,
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final email = _emailController.text;
        final ci = int.tryParse(_ciController.text) ?? 0; // Valor por defecto
        if (ci == 0) throw Exception('CI inválido');

        final token = await AutenticacionServices().loginUsuario(
          context: context,
          email: email,
          ci: ci,
        );

        if (token != null) {
          await userProvider.setToken(token);
          await userProvider.saveCredentials(email, ci); // Guarda credenciales

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SelectOrganizationPage(),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciales incorrectas')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    bool isNumber,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 174, 191, 200)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 174, 191, 200),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio';
        if (isNumber && int.tryParse(value) == null) return 'Número inválido';
        return null;
      },
    );
  }
}
