import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../core/network/network_client.dart';
import '../../../core/network/network_request.dart';
import '../../../core/network/remote_data_source_base.dart';

/// Bridges the design system's fixed [CategoryId] slugs (e.g. "dairy") to
/// the backend's database-generated category UUIDs (GET /categories).
///
/// The backend seeds its 16 categories with English display names ("Dairy
/// & Eggs") that don't match the design system's slugs or order 1:1, and
/// assigns each a random UUID as its primary key — so a slug can never be
/// sent as `category_id` directly (the backend validates it's a real row).
/// This is a fixed static mapping because categories are read-only,
/// pre-seeded reference data with no create/update/delete endpoints.
class CategoryRegistry with RemoteDataSourceBase {
  CategoryRegistry._();
  static final CategoryRegistry instance = CategoryRegistry._();

  static const Map<CategoryId, String> _backendName = {
    CategoryId.produce: 'Fresh Produce',
    CategoryId.meat: 'Meat & Seafood',
    CategoryId.dairy: 'Dairy & Eggs',
    CategoryId.bakery: 'Bakery',
    CategoryId.pantry: 'Pantry',
    CategoryId.cooking: 'Cooking Essentials',
    CategoryId.breakfast: 'Breakfast',
    CategoryId.snacks: 'Snacks',
    CategoryId.beverages: 'Beverages',
    CategoryId.frozen: 'Frozen',
    CategoryId.ready: 'Ready-to-Eat',
    CategoryId.baby: 'Baby',
    CategoryId.care: 'Personal Care',
    CategoryId.health: 'Health',
    CategoryId.household: 'Household',
    CategoryId.pets: 'Pets',
  };

  static const _cacheKey = 'category_registry_cache';

  Map<String, String>? _nameToUuid; // backend name -> uuid
  Map<String, CategoryId>? _uuidToSlug; // uuid -> CategoryId
  Future<void>? _loading;

  /// Resolves once the mapping is usable (from disk cache or network), then
  /// refreshes from network in the background. Safe to call repeatedly
  /// (e.g. from initState) — later calls reuse the same in-flight result.
  Future<void> ensureLoaded() {
    if (_nameToUuid != null) return Future.value();
    return _loading ??= _loadFromDiskThenNetwork();
  }

  Future<void> _loadFromDiskThenNetwork() async {
    final cached = await _readCache();
    if (cached != null) {
      _apply(cached);
      unawaited(_load()); // refresh in the background, categories rarely change
    } else {
      await _load();
    }
  }

  Future<void> _load() async {
    try {
      final res = await run(() => NetworkClient.instance.get<Response>(
            request: NetworkRequest(endpoint: '/categories'),
            converter: (response) => response,
          ));
      final data = res.data;
      if (data is! List) return;
      final nameToUuid = <String, String>{};
      for (final row in data) {
        if (row is Map && row['name'] is String && row['category_id'] is String) {
          nameToUuid[row['name'] as String] = row['category_id'] as String;
        }
      }
      _apply(nameToUuid);
      unawaited(_writeCache(nameToUuid));
    } catch (_) {
      // Leave unresolved — callers fall back to omitting category_id
      // rather than sending a value the backend will reject.
    }
  }

  void _apply(Map<String, String> nameToUuid) {
    _nameToUuid = nameToUuid;
    _uuidToSlug = {
      for (final entry in _backendName.entries)
        if (nameToUuid[entry.value] != null) nameToUuid[entry.value]!: entry.key,
    };
  }

  Future<Map<String, String>?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      return (jsonDecode(raw) as Map<String, dynamic>).cast<String, String>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(Map<String, String> nameToUuid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(nameToUuid));
    } catch (_) {
      // Non-fatal — the in-memory mapping is already usable this session.
    }
  }

  /// The real backend UUID for [slug], or null if not loaded/found yet.
  String? uuidFor(CategoryId slug) => _nameToUuid?[_backendName[slug]];

  /// Resolves a value coming back from the backend — a real UUID — to the
  /// [CategoryId] slug the picker UI understands. Falls back to
  /// [CategoryId.pantry] if unloaded or unrecognized.
  CategoryId slugFor(String? backendValue) {
    if (backendValue == null) return CategoryId.pantry;
    return _uuidToSlug?[backendValue] ?? CategoryId.pantry;
  }
}
