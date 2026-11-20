import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/api_service.dart';
import '../../core/theme.dart';
import '../../core/widgets/components.dart';
import '../catalog/models/listing.dart';

/// Halaman Peta Sebaran Makanan Interaktif (Modul 4 - Pembeli).
///
/// Fitur utama:
/// 1. Peta Interaktif OpenStreetMap (OSM) via package flutter_map & latlong2.
/// 2. Marker Toko Dinamis: Menggunakan widget Sticker (harga, gratis, urgent, terpilih).
/// 3. Filter Lokasi & Re-center: Tombol floating untuk mengembalikan fokus peta ke area kampus UI / Depok.
/// 4. Interaksi Tap Marker: Membuka bottom sheet profil toko dan daftar makanan surplus yang tersedia.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Controller untuk mengontrol posisi tengah dan zoom level pada peta OSM
  final MapController _mapController = MapController();

  // Koordinat default awal peta: Area Beji / Kampus UI Depok (-6.3698, 106.82025)
  static const LatLng _initialCenter = LatLng(-6.3698, 106.82025);

  // Daftar listing makanan dari backend yang memiliki koordinat latitude & longitude
  List<Listing> _listings = [];

  // ID listing/toko yang sedang aktif dipilih pada marker peta
  int? _selectedListingId;

  // Status proses memuat data dari server
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Memuat data listing dari backend saat halaman peta pertama kali dibuka
    _fetchMapListings();
  }

  /// Mengambil data seluruh makanan surplus publik dari backend DRF.
  /// Setiap listing membawa data toko beserta koordinat latitude & longitude-nya.
  Future<void> _fetchMapListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.instance.fetchListings();
      if (mounted) {
        setState(() {
          // Hanya ambil listing yang memiliki koordinat valid (tidak 0.0)
          _listings = data
              .where((item) => item.latitude != 0.0 && item.longitude != 0.0)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// Memusatkan kembali peta ke lokasi default (Kampus UI / Depok)
  void _recenterMap() {
    _mapController.move(_initialCenter, 14.5);
  }

  /// Menampilkan Modal Bottom Sheet detail toko dan makanan saat marker toko diklik oleh pengguna.
  void _showStoreSummarySheet(Listing listing) {
    setState(() {
      _selectedListingId = listing.id;
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        final t = Theme.of(ctx).textTheme;

        // Ambil semua makanan yang dijual oleh toko yang sama untuk ditampilkan di bottom sheet
        final storeListings = _listings
            .where(
              (item) =>
                  item.storeId == listing.storeId ||
                  item.store == listing.store,
            )
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
            boxShadow: AppShadow.e2,
          ),
          padding: const EdgeInsets.all(AppSpace.xl),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar indikator geser sheet
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpace.md),
                      decoration: BoxDecoration(
                        color: c.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Nama Toko & Status Buka
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          Icons.storefront,
                          color: c.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.store,
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              listing.address,
                              style: t.bodySmall?.copyWith(color: c.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Badge Status Buka Toko
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: c.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          'Buka',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: AppSpace.xl),

                  // Judul Seksi Makanan Tersedia di Toko Ini
                  Text(
                    'Makanan Surplus di Toko Ini (${storeListings.length})',
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpace.sm),

                  // Daftar Makanan Toko
                  for (final food in storeListings) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpace.sm),
                      padding: const EdgeInsets.all(AppSpace.sm),
                      decoration: BoxDecoration(
                        color: c.bg,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: c.divider),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail makanan
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: c.surface2,
                              child:
                                  food.image != null && food.image!.isNotEmpty
                                  ? Image.network(
                                      food.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.fastfood,
                                        size: 20,
                                        color: c.textMuted,
                                      ),
                                    )
                                  : Icon(
                                      Icons.fastfood,
                                      size: 20,
                                      color: c.textMuted,
                                    ),
                            ),
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  food.isDonation
                                      ? 'Gratis (Donasi)'
                                      : rupiah(food.price),
                                  style: AppText.mono.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: food.isDonation
                                        ? c.success
                                        : c.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Sisa ${food.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpace.lg),

                  // Tombol CTA
                  AppButton(
                    'Tutup Ringkasan',
                    expand: true,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      // Reset status marker terpilih saat bottom sheet ditutup
      if (mounted) {
        setState(() {
          _selectedListingId = null;
        });
      }
    });
  }

  /// Menentukan jenis (kind) Sticker marker berdasarkan kriteria bisnis:
  /// 1. Jika sedang dipilih -> StickerKind.selected (Warna Hijau Utama)
  /// 2. Jika donasi gratis (price == 0) -> StickerKind.free (Warna Putih-Hijau)
  /// 3. Jika batas waktu ambil < 30 menit -> StickerKind.urgent (Warna Oranye)
  /// 4. Standar harga surplus -> StickerKind.price (Warna Kuning Mustard)
  StickerKind _getStickerKind(Listing item) {
    if (item.id == _selectedListingId) return StickerKind.selected;
    if (item.isDonation) return StickerKind.free;
    if (item.isUrgent) return StickerKind.urgent;
    return StickerKind.price;
  }

  /// Format teks label yang dicetak di atas marker Sticker peta
  String _getStickerLabel(Listing item) {
    if (item.isDonation) return 'Gratis';
    return rupiah(item.price);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // 1. Lapisan Utama: Peta Interaktif OpenStreetMap (OSM)
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 14.5,
              minZoom: 11.0,
              maxZoom: 18.0,
            ),
            children: [
              // TileLayer OSM publik
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.habisin.habisin_mobile',
              ),

              // MarkerLayer: Menempatkan pin toko di atas koordinat geografis
              MarkerLayer(
                markers: [
                  for (final item in _listings)
                    Marker(
                      point: LatLng(item.latitude, item.longitude),
                      width: 90,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          // Pindahkan fokus kamera peta ke titik toko yang diklik
                          _mapController.move(
                            LatLng(item.latitude, item.longitude),
                            15.5,
                          );
                          // Tampilkan modal ringkasan toko
                          _showStoreSummarySheet(item);
                        },
                        child: Sticker(
                          _getStickerLabel(item),
                          kind: _getStickerKind(item),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Bar Informasi Melayang di Atas Peta
          Positioned(
            top: AppSpace.md,
            left: AppSpace.md,
            right: AppSpace.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.sm,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadow.e1,
                border: Border.all(color: c.divider),
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined, size: 20, color: c.primary),
                  const SizedBox(width: AppSpace.sm),
                  // Judul 'Peta Sebaran Makanan' (wajib untuk memenuhi ekspektasi widget test)
                  Text(
                    'Peta Sebaran Makanan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  const Spacer(),
                  // Badge jumlah toko ditemukan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: c.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${_listings.length} Toko',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: c.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Indikator Loading Melayang saat Mengambil Data
          if (_isLoading)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: AppShadow.e1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Memuat titik toko...',
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Floating Action Buttons di Sudut Kanan Bawah Peta
          Positioned(
            bottom: AppSpace.lg,
            right: AppSpace.lg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Refresh Data Peta
                FloatingActionButton.small(
                  heroTag: 'refresh_map',
                  backgroundColor: c.surface,
                  foregroundColor: c.text,
                  tooltip: 'Muat ulang data toko',
                  onPressed: _fetchMapListings,
                  child: const Icon(Icons.refresh, size: 20),
                ),
                const SizedBox(height: AppSpace.sm),

                // Tombol Re-center Peta ke Kampus UI Depok
                FloatingActionButton.small(
                  heroTag: 'recenter_map',
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  tooltip: 'Pusatkan ke Depok / Kampus UI',
                  onPressed: _recenterMap,
                  child: const Icon(Icons.my_location, size: 20),
                ),
              ],
            ),
          ),

          // 5. Pesan Error Melayang jika Jaringan Terputus
          if (_errorMessage != null)
            Positioned(
              bottom: AppSpace.lg,
              left: AppSpace.lg,
              right: 70,
              child: Container(
                padding: const EdgeInsets.all(AppSpace.sm),
                decoration: BoxDecoration(
                  color: c.errorTint,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: c.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 18, color: c.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 11, color: c.error),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
