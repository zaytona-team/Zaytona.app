import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/catalog_entry.dart';
import '../../domain/repositories/personal_catalog_repository.dart';
import '../datasources/remote/personal_catalog_remote_datasource.dart';

/// Personal item history, backed by `GET /users/me/items`.
class PersonalCatalogRepositoryImpl implements PersonalCatalogRepository {
  PersonalCatalogRepositoryImpl({
    required PersonalCatalogRemoteDataSource remoteDataSource,
  }) : _ds = remoteDataSource;

  final PersonalCatalogRemoteDataSource _ds;

  static const _cacheKey = 'personal_catalog_cache';

  @override
  Future<Result<Failure, List<CatalogEntry>>> getMyItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return const Success([]);
    final decoded = jsonDecode(raw) as List;
    return Success(decoded
        .map((e) => CatalogEntry.fromJson(e as Map<String, dynamic>))
        .toList());
  }

  @override
  Future<Result<Failure, List<CatalogEntry>>> refreshMyItems() async {
    try {
      final res = await _ds.getMyItems();
      final data = res.data;
      // Every repository in this codebase reuses the same class-level
      // default Arabic copy from core/error/failure.dart instead of
      // re-typing the message per call site.
      if (data is! List) {
        return const ResultError(ValidationFailure());
      }

      final entries = data
          .whereType<Map<String, dynamic>>()
          .map(CatalogEntry.fromJson)
          .toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(entries.map((e) => e.toJson()).toList()),
      );

      return Success(entries);
    } on NetworkException catch (e) {
      return ResultError(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return ResultError(ServerFailure(e.message));
    } catch (_) {
      return const ResultError(ServerFailure());
    }
  }
}
