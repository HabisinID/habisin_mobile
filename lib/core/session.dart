import 'package:flutter/material.dart';

enum Role { pembeli, mitra, admin }

/// Peran pengguna yang sedang aktif. Menentukan bottom navigation di HomeShell.
// ponytail: diganti manual dari halaman Akun; Modul 1 mengisinya dari GET /api/auth/me setelah login.
final currentRole = ValueNotifier<Role>(Role.pembeli);

/// Mode tema: ikut sistem (default), terang, atau gelap. Diganti dari halaman Akun.
// ponytail: tidak disimpan; kembali ke "Sistem" saat app dibuka ulang. Simpan ke shared_preferences bila perlu.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
