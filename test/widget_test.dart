import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habisin_mobile/core/session.dart';
import 'package:habisin_mobile/core/theme.dart';
import 'package:habisin_mobile/core/widgets/component_gallery.dart';
import 'package:habisin_mobile/core/widgets/components.dart';
import 'package:habisin_mobile/main.dart';

Finder _tab(String label) => find.descendant(
  of: find.byKey(const Key('bottom-nav')),
  matching: find.text(label),
);

Future<void> _visitTabs(
  WidgetTester tester,
  Map<String, String> tabToTitle,
) async {
  for (final MapEntry(key: tab, value: title) in tabToTitle.entries) {
    await tester.tap(_tab(tab));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget, reason: tab);
  }
}

Future<void> _openAndBack(
  WidgetTester tester,
  Finder opener,
  String title,
) async {
  await tester.tap(opener);
  await tester.pumpAndSettle();
  expect(find.text(title), findsWidgets, reason: title);
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('bottom-nav')), findsOneWidget);
}

void main() {
  setUp(() {
    currentRole.value = Role.pembeli;
    themeMode.value = ThemeMode.light;
  });

  testWidgets('pembeli: tab, toggle peta/daftar, halaman ulasan', (
    tester,
  ) async {
    await tester.pumpWidget(const HabisinApp());
    expect(find.text('Peta Sebaran Makanan'), findsOneWidget);
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Katalog & Pencarian'), findsOneWidget);

    await _visitTabs(tester, {
      'Pesanan': 'Pesanan Saya',
      'Akun': 'POST /api/auth/login',
    });
    await _openAndBack(
      tester,
      find.text('Ulasan & Komplain saya'),
      'Ulasan & Komplain',
    );
  });

  testWidgets('mitra: kelima tab dan profil toko', (tester) async {
    currentRole.value = Role.mitra;
    await tester.pumpWidget(const HabisinApp());
    await _visitTabs(tester, {
      'Listing': 'Kelola Listing',
      'Verifikasi': 'Verifikasi Kode',
      'Pesanan': 'Pesanan Masuk',
      'Dasbor': 'Dasbor Statistik',
      'Akun': 'POST /api/auth/login',
    });
    await _openAndBack(tester, find.text('Profil Toko'), 'Profil Toko');
  });

  testWidgets('admin: kelima tab dan akun dari avatar', (tester) async {
    currentRole.value = Role.admin;
    await tester.pumpWidget(const HabisinApp());
    await _visitTabs(tester, {
      'Pendaftaran': 'Pendaftaran Mitra',
      'Listing': 'Listing Publik',
      'Laporan': 'Laporan Komplain',
      'Log': 'Log Moderasi',
      'Ringkasan': 'Ringkasan Admin',
    });
    await _openAndBack(tester, find.byTooltip('Akun'), 'Akun');
  });

  test('rupiah() memakai titik ribuan', () {
    expect(rupiah(0), 'Rp0');
    expect(rupiah(8000), 'Rp8.000');
    expect(rupiah(1250000), 'Rp1.250.000');
  });

  for (final (name, theme) in [
    ('terang', AppTheme.light),
    ('gelap', AppTheme.dark),
  ]) {
    testWidgets(
      'galeri komponen render tanpa overflow di layar ponsel 390 (tema $name)',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(theme: theme, home: const ComponentGallery()),
        );
        // Gulir ke bawah agar semua komponen ikut di-render.
        await tester.drag(find.byType(ListView), const Offset(0, -3000));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('pilihan tema di Akun mengganti palet aplikasi', (tester) async {
    await tester.pumpWidget(const HabisinApp());
    Color bg() =>
        tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor ??
        Theme.of(tester.element(find.byType(Scaffold).first))
            .scaffoldBackgroundColor;
    expect(bg(), AppColors.light.bg);

    await tester.tap(_tab('Akun'));
    await tester.pumpAndSettle();
    final gelap = find.text('Gelap');
    await tester.scrollUntilVisible(
      gelap,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(gelap);
    await tester.pumpAndSettle();
    await tester.tap(gelap);
    await tester.pumpAndSettle();
    expect(bg(), AppColors.dark.bg);
  });

  testWidgets('ganti peran dari tab Akun mengganti bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const HabisinApp());
    await tester.tap(_tab('Akun'));
    await tester.pumpAndSettle();
    final mitra = find.text('Mitra');
    await tester.scrollUntilVisible(
      mitra,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(mitra);
    await tester.pumpAndSettle();
    await tester.tap(mitra);
    await tester.pumpAndSettle();
    expect(_tab('Dasbor'), findsOneWidget);
    expect(_tab('Jelajahi'), findsNothing);
  });
}
