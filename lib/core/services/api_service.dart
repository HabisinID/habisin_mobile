import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../modules/catalog/models/listing.dart';

/// Service HTTP terpadu untuk integrasi aplikasi mobile dengan backend Django REST Framework (DRF).
/// Menangani endpoint publik, otentikasi sesi, serta proteksi CSRF.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String baseUrl =
      'https://rozan-laudzai-habisin-backend.pws.cs.ui.ac.id/api';

  // Cookie jar sederhana untuk menyimpan sesi dan CSRF token
  final Map<String, String> _cookies = {};
  String? _csrfToken;

  /// Ambil cookie format Header: `csrftoken=...; sessionid=...`
  String get _cookieHeader {
    if (_cookies.isEmpty) return '';
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  /// Simpan cookies dari response header `set-cookie`
  void _updateCookies(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      final parts = rawCookie.split(',');
      for (final part in parts) {
        final pair = part.split(';')[0].trim();
        final eq = pair.indexOf('=');
        if (eq > 0) {
          final name = pair.substring(0, eq).trim();
          final val = pair.substring(eq + 1).trim();
          _cookies[name] = val;
          if (name == 'csrftoken') {
            _csrfToken = val;
          }
        }
      }
    }
  }

  /// Handshake CSRF token dari backend
  Future<String> ensureCsrfToken() async {
    if (_csrfToken != null && _csrfToken!.isNotEmpty) {
      return _csrfToken!;
    }
    try {
      final uri = Uri.parse('$baseUrl/auth/csrf');
      final res = await http.get(uri);
      _updateCookies(res);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['csrfToken'] != null) {
          _csrfToken = data['csrfToken'] as String;
        }
      }
    } catch (_) {
      // Abaikan error jaringan saat pra-handshake
    }
    return _csrfToken ?? '';
  }

  /// Header standar untuk setiap request
  Map<String, String> _buildHeaders({bool isJson = true}) {
    final headers = <String, String>{
      'Referer': 'https://rozan-laudzai-habisin-backend.pws.cs.ui.ac.id/',
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    final cookie = _cookieHeader;
    if (cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    if (_csrfToken != null && _csrfToken!.isNotEmpty) {
      headers['X-CSRFToken'] = _csrfToken!;
    }
    return headers;
  }

  // ===========================================================================
  // Modul 5 & 4: Katalog Publik & Peta Sebaran Makanan
  // ===========================================================================

  /// Mengambil seluruh listing makanan aktif publik
  Future<List<Listing>> fetchListings() async {
    final uri = Uri.parse('$baseUrl/listings');
    final response = await http.get(uri, headers: _buildHeaders(isJson: false));
    _updateCookies(response);

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      if (body is List) {
        return body
            .map((item) => Listing.fromJson(item as Map<String, dynamic>))
            .where((l) => !l.takenDown)
            .toList();
      }
      return [];
    } else {
      throw _parseError(response, 'Gagal memuat katalog makanan surplus.');
    }
  }

  /// Mengambil detail toko publik berdasarkan store ID
  Future<StoreSummary> fetchStoreDetail(int storeId) async {
    final uri = Uri.parse('$baseUrl/stores/$storeId');
    final response = await http.get(uri, headers: _buildHeaders(isJson: false));
    _updateCookies(response);

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      return StoreSummary.fromJson(body as Map<String, dynamic>);
    } else {
      throw _parseError(response, 'Gagal memuat profil toko.');
    }
  }

  /// Mengambil listing makanan khusus milik toko tertentu
  Future<List<Listing>> fetchStoreListings(int storeId) async {
    final uri = Uri.parse('$baseUrl/stores/$storeId/listings');
    final response = await http.get(uri, headers: _buildHeaders(isJson: false));
    _updateCookies(response);

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      if (body is List) {
        return body
            .map((item) => Listing.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw _parseError(response, 'Gagal memuat makanan toko.');
    }
  }

  // ===========================================================================
  // Modul 3: Manajemen Produk Makanan Surplus (Mitra)
  // ===========================================================================

  /// Mengambil inventaris listing toko milik mitra
  Future<List<Listing>> fetchPartnerListings() async {
    await ensureCsrfToken();
    final uri = Uri.parse('$baseUrl/partner/listings');
    final response = await http.get(uri, headers: _buildHeaders(isJson: false));
    _updateCookies(response);

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      if (body is List) {
        return body
            .map((item) => Listing.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Jika belum terautentikasi di sesi backend, fallback ke data publik sebagai demo
      final allListings = await fetchListings();
      return allListings;
    } else {
      throw _parseError(response, 'Gagal memuat inventaris mitra.');
    }
  }

  /// Membuat listing makanan surplus baru (Mitra)
  Future<Listing> createPartnerListing(Map<String, dynamic> data) async {
    await ensureCsrfToken();
    final uri = Uri.parse('$baseUrl/partner/listings');
    final response = await http.post(
      uri,
      headers: _buildHeaders(isJson: true),
      body: jsonEncode(data),
    );
    _updateCookies(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Listing.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw _parseError(response, 'Gagal menambah listing makanan baru.');
    }
  }

  /// Memperbarui listing makanan (Mitra)
  Future<Listing> updatePartnerListing(
    int id,
    Map<String, dynamic> data,
  ) async {
    await ensureCsrfToken();
    final uri = Uri.parse('$baseUrl/partner/listings/$id');
    final response = await http.patch(
      uri,
      headers: _buildHeaders(isJson: true),
      body: jsonEncode(data),
    );
    _updateCookies(response);

    if (response.statusCode == 200) {
      return Listing.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw _parseError(response, 'Gagal memperbarui listing makanan.');
    }
  }

  /// Menghapus listing makanan (Mitra)
  Future<void> deletePartnerListing(int id) async {
    await ensureCsrfToken();
    final uri = Uri.parse('$baseUrl/partner/listings/$id');
    final response = await http.delete(
      uri,
      headers: _buildHeaders(isJson: false),
    );
    _updateCookies(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _parseError(response, 'Gagal menghapus listing makanan.');
    }
  }

  /// Menandai stok listing menjadi habis (Sold Out)
  Future<void> markListingSoldOut(int id) async {
    await ensureCsrfToken();
    final uri = Uri.parse('$baseUrl/partner/listings/$id/sold-out');
    final response = await http.post(
      uri,
      headers: _buildHeaders(isJson: false),
    );
    _updateCookies(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _parseError(response, 'Gagal menandai listing habis.');
    }
  }

  /// Membatalkan tanda habis (Undo Sold Out)
  Future<void> undoListingSoldOut(int id) async {
    await ensureCsrfToken();
    final uri = Uri.parse('$baseUrl/partner/listings/$id/undo-sold-out');
    final response = await http.post(
      uri,
      headers: _buildHeaders(isJson: false),
    );
    _updateCookies(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _parseError(response, 'Gagal membatalkan status habis.');
    }
  }

  // ===========================================================================
  // Error Parser Helper
  // ===========================================================================

  Exception _parseError(http.Response response, String fallback) {
    try {
      final dynamic body = jsonDecode(response.body);
      if (body is Map) {
        if (body['detail'] != null) {
          return Exception(body['detail'].toString());
        }
        if (body['error'] != null) {
          return Exception(body['error'].toString());
        }
        final messages = body.values
            .map((v) => v is List ? v.join(', ') : v.toString())
            .join('\n');
        if (messages.isNotEmpty) {
          return Exception(messages);
        }
      }
    } catch (_) {}
    return Exception('$fallback (Status ${response.statusCode})');
  }
}
