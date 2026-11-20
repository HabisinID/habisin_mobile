import 'package:flutter/material.dart';

import '../theme.dart';
import 'components.dart';

/// Katalog komponen design.pen untuk referensi anggota tim (Akun → Galeri komponen).
class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const gap = SizedBox(height: AppSpace.xl);
    return Scaffold(
      appBar: AppBar(title: const Text('Galeri komponen')),
      bottomNavigationBar: const TicketStrip(code: 'H7K49', meta: 'Ambil sebelum 20.30 · Roti Margonda'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          const SectionHeader('Tipografi'),
          Text('Ambil sebelum 20.30', style: t.displaySmall),
          Text('Roti Sisir Mentega', style: t.headlineSmall),
          Text('Makanan surplus terdekat', style: t.titleLarge),
          Text('Toko Roti Margonda · 350 m', style: t.bodyLarge),
          Text('2 porsi tersisa · Hemat 60%', style: t.bodyMedium),
          Text('DICETAK 19.02 WIB', style: t.labelSmall),
          Text('H7K · 49', style: AppText.code),
          Text('${rupiah(8000)}   ${rupiah(1250000)}   20.30', style: AppText.mono),
          gap,
          const SectionHeader('Tombol'),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            AppButton('Pesan sekarang', onPressed: () {}),
            AppButton.secondary('Pindai QR', icon: Icons.qr_code_scanner, onPressed: () {}),
            AppButton.destructive('Hapus permanen', onPressed: () {}),
            const AppButton('Disabled', onPressed: null),
            AppButton('Menyimpan', loading: true, onPressed: () {}),
          ]),
          gap,
          const SectionHeader('Input & chip'),
          const AppInput(label: 'Nama makanan', hint: 'Nasi Ayam Geprek', help: 'Contoh: Roti Sisir Mentega'),
          const SizedBox(height: AppSpace.md),
          Wrap(spacing: AppSpace.sm, children: [
            const AppChip('Gratis', selected: true),
            const AppChip('Roti & kue'),
            const AppChip('Filter', icon: Icons.tune),
          ]),
          gap,
          const SectionHeader('Countdown & stiker'),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            Countdown.fromDuration(const Duration(hours: 2, minutes: 14)),
            Countdown.fromDuration(const Duration(minutes: 18)),
          ]),
          const SizedBox(height: AppSpace.md),
          const Wrap(spacing: AppSpace.sm, children: [
            Sticker('Rp8.000'),
            Sticker('Gratis', kind: StickerKind.free),
            Sticker('Rp5.000', kind: StickerKind.urgent),
            Sticker('Rp10.000', kind: StickerKind.selected),
          ]),
          gap,
          const SectionHeader('Listing Row', action: 'Lihat semua'),
          ListingRow(
            title: 'Roti Sisir Mentega',
            shop: 'Toko Roti Margonda · 350 m',
            deadline: '20.30',
            stockLabel: '2 porsi tersisa',
            price: 8000,
            normalPrice: 20000,
            timeLeft: 0.6,
            onTap: () {},
            onFavorite: () {},
          ),
          gap,
          const SectionHeader('Statistik'),
          const StatStruk(
            label: 'Porsi terselamatkan',
            value: '12.486',
            unit: 'porsi',
            badge: 'Estimasi',
            sub: 'dari 214 toko di Depok',
          ),
          const SizedBox(height: AppSpace.lg),
          const BarChart(values: [60, 83, 72, 105, 93, 120], labels: ['Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep']),
          gap,
          const SectionHeader('Status'),
          const SizedBox(height: 160, child: StateView(icon: Icons.search_off, title: 'Belum ada yang cocok.')),
          SizedBox(height: 220, child: StateView.error(onAction: () {})),
        ],
      ),
    );
  }
}
