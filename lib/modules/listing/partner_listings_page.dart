import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/theme.dart';
import '../../core/widgets/components.dart';
import '../catalog/models/listing.dart';

/// Halaman Manajemen Produk Makanan Surplus Mitra (Modul 3).
///
/// Fitur utama yang diimplementasikan:
/// 1. READ: Mengambil dan menampilkan daftar inventaris makanan surplus milik toko mitra.
/// 2. CREATE: Form modal untuk menambah makanan surplus baru dengan validasi harga & stok.
/// 3. UPDATE: Form edit data produk dan toggle cepat status ketersediaan ("Tandai Habis").
/// 4. DELETE: Menghapus makanan dari inventaris dengan dialog konfirmasi pencegahan salah klik.
class PartnerListingsPage extends StatefulWidget {
  const PartnerListingsPage({super.key});

  @override
  State<PartnerListingsPage> createState() => _PartnerListingsPageState();
}

class _PartnerListingsPageState extends State<PartnerListingsPage> {
  // State untuk menampung daftar listing milik mitra dari backend
  List<Listing> _listings = [];

  // State indikator saat request data ke server sedang berlangsung
  bool _isLoading = true;

  // Menyimpan pesan error jika terjadi kegagalan jaringan atau server
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Memuat data inventaris mitra pertama kali saat widget dibangun
    _loadListings();
  }

  /// Mengambil daftar makanan surplus milik mitra dari endpoint GET /api/partner/listings.
  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Panggil ApiService untuk request data ke backend PWS
      final data = await ApiService.instance.fetchPartnerListings();
      if (mounted) {
        setState(() {
          _listings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Bersihkan prefix Exception agar pesan ke pengguna lebih ramah
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// Mengubah status ketersediaan makanan (Tandai Habis / Batalkan Tanda Habis).
  ///
  /// Logic:
  /// - Jika item saat ini habis (stok == 0 atau active == false), kirim POST /undo-sold-out.
  /// - Jika item saat ini aktif, kirim POST /sold-out.
  Future<void> _toggleSoldOut(Listing item) async {
    final isCurrentlySoldOut = item.stock == 0 || !item.active;
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = AppColors.of(context).error;

    try {
      if (isCurrentlySoldOut) {
        // Panggil endpoint undo-sold-out di backend
        await ApiService.instance.undoListingSoldOut(item.id);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Status "${item.name}" berhasil dipulihkan menjadi aktif.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Panggil endpoint sold-out di backend
        await ApiService.instance.markListingSoldOut(item.id);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('"${item.name}" ditandai habis (Sold Out).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // Muat ulang daftar inventaris agar UI tersinkronisasi dengan database backend
      _loadListings();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Menghapus makanan surplus dari inventaris mitra.
  ///
  /// Dilengkapi AlertDialog konfirmasi untuk mencegah ketidaksengajaan terhapus saat demo/pemakaian.
  Future<void> _deleteListing(Listing item) async {
    // Tampilkan dialog konfirmasi penghapusan
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Makanan Surplus?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item.name}" dari inventaris? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(ctx).error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Jika pengguna menekan "Hapus", kirim request DELETE ke backend
    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final errorColor = AppColors.of(context).error;

      try {
        await ApiService.instance.deletePartnerListing(item.id);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('"${item.name}" berhasil dihapus dari inventaris.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh data setelah penghapusan berhasil
        _loadListings();
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Menampilkan modal bottom sheet form untuk Tambah atau Edit Makanan Surplus.
  ///
  /// Parameter:
  /// - [existingItem]: Jika diisi, form bertindak sebagai Edit (UPDATE).
  ///                   Jika null, form bertindak sebagai Tambah Baru (CREATE).
  void _showFormDialog({Listing? existingItem}) {
    final isEditing = existingItem != null;
    final formKey = GlobalKey<FormState>();

    // Controller input teks dengan nilai awal sesuai data yang sedang diedit (jika ada)
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    final categoryController = TextEditingController(text: existingItem?.category ?? 'Roti & kue');
    final descController = TextEditingController(text: existingItem?.description ?? '');
    final normalPriceController =
        TextEditingController(text: existingItem != null ? existingItem.originalPrice.toString() : '');
    final priceController =
        TextEditingController(text: existingItem != null ? existingItem.price.toString() : '0');
    final stockController =
        TextEditingController(text: existingItem != null ? existingItem.stock.toString() : '5');
    final imageController = TextEditingController(text: existingItem?.image ?? '');
    final allergensController = TextEditingController(text: existingItem?.allergens ?? '');

    bool isSubmitting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            final c = AppColors.of(dialogCtx);
            final t = Theme.of(dialogCtx).textTheme;

            return Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                boxShadow: AppShadow.e2,
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpace.xl,
                AppSpace.lg,
                AppSpace.xl,
                // Mengangkat form ke atas saat keyboard virtual ponsel muncul
                MediaQuery.of(dialogCtx).viewInsets.bottom + AppSpace.xl,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar dekoratif
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

                      // Judul Modal Form
                      Text(
                        isEditing ? 'Edit Makanan Surplus' : 'Tambah Makanan Surplus Baru',
                        style: t.titleLarge,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        'Pastikan batas waktu dan harga diskon sudah sesuai.',
                        style: t.bodySmall?.copyWith(color: c.textMuted),
                      ),
                      const SizedBox(height: AppSpace.lg),

                      // 1. Input Nama Makanan (Wajib, maks 60 karakter)
                      AppInput(
                        label: 'Nama Makanan *',
                        controller: nameController,
                        hint: 'Contoh: Roti Manis Cokelat Sisa Siang',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nama makanan wajib diisi';
                          if (v.trim().length > 60) return 'Maksimal 60 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpace.md),

                      // 2. Dropdown Pilihan Kategori Makanan
                      DropdownButtonFormField<String>(
                        initialValue: ['Roti & kue', 'Nasi & lauk', 'Minuman', 'Camilan']
                                .contains(categoryController.text)
                            ? categoryController.text
                            : 'Roti & kue',
                        decoration: InputDecoration(
                          labelText: 'Kategori Makanan',
                          labelStyle: t.labelMedium,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Roti & kue', child: Text('Roti & kue')),
                          DropdownMenuItem(value: 'Nasi & lauk', child: Text('Nasi & lauk')),
                          DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                          DropdownMenuItem(value: 'Camilan', child: Text('Camilan')),
                        ],
                        onChanged: (val) {
                          if (val != null) categoryController.text = val;
                        },
                      ),
                      const SizedBox(height: AppSpace.md),

                      // 3. Input Harga Normal & Harga Surplus (Diskon/Donasi)
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Harga Normal (Rp) *',
                              controller: normalPriceController,
                              keyboardType: TextInputType.number,
                              hint: '20000',
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 0) return 'Nominal tidak valid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: AppInput(
                              label: 'Harga Surplus / 0 (Rp) *',
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              hint: '0 = Donasi',
                              validator: (v) {
                                final p = int.tryParse(v ?? '');
                                final n = int.tryParse(normalPriceController.text) ?? 0;
                                if (p == null || p < 0) return 'Nominal tidak valid';
                                if (n > 0 && p > n) return 'Melebihi harga normal';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.md),

                      // 4. Input Jumlah Porsi Stok Tersedia (Minimal 1)
                      AppInput(
                        label: 'Stok Porsi Tersedia *',
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        hint: 'Jumlah porsi (misal 5)',
                        validator: (v) {
                          final s = int.tryParse(v ?? '');
                          if (s == null || s < 1) return 'Stok minimal 1 porsi';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpace.md),

                      // 5. Deskripsi Makanan
                      AppInput(
                        label: 'Deskripsi Makanan',
                        controller: descController,
                        hint: 'Kondisi makanan, alasan surplus, dll.',
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpace.md),

                      // 6. Catatan Alergen (Opsional)
                      AppInput(
                        label: 'Catatan Alergen (Opsional)',
                        controller: allergensController,
                        hint: 'Misal: Mengandung susu, kacang, telur',
                      ),
                      const SizedBox(height: AppSpace.md),

                      // 7. URL Foto Makanan (Opsional)
                      AppInput(
                        label: 'URL Foto Makanan (Opsional)',
                        controller: imageController,
                        hint: 'https://images.unsplash.com/...',
                      ),
                      const SizedBox(height: AppSpace.xl),

                      // 8. Tombol Eksekusi Simpan
                      AppButton(
                        isEditing ? 'Simpan Perubahan' : 'Tambah ke Inventaris',
                        loading: isSubmitting,
                        expand: true,
                        icon: isEditing ? Icons.save : Icons.add_circle_outline,
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                // Jalankan validasi semua form field
                                if (formKey.currentState?.validate() ?? false) {
                                  setSheetState(() => isSubmitting = true);

                                  // Siapkan payload JSON untuk dikirim ke backend Django
                                  final payload = <String, dynamic>{
                                    'name': nameController.text.trim(),
                                    'category': categoryController.text.trim(),
                                    'description': descController.text.trim(),
                                    'original_price':
                                        int.tryParse(normalPriceController.text) ?? 0,
                                    'price': int.tryParse(priceController.text) ?? 0,
                                    'stock': int.tryParse(stockController.text) ?? 1,
                                    'image': imageController.text.trim().isNotEmpty
                                        ? imageController.text.trim()
                                        : null,
                                    'allergens': allergensController.text.trim(),
                                    'active': true,
                                    // Rentang waktu pengambilan: mulai saat ini s/d 4 jam ke depan
                                    'pickup_start': DateTime.now().toIso8601String(),
                                    'pickup_end': DateTime.now()
                                        .add(const Duration(hours: 4))
                                        .toIso8601String(),
                                  };

                                  final messenger = ScaffoldMessenger.of(context);
                                  try {
                                    if (isEditing) {
                                      // Request PATCH ke /api/partner/listings/<id>
                                      await ApiService.instance
                                          .updatePartnerListing(existingItem.id, payload);
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Listing berhasil diperbarui!'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      // Request POST ke /api/partner/listings
                                      await ApiService.instance.createPartnerListing(payload);
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Makanan surplus baru berhasil ditambahkan!'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                    if (context.mounted) Navigator.pop(sheetCtx);
                                    // Refresh data inventaris
                                    _loadListings();
                                  } catch (e) {
                                    setSheetState(() => isSubmitting = false);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}',
                                        ),
                                        backgroundColor: c.error,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: RefreshIndicator(
        onRefresh: _loadListings,
        child: Column(
          children: [
            // Baris Judul & Tombol Tambah
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.sm),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul 'Kelola Listing' (wajib untuk memenuhi ekspektasi widget test)
                      Text(
                        'Kelola Listing',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_listings.length} produk di inventaris toko',
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Tombol Tambah Makanan Surplus
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: c.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                    onPressed: () => _showFormDialog(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Kontainer Utama Daftar Inventaris
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun tampilan body sesuai kondisi state (Loading, Error, Empty, atau Success)
  Widget _buildBody() {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;

    // 1. Kondisi saat sedang mengambil data dari server
    if (_isLoading) {
      return const StateView.loading();
    }

    // 2. Kondisi jika terjadi error jaringan atau server
    if (_errorMessage != null) {
      return StateView.error(
        message: _errorMessage,
        onAction: _loadListings,
      );
    }

    // 3. Kondisi jika toko mitra belum memiliki listing
    if (_listings.isEmpty) {
      return StateView(
        icon: Icons.inventory_2_outlined,
        title: 'Belum ada produk makanan surplus',
        message: 'Mulai tambahkan makanan surplus toko Anda untuk mengurangi limbah makanan.',
        action: 'Tambah Makanan Pertama',
        onAction: () => _showFormDialog(),
      );
    }

    // 4. Kondisi sukses: Tampilkan daftar kartu inventaris produk
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.xxl),
      itemCount: _listings.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.md),
      itemBuilder: (context, index) {
        final item = _listings[index];
        final isSoldOut = item.stock == 0 || !item.active;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: isSoldOut ? c.divider : c.border.withValues(alpha: 0.5)),
          ),
          color: isSoldOut ? c.surface2.withValues(alpha: 0.5) : c.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail Foto Makanan
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: c.surface2,
                        child: item.image != null && item.image!.isNotEmpty
                            ? Image.network(
                                item.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    Icon(Icons.fastfood, color: c.textMuted),
                              )
                            : Icon(Icons.fastfood, color: c.textMuted),
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),

                    // Detail Nama & Kategori
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Badge Stok / Status Habis
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSoldOut ? c.errorTint : c.primaryTint,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  isSoldOut ? 'Habis (Sold Out)' : 'Tersedia: ${item.stock} porsi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isSoldOut ? c.error : c.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Menu Opsi Lainnya (Edit, Toggle, Hapus)
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, size: 20, color: c.textMuted),
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    _showFormDialog(existingItem: item);
                                  } else if (action == 'toggle') {
                                    _toggleSoldOut(item);
                                  } else if (action == 'delete') {
                                    _deleteListing(item);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit Produk'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSoldOut
                                              ? Icons.replay_outlined
                                              : Icons.block_outlined,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(isSoldOut ? 'Batalkan Habis' : 'Tandai Habis'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 18, color: c.error),
                                        const SizedBox(width: 8),
                                        Text('Hapus', style: TextStyle(color: c.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: isSoldOut ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kategori: ${item.category}',
                            style: t.bodySmall?.copyWith(color: c.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSpace.lg),

                // Baris Nominal Harga & Tombol Shortcut Cepat
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.isDonation ? 'Donasi Gratis' : rupiah(item.price),
                          style: AppText.mono.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: item.isDonation ? c.success : c.primary,
                          ),
                        ),
                        if (item.originalPrice > 0 && !item.isDonation)
                          Text(
                            rupiah(item.originalPrice),
                            style: AppText.mono.copyWith(
                              fontSize: 12,
                              color: c.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    // Tombol Cepat: "Tandai Habis" atau "Aktifkan Kembali"
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: isSoldOut ? c.primary : c.urgency),
                      ),
                      icon: Icon(
                        isSoldOut ? Icons.check_circle_outline : Icons.highlight_off,
                        size: 16,
                        color: isSoldOut ? c.primary : c.urgency,
                      ),
                      label: Text(
                        isSoldOut ? 'Aktifkan' : 'Tandai Habis',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSoldOut ? c.primary : c.urgency,
                        ),
                      ),
                      onPressed: () => _toggleSoldOut(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
