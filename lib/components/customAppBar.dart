import 'package:flutter/material.dart';
import 'package:medical_record_movil/components/wabeClipper.dart';
import 'package:medical_record_movil/screens/home.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title1;
  final IconData icon;
  final Color colorBack;
  final Color titlecolor;

  const CustomAppBar(
      {super.key,
      required this.title1,
      required this.titlecolor,
      required this.icon,
      required this.colorBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: ClipPath(
        clipper: DoubleWaveClipper(),
        child: Container(
          height: double.infinity,
          color: colorBack,
        ),
      ),
      toolbarHeight: 110,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconAppBar(
            icon: icon,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1,
                style: TextStyle(
                  fontSize: 18,
                  color: titlecolor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}
