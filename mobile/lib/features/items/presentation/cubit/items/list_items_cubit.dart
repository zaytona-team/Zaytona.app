import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/token_storage.dart';
import '../../../../../core/realtime/socket_service.dart';
import '../../../../lists/domain/entities/shopping_list.dart';
import '../../../../lists/domain/usecases/delete_list_usecase.dart';
import '../../../../lists/domain/usecases/rename_list_usecase.dart';
import '../../../domain/entities/list_item.dart';
import '../../../domain/usecases/delete_all_items_usecase.dart';
import '../../../domain/usecases/delete_item_usecase.dart';
import '../../../domain/usecases/get_list_items_usecase.dart';
import '../../../domain/usecases/set_purchased_usecase.dart';
import '../../../domain/usecases/update_item_usecase.dart';

part 'list_items_state.dart';

/// Drives the list detail screen: loads items, toggles purchase, edits and
/// deletes. Mutations update the loaded list in place (no full reload) so
/// checking an item off feels instant.
///
/// Also stays live via Socket.IO: [load] subscribes to item.* events for
/// this list so other group members' edits show up without a refresh.
/// Events the caller's own action just caused are skipped (actor_user_id
/// match) — the REST response already updated the state synchronously.
class ListItemsCubit extends Cubit<ListItemsState> {
  ListItemsCubit(
    this._getListItemsUseCase,
    this._setPurchasedUseCase,
    this._updateItemUseCase,
    this._deleteItemUseCase,
    this._deleteAllItemsUseCase,
    this._deleteListUseCase,
    this._renameListUseCase,
    this._socketService,
  ) : super(ListItemsInitial());

  final GetListItemsUseCase _getListItemsUseCase;
  final SetPurchasedUseCase _setPurchasedUseCase;
  final UpdateItemUseCase _updateItemUseCase;
  final DeleteItemUseCase _deleteItemUseCase;
  final DeleteAllItemsUseCase _deleteAllItemsUseCase;
  final DeleteListUseCase _deleteListUseCase;
  final RenameListUseCase _renameListUseCase;
  final SocketService _socketService;

  final Set<String> _writingIds = {};
  final Map<String, double> _pendingQtyTargets = {};
  final Map<String, double> _lastConfirmedQty = {};
  final List<StreamSubscription<Map<String, dynamic>>> _socketSubs = [];

  Future<void> load(String listId) async {
    emit(ListItemsLoading());
    final result = await _getListItemsUseCase(GetListItemsParams(listId));
    result.fold(
      (failure) => emit(ListItemsError(failure.message)),
      (items) => emit(ListItemsLoaded(items)),
    );
    await _subscribeToRealtime(listId);
  }

  Future<void> _subscribeToRealtime(String listId) async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    _socketSubs.clear();
    final myId = await TokenStorage.readUserId();

    void listen(String event, void Function(Map<String, dynamic>) handler) {
      _socketSubs.add(_socketService.on(event).listen((data) {
        if (data['list_id'] != listId) return;
        if (data['actor_user_id'] == myId) return;
        handler(data);
      }));
    }

    listen('item.added', (data) => itemAdded(ListItem.fromJson(data['item'])));
    listen('item.updated', (data) => _remoteReplace(ListItem.fromJson(data['item'])));
    listen('item.purchased', (data) => _remoteReplace(ListItem.fromJson(data['item'])));
    listen('item.unpurchased', (data) => _remoteReplace(ListItem.fromJson(data['item'])));
    listen('item.deleted', (data) => _remoteRemove(data['list_item_id'] as String));
    listen('item.bulk_deleted', (_) => load(listId));
  }

  void _remoteReplace(ListItem item) {
    final current = state;
    if (current is ListItemsLoaded) _replace(current, item);
  }

  void _remoteRemove(String listItemId) {
    final current = state;
    if (current is! ListItemsLoaded) return;
    emit(ListItemsLoaded(
      [for (final i in current.items) if (i.listItemId != listItemId) i],
      pendingIds: current.pendingIds,
    ));
  }

  @override
  Future<void> close() async {
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    return super.close();
  }

  Future<void> togglePurchased(ListItem item) async {
    final current = state;
    if (current is! ListItemsLoaded) return;
    emit(current.withPending(item.listItemId, true));
    final result = await _setPurchasedUseCase(SetPurchasedParams(
      listId: item.listId,
      listItemId: item.listItemId,
      isBought: !item.isBought,
    ));
    final afterCall = state;
    if (afterCall is! ListItemsLoaded) return;
    result.fold(
      // A failed mutation shouldn't blank the whole list — keep it loaded
      // and surface the error as a one-shot message instead.
      (failure) => emit(afterCall
          .withPending(item.listItemId, false)
          .copyWith(error: failure.message)),
      (updated) => _replace(afterCall.withPending(item.listItemId, false), updated),
    );
  }

  /// Used for full-item edits (name, unit, notes, etc. — see the edit-item
  /// sheet). Blocks on the server round trip and shows the Zaytona logo
  /// (via [ListItemsLoaded.pendingIds]) in place of the row's contents
  /// while pending. Quantity-only changes from the stepper go through
  /// [changeQuantity] instead, which updates optimistically.
  Future<void> updateItem(ListItem item) async {
    final current = state;
    if (current is! ListItemsLoaded) return;
    emit(current.withPending(item.listItemId, true));
    final result = await _updateItemUseCase(
      UpdateItemParams(listId: item.listId, item: item),
    );
    final afterCall = state;
    if (afterCall is! ListItemsLoaded) return;
    result.fold(
      (failure) => emit(afterCall
          .withPending(item.listItemId, false)
          .copyWith(error: failure.message)),
      (updated) => _replace(afterCall.withPending(item.listItemId, false), updated),
    );
  }

  Future<void> deleteItem(ListItem item) async {
    final current = state;
    if (current is! ListItemsLoaded) return;
    emit(current.withPending(item.listItemId, true));
    final result = await _deleteItemUseCase(DeleteItemParams(
      listId: item.listId,
      listItemId: item.listItemId,
    ));
    final afterCall = state;
    if (afterCall is! ListItemsLoaded) return;
    result.fold(
      (failure) => emit(afterCall
          .withPending(item.listItemId, false)
          .copyWith(error: failure.message)),
      (_) => emit(ListItemsLoaded(
        [
          for (final i in afterCall.items)
            if (i.listItemId != item.listItemId) i,
        ],
        pendingIds: afterCall.withPending(item.listItemId, false).pendingIds,
      )),
    );
  }

  /// Deletes the whole list. Returns whether it succeeded; on failure the
  /// current loaded state is kept with an error message for the page's
  /// existing one-shot error listener to surface.
  Future<bool> deleteList({
    required String groupId,
    required String listId,
  }) async {
    final result = await _deleteListUseCase(
      DeleteListParams(groupId: groupId, listId: listId),
    );
    final current = state;
    return result.fold(
      (failure) {
        if (current is ListItemsLoaded) {
          emit(current.copyWith(error: failure.message));
        }
        return false;
      },
      (_) => true,
    );
  }

  /// Renames the list and/or updates its accent color. Returns the
  /// updated list on success (for the page to mirror into its own display
  /// state) or null on failure — the failure message is surfaced through
  /// the existing one-shot [error] field.
  Future<ShoppingList?> renameList(String listId, String name, {String? color}) async {
    final result = await _renameListUseCase(
      RenameListParams(listId: listId, name: name, color: color),
    );
    final current = state;
    return result.fold(
      (failure) {
        if (current is ListItemsLoaded) {
          emit(current.copyWith(error: failure.message));
        }
        return null;
      },
      (updated) => updated,
    );
  }

  /// Deletes every item on the list via the single atomic bulk-delete
  /// endpoint, then reloads so the final state always reflects the server.
  Future<void> deleteAllItems(String listId) async {
    final current = state;
    if (current is! ListItemsLoaded) return;
    final result = await _deleteAllItemsUseCase(
      DeleteAllItemsParams(listId: listId),
    );
    result.fold(
      (failure) => emit(current.copyWith(error: failure.message)),
      (_) {},
    );
    await load(listId);
  }

  /// Called by the add-item flow so a new item appears without a reload.
  ///
  /// The backend merges an add for a name+unit that's already active on
  /// the list into that existing row (quantity += requested) instead of
  /// creating a second one — so the response can be either a genuinely
  /// new row or the existing one with its quantity bumped. Upsert by id
  /// so a merge updates the existing row in place instead of appending a
  /// second, client-side-only duplicate of it.
  void itemAdded(ListItem item) {
    final current = state;
    if (current is! ListItemsLoaded) return;
    final alreadyPresent = current.items.any((i) => i.listItemId == item.listItemId);
    emit(alreadyPresent
        ? _replaced(current, item)
        : ListItemsLoaded([...current.items, item], pendingIds: current.pendingIds));
  }

  /// Updates the on-screen quantity immediately, then writes it to the
  /// server. Taps that land while a write is already in flight for this
  /// item are coalesced: only the latest target is sent, and at most one
  /// more request follows the in-flight one — never one request per tap.
  Future<void> changeQuantity(ListItem item, double quantity) async {
    final current = state;
    if (current is! ListItemsLoaded) return;
    _lastConfirmedQty.putIfAbsent(item.listItemId, () => item.quantity);
    _pendingQtyTargets[item.listItemId] = quantity;
    _replace(current, item.copyWith(quantity: quantity));
    if (_writingIds.contains(item.listItemId)) return;
    _writingIds.add(item.listItemId);
    await _drainQtyWrites(item);
  }

  Future<void> _drainQtyWrites(ListItem item) async {
    final id = item.listItemId;
    while (true) {
      final target = _pendingQtyTargets[id];
      if (target == null) break;
      final result = await _updateItemUseCase(
        UpdateItemParams(listId: item.listId, item: item.copyWith(quantity: target)),
      );
      if (isClosed) return;
      final stillTarget = _pendingQtyTargets[id] == target;
      var shouldStop = stillTarget;
      result.fold(
        (failure) {
          final afterCall = state;
          if (afterCall is ListItemsLoaded) {
            final reverted = item.copyWith(quantity: _lastConfirmedQty[id] ?? item.quantity);
            emit(_replaced(afterCall, reverted).copyWith(error: failure.message));
          }
          shouldStop = true;
        },
        (updated) => _lastConfirmedQty[id] = updated.quantity,
      );
      if (shouldStop) {
        _pendingQtyTargets.remove(id);
        break;
      }
    }
    _writingIds.remove(id);
    _lastConfirmedQty.remove(id);
  }

  ListItemsLoaded _replaced(ListItemsLoaded current, ListItem updated) {
    return ListItemsLoaded([
      for (final i in current.items)
        i.listItemId == updated.listItemId ? updated : i,
    ], pendingIds: current.pendingIds);
  }

  void _replace(ListItemsLoaded current, ListItem updated) {
    emit(_replaced(current, updated));
  }
}
