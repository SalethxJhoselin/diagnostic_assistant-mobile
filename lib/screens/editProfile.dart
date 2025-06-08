import 'package:asd/components/Card.dart';
import 'package:asd/components/CustomAppBar.dart';
import 'package:asd/components/CustomTextField.dart';
import 'package:asd/components/actionButton.dart';
import 'package:asd/providers/userProvider.dart';
import 'package:asd/services/patientService.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final UserProvider userProvider;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _emailController = TextEditingController(text: userProvider.email);
    _phoneController = TextEditingController(
      text: userProvider.phone?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    int? phoneNumber;
    if (_phoneController.text.isNotEmpty) {
      phoneNumber = int.tryParse(_phoneController.text);
      if (phoneNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese un número de teléfono válido')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    final updateData = {
      if (_emailController.text.isNotEmpty) 'email': _emailController.text,
      if (phoneNumber != null) 'phone': phoneNumber,
    };

    try {
      final success = await PatientService.updatePatientByCi(
        ci: userProvider.ci!,
        data: updateData,
      );

      if (success && mounted) {
        await userProvider.updateUserData(
          email: _emailController.text,
          phone: phoneNumber,
        );
        Navigator.pop(context, true); // Retornar true indicando éxito
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar los datos')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title1: 'Editar Perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            ProfileCard(
              child: Column(
                children: [
                  CustomTextField(
                    icon: LineAwesomeIcons.envelope,
                    label: 'Correo Electrónico',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    icon: LineAwesomeIcons.phone_alt_solid,
                    label: 'Teléfono/Celular',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ActionButton(
                    icon: LineAwesomeIcons.save,
                    title: 'Guardar Cambios',
                    color: Colors.teal,
                    isDark: isDark,
                    onPressed: _isLoading ? () {} : () => _updateProfile(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
