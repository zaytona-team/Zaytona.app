import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/catalog_entry.dart';

abstract class PersonalCatalogRepository {
  /// Cached result only — fast, no network. Empty list if never refreshed.
  Future<Result<Failure, List<CatalogEntry>>> getMyItems();

  /// Forces a fresh fetch (today: aggregated across every list in every
  /// group the user belongs to; once `GET /users/me/items` ships, a single
  /// call) and updates the cache.
  Future<Result<Failure, List<CatalogEntry>>> refreshMyItems();
}
