import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/widgets/module_page.dart';

/// Template halaman Masuk / Daftar (Modul 1). Desain: design.pen "MOBILE 390 · Landing page & Akun (Masuk, Daftar)".
class AuthPage extends StatelessWidget {
  const AuthPage({super.key, this.register = false});

  final bool register;

  @override
  Widget build(BuildContext context) => ModulePage(
        module: 1,
        title: register ? 'Daftar' : 'Masuk',
        owner: 'Rozan Laudzai',
        standalone: true,
        endpoints: register
            ? const ['GET /api/auth/username?username=', 'POST /api/auth/register']
            : const ['POST /api/auth/login'],
        children: [
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, register ? AppRoutes.login : AppRoutes.register),
            child: Text(register ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar'),
          ),
        ],
      );
}
