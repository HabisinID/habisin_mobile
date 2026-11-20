import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/session.dart';
import '../../core/widgets/module_page.dart';

/// Tab Akun (Pembeli & Mitra) dan halaman akun Admin (dibuka dari avatar).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.standalone = false});

  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentRole,
      builder: (context, role, _) => ModulePage(
        module: 1,
        title: 'Akun',
        owner: 'Rozan Laudzai',
        standalone: standalone,
        endpoints: const [
          'POST /api/auth/login',
          'POST /api/auth/register',
          'POST /api/auth/logout',
          'GET/PATCH/DELETE /api/auth/me',
          'POST /api/auth/password',
        ],
        children: [
          const SizedBox(height: 16),
          _Link(Icons.login, 'Masuk', AppRoutes.login),
          _Link(Icons.person_add_alt, 'Daftar akun', AppRoutes.register),
          const SizedBox(height: 8),
          if (role == Role.pembeli)
            _Link(
              Icons.rate_review_outlined,
              'Ulasan & Komplain saya',
              AppRoutes.review,
            ),
          if (role == Role.mitra)
            _Link(Icons.store_outlined, 'Profil Toko', AppRoutes.store),
          const SizedBox(height: 8),
          _Link(
            Icons.palette_outlined,
            'Galeri komponen (dev)',
            AppRoutes.components,
          ),
          const SizedBox(height: 16),
          const Text('Tema'),
          const SizedBox(height: 8),
          ValueListenableBuilder(
            valueListenable: themeMode,
            builder: (_, mode, _) => SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('Sistem'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Terang'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Gelap'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) => themeMode.value = s.first,
            ),
          ),
          const SizedBox(height: 16),
          // Sementara: ganti peran untuk menguji navigasi sebelum login jadi.
          const Text('Peran (sementara, sebelum login)'),
          const SizedBox(height: 8),
          SegmentedButton<Role>(
            segments: const [
              ButtonSegment(value: Role.pembeli, label: Text('Pembeli')),
              ButtonSegment(value: Role.mitra, label: Text('Mitra')),
              ButtonSegment(value: Role.admin, label: Text('Admin')),
            ],
            selected: {role},
            onSelectionChanged: (s) {
              currentRole.value = s.first;
              if (standalone) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link(this.icon, this.label, this.route);
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    ),
  );
}
