part of 'list_items_cubit.dart';

sealed class ListItemsState {}

final class ListItemsInitial extends ListItemsState {}

final class ListItemsLoading extends ListItemsState {}

final class ListItemsLoaded extends ListItemsState {
  ListItemsLoaded(this.items, {this.pendingIds = const {}, this.error});
  final List<ListItem> items;

  /// listItemIds with a request currently in flight (qty write, purchase
  /// toggle, delete) — the UI shows the Zaytona logo on that row in place
  /// of its usual control while its own call is pending. Other rows stay
  /// fully interactive; nothing here blocks further user actions.
  final Set<String> pendingIds;

  /// One-shot mutation-failure message (e.g. a failed qty update) — the
  /// list stays visible; the UI consumes this once via a SnackBar.
  final String? error;

  ListItemsLoaded withPending(String listItemId, bool pending) {
    final next = Set<String>.from(pendingIds);
    pending ? next.add(listItemId) : next.remove(listItemId);
    return ListItemsLoaded(items, pendingIds: next);
  }

  ListItemsLoaded copyWith({String? error}) =>
      ListItemsLoaded(items, pendingIds: pendingIds, error: error);
}

final class ListItemsError extends ListItemsState {
  ListItemsError(this.message);
  final String message;
}
