/// Model data untuk Listing Makanan Surplus dan Ringkasan Toko.
/// Sesuai schema serializer backend Django REST Framework (DRF).
library;

class StoreSummary {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final String landmark;
  final String? profilePicture;

  const StoreSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isOpen,
    this.landmark = '',
    this.profilePicture,
  });

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    return StoreSummary(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Toko Tanpa Nama',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['is_open'] as bool? ?? true,
      landmark: json['landmark'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_open': isOpen,
        'landmark': landmark,
        'profile_picture': profilePicture,
      };
}

class Listing {
  final int id;
  final String name;
  final String store;
  final String category;
  final String description;
  final String address;
  final int price;
  final int originalPrice;
  final int stock;
  final String? image;
  final double latitude;
  final double longitude;
  final DateTime? pickupStart;
  final DateTime? pickupEnd;
  final bool active;
  final int storeId;
  final StoreSummary? storeSummary;
  final String packaging;
  final String allergens;
  final String buyerNotes;
  final bool takenDown;

  const Listing({
    required this.id,
    required this.name,
    required this.store,
    required this.category,
    required this.description,
    required this.address,
    required this.price,
    required this.originalPrice,
    required this.stock,
    this.image,
    required this.latitude,
    required this.longitude,
    this.pickupStart,
    this.pickupEnd,
    required this.active,
    required this.storeId,
    this.storeSummary,
    this.packaging = '',
    this.allergens = '',
    this.buyerNotes = '',
    this.takenDown = false,
  });

  /// True jika makanan surplus dibagikan sebagai donasi gratis.
  bool get isDonation => price == 0;

  /// True jika makanan aktif, belum diambil/sold-out, dan tidak di-takedown.
  bool get isAvailable => active && stock > 0 && !takenDown;

  /// Persentase diskon dari harga normal.
  int get discountPercent {
    if (originalPrice > 0 && price > 0 && originalPrice > price) {
      return ((1 - (price / originalPrice)) * 100).round();
    }
    return 0;
  }

  /// Format sisa waktu menuju batas akhir ambil (pickupEnd).
  Duration get timeLeft {
    if (pickupEnd == null) return Duration.zero;
    return pickupEnd!.difference(DateTime.now());
  }

  /// True jika waktu tersisa kurang dari 30 menit.
  bool get isUrgent => timeLeft.inMinutes > 0 && timeLeft.inMinutes <= 30;

  /// Format jam deadline "HH.mm".
  String get deadlineFormatted {
    if (pickupEnd == null) return '23:59';
    final local = pickupEnd!.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  factory Listing.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    return Listing(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Makanan Surplus',
      store: json['store'] as String? ?? 'Toko Mitra',
      category: json['category'] as String? ?? 'Lainnya',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      image: json['image'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      pickupStart: parseDate(json['pickup_start']),
      pickupEnd: parseDate(json['pickup_end']),
      active: json['active'] as bool? ?? true,
      storeId: json['store_id'] as int? ?? 0,
      storeSummary: json['store_summary'] != null && json['store_summary'] is Map<String, dynamic>
          ? StoreSummary.fromJson(json['store_summary'] as Map<String, dynamic>)
          : null,
      packaging: json['packaging'] as String? ?? '',
      allergens: json['allergens'] as String? ?? '',
      buyerNotes: json['buyer_notes'] as String? ?? '',
      takenDown: json['taken_down'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'store': store,
        'category': category,
        'description': description,
        'address': address,
        'price': price,
        'original_price': originalPrice,
        'stock': stock,
        'image': image,
        'latitude': latitude,
        'longitude': longitude,
        'pickup_start': pickupStart?.toIso8601String(),
        'pickup_end': pickupEnd?.toIso8601String(),
        'active': active,
        'store_id': storeId,
        'store_summary': storeSummary?.toJson(),
        'packaging': packaging,
        'allergens': allergens,
        'buyer_notes': buyerNotes,
        'taken_down': takenDown,
      };
}
