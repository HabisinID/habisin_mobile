import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/theme.dart';
import '../../core/widgets/components.dart';
import 'models/listing.dart';

/// Halaman Katalog & Pencarian Makanan Surplus (Modul 5 - Pembeli).
/// Menyediakan pencarian dengan debouncer, filter kategori, toggle donasi gratis,
/// pengurutan harga/deadline, dan dialog detail produk.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Filter & Sort State
  String _selectedCategory = 'Semua';
  bool _freeOnly = false;
  String _sortBy =
      'default'; // 'default', 'price_asc', 'discount_desc', 'urgent'

  static const List<String> _categories = [
    'Semua',
    'Roti & kue',
    'Nasi & lauk',
    'Minuman',
    'Camilan',
  ];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.instance.fetchListings();
      if (mounted) {
        setState(() {
          _allListings = data;
          _isLoading = false;
        });
        _applyFilters();
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<Listing> result = _allListings.where((item) {
      // Filter teks pencarian (nama makanan atau nama toko)
      final matchQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.store.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);

      // Filter kategori
      final matchCategory =
          _selectedCategory == 'Semua' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();

      // Filter donasi gratis
      final matchFree = !_freeOnly || item.isDonation;

      return matchQuery && matchCategory && matchFree;
    }).toList();

    // Penerapan pengurutan (Sorting)
    switch (_sortBy) {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'discount_desc':
        result.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
        break;
      case 'urgent':
        result.sort((a, b) {
          final aEnd =
              a.pickupEnd ?? DateTime.now().add(const Duration(days: 1));
          final bEnd =
              b.pickupEnd ?? DateTime.now().add(const Duration(days: 1));
          return aEnd.compareTo(bEnd);
        });
        break;
      default:
        // Urutan standar: produk tersedia diutamakan
        result.sort((a, b) {
          if (a.isAvailable && !b.isAvailable) return -1;
          if (!a.isAvailable && b.isAvailable) return 1;
          return 0;
        });
    }

    setState(() {
      _filteredListings = result;
    });
  }

  void _showDetailBottomSheet(Listing listing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        final t = Theme.of(ctx).textTheme;

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
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpace.lg),
                      decoration: BoxDecoration(
                        color: c.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Foto Produk
                  if (listing.image != null && listing.image!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          listing.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: c.surface2,
                            child: Icon(
                              Icons.fastfood,
                              size: 48,
                              color: c.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpace.lg),

                  // Kategori & Badge Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          listing.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: c.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      if (listing.pickupEnd != null)
                        Countdown.fromDuration(listing.timeLeft),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),

                  // Judul & Nama Toko
                  Text(listing.name, style: t.headlineSmall),
                  const SizedBox(height: AppSpace.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 16,
                        color: c.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.store,
                          style: t.bodyMedium?.copyWith(
                            color: c.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (listing.address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: c.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: t.bodySmall?.copyWith(color: c.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Divider(height: AppSpace.xxl),

                  // Harga & Diskon
                  Wrap(
                    spacing: AppSpace.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        listing.isDonation
                            ? 'Gratis (Donasi)'
                            : rupiah(listing.price),
                        style: AppText.mono.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: listing.isDonation ? c.success : c.primary,
                        ),
                      ),
                      if (listing.originalPrice > 0 && !listing.isDonation)
                        Text(
                          rupiah(listing.originalPrice),
                          style: AppText.mono.copyWith(
                            fontSize: 14,
                            color: c.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (listing.discountPercent > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: c.primaryTint,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'Hemat ${listing.discountPercent}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: c.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Sisa stok: ${listing.stock} porsi',
                    style: t.bodyMedium?.copyWith(
                      color: listing.stock > 0 ? c.text : c.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (listing.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.md),
                    Text('Deskripsi:', style: t.titleSmall),
                    const SizedBox(height: 4),
                    Text(listing.description, style: t.bodyMedium),
                  ],

                  if (listing.allergens.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      'Alergen: ${listing.allergens}',
                      style: t.bodySmall?.copyWith(color: c.error),
                    ),
                  ],

                  const SizedBox(height: AppSpace.xl),

                  // Tombol Aksi
                  AppButton(
                    listing.isAvailable ? 'Pesan Makanan Ini' : 'Stok Habis',
                    expand: true,
                    icon: Icons.shopping_bag_outlined,
                    onPressed: listing.isAvailable
                        ? () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Siap memesan "${listing.name}". Lanjutkan ke tab Pesanan.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
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
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.md,
                AppSpace.lg,
                0,
              ),
              child: AppInput(
                label: 'Katalog & Pencarian',
                controller: _searchController,
                hint: 'Ketik nama makanan atau toko...',
                prefixIcon: Icons.search,
                onChanged: _onSearchChanged,
                suffix: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
            ),

            // Horizontal Chips Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: AppSpace.sm,
              ),
              child: Row(
                children: [
                  for (final cat in _categories) ...[
                    AppChip(
                      cat,
                      selected: _selectedCategory == cat,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                        _applyFilters();
                      },
                    ),
                    const SizedBox(width: AppSpace.sm),
                  ],
                  // Filter Toggle Donasi Gratis
                  AppChip(
                    'Donasi Gratis',
                    icon: Icons.volunteer_activism_outlined,
                    selected: _freeOnly,
                    onSelected: (val) {
                      setState(() {
                        _freeOnly = val;
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),

            // Sort & Info Result Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Text(
                    '${_filteredListings.length} makanan ditemukan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.textMuted,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    tooltip: 'Urutkan',
                    initialValue: _sortBy,
                    onSelected: (val) {
                      setState(() {
                        _sortBy = val;
                      });
                      _applyFilters();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'default',
                        child: Text('Urutan Default'),
                      ),
                      PopupMenuItem(
                        value: 'urgent',
                        child: Text('Batas Ambil Terdekat'),
                      ),
                      PopupMenuItem(
                        value: 'price_asc',
                        child: Text('Harga Termurah'),
                      ),
                      PopupMenuItem(
                        value: 'discount_desc',
                        child: Text('Diskon Tertinggi'),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort, size: 16, color: c.primary),
                        const SizedBox(width: 4),
                        Text(
                          switch (_sortBy) {
                            'urgent' => 'Paling Urgent',
                            'price_asc' => 'Termurah',
                            'discount_desc' => 'Diskon Tertinggi',
                            _ => 'Urutkan',
                          },
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: c.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Main Content Area
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const StateView.loading();
    }

    if (_errorMessage != null) {
      return StateView.error(message: _errorMessage, onAction: _loadListings);
    }

    if (_filteredListings.isEmpty) {
      return StateView(
        icon: Icons.search_off_outlined,
        title: 'Tidak ada makanan surplus ditemukan',
        message: 'Coba ubah kata kunci pencarian atau sesuaikan filter kategori Anda.',
        action: 'Reset Filter',
        onAction: () {
          _searchController.clear();
          setState(() {
            _selectedCategory = 'Semua';
            _freeOnly = false;
            _sortBy = 'default';
          });
          _applyFilters();
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpace.xxl),
      itemCount: _filteredListings.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _filteredListings[index];
        final double timeLeftRatio = (item.pickupEnd != null)
            ? (item.timeLeft.inMinutes / 180).clamp(0.0, 1.0)
            : 1.0;

        return ListingRow(
          title: item.name,
          shop: '${item.store} · ${item.address}',
          deadline: item.deadlineFormatted,
          price: item.price,
          normalPrice: item.originalPrice > 0 ? item.originalPrice : null,
          stockLabel: '${item.stock} porsi tersisa',
          imageUrl: item.image,
          timeLeft: timeLeftRatio,
          onTap: () => _showDetailBottomSheet(item),
        );
      },
    );
  }
}
