import 'package:get_it/get_it.dart';
import '../l10n/locale_controller.dart';
import '../network/network_client.dart';
import '../network/token_storage.dart';
import '../../features/items/data/category_registry.dart';
import '../notifications/local_notification_service.dart';
import '../notifications/push_notification_service.dart';
import '../realtime/socket_service.dart';

import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/presentation/bloc/otp_cubit.dart';
import '../../features/auth/presentation/bloc/signup_cubit.dart';

import '../../features/histories/data/datasources/remote/history_remote_datasource.dart';
import '../../features/histories/data/repositories/history_repository_impl.dart';
import '../../features/histories/domain/repositories/history_repository.dart';
import '../../features/histories/domain/usecases/get_list_trips_usecase.dart';
import '../../features/histories/domain/usecases/get_list_history_usecase.dart';
import '../../features/histories/presentation/cubit/history_cubit.dart';

import '../../features/groups/data/datasources/remote/group_remote_datasource.dart';
import '../../features/groups/data/repositories/group_repository_impl.dart';
import '../../features/groups/domain/repositories/group_repository.dart';
import '../../features/groups/domain/usecases/create_group_usecase.dart';
import '../../features/groups/domain/usecases/delete_group_usecase.dart';
import '../../features/groups/domain/usecases/get_group_members_usecase.dart';
import '../../features/groups/domain/usecases/get_group_usecase.dart';
import '../../features/groups/domain/usecases/join_group_usecase.dart';
import '../../features/groups/domain/usecases/leave_group_usecase.dart';
import '../../features/groups/domain/usecases/list_groups_usecase.dart';
import '../../features/groups/domain/usecases/remove_member_usecase.dart';
import '../../features/groups/domain/usecases/transfer_admin_usecase.dart';
import '../../features/groups/domain/usecases/update_group_usecase.dart';
import '../../features/groups/presentation/cubit/groups/create_group_cubit.dart';
import '../../features/groups/presentation/cubit/groups/get_group_cubit.dart';
import '../../features/groups/presentation/cubit/groups/group_settings_cubit.dart';
import '../../features/groups/presentation/cubit/groups/join_group_cubit.dart';
import '../../features/groups/presentation/cubit/groups/list_groups_cubit.dart';

import '../../features/lists/data/datasources/remote/list_remote_datasource.dart';
import '../../features/lists/data/repositories/list_repository_impl.dart';
import '../../features/lists/domain/repositories/list_repository.dart';
import '../../features/lists/domain/usecases/create_list_usecase.dart';
import '../../features/lists/domain/usecases/delete_list_usecase.dart';
import '../../features/lists/domain/usecases/rename_list_usecase.dart';
import '../../features/lists/domain/usecases/get_group_lists_usecase.dart';
import '../../features/lists/domain/usecases/get_list_usecase.dart';
import '../../features/lists/presentation/cubit/lists/create_list_cubit.dart';
import '../../features/lists/presentation/cubit/lists/group_lists_cubit.dart';

import '../../features/items/data/datasources/remote/item_remote_datasource.dart';
import '../../features/items/data/datasources/remote/personal_catalog_remote_datasource.dart';
import '../../features/items/data/repositories/item_repository_impl.dart';
import '../../features/items/data/repositories/personal_catalog_repository_impl.dart';
import '../../features/items/domain/repositories/item_repository.dart';
import '../../features/items/domain/repositories/personal_catalog_repository.dart';
import '../../features/items/domain/usecases/add_item_usecase.dart';
import '../../features/items/domain/usecases/delete_all_items_usecase.dart';
import '../../features/items/domain/usecases/delete_item_usecase.dart';
import '../../features/items/domain/usecases/get_list_items_usecase.dart';
import '../../features/items/domain/usecases/set_purchased_usecase.dart';
import '../../features/items/domain/usecases/update_item_usecase.dart';
import '../../features/items/presentation/cubit/items/add_item_cubit.dart';
import '../../features/items/presentation/cubit/items/catalog_cubit.dart';
import '../../features/items/presentation/cubit/items/list_items_cubit.dart';
import '../../features/items/presentation/cubit/trip/active_trip_cubit.dart';
import '../../features/items/presentation/cubit/trip/complete_trip_cubit.dart';

import '../../features/notifications/data/datasources/remote/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/assign_buyer_usecase.dart';
import '../../features/notifications/domain/usecases/complete_trip_usecase.dart';
import '../../features/notifications/domain/usecases/get_active_trip_usecase.dart';
import '../../features/notifications/domain/usecases/heading_to_store_usecase.dart';
import '../../features/notifications/domain/usecases/remind_me_usecase.dart';
import '../../features/notifications/domain/usecases/remind_member_usecase.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';

/// Global service locator. Call [setupLocator] once, before `runApp`.
final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  // ── Core ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<TokenStorage>(TokenStorage.new);
  sl.registerLazySingleton<LocaleController>(LocaleController.new);
  sl.registerLazySingleton<NetworkClient>(() => NetworkClient.instance);
  sl.registerLazySingleton<CategoryRegistry>(() => CategoryRegistry.instance);

  // Real-time sync (Socket.IO) — one connection shared by every cubit
  // below that takes it as a dependency. See core/realtime/socket_service.dart.
  sl.registerLazySingleton<SocketService>(SocketService.new);

  // ── Repositories ──────────────────────────────────────────────────────
  // DEV ONLY branch: with DevConfig.useFakeBackend the in-memory fakes
  // (core/dev/fake_repositories.dart) replace the real API repositories.
  // Everything downstream (usecases, cubits, pages) is identical either way.
    sl.registerLazySingleton(() => GroupRemoteDataSource(sl()));
    sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl(sl()));
    sl.registerLazySingleton(() => ListRemoteDataSource(sl()));
    sl.registerLazySingleton<ListRepository>(() => ListRepositoryImpl(sl()));
    sl.registerLazySingleton(() => ItemRemoteDataSource(sl()));
    sl.registerLazySingleton<ItemRepository>(() => ItemRepositoryImpl(sl()));
    sl.registerLazySingleton(() => NotificationRemoteDataSource(sl()));
    sl.registerLazySingleton<NotificationRepository>(
        () => NotificationRepositoryImpl(sl()));
    sl.registerLazySingleton(() => HistoryRemoteDataSource(sl()));
    sl.registerLazySingleton<HistoryRepository>(
        () => HistoryRepositoryImpl(sl()));

  sl.registerLazySingleton(() => PersonalCatalogRemoteDataSource(sl()));
  sl.registerLazySingleton<PersonalCatalogRepository>(
    () => PersonalCatalogRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Auth feature ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl()));

  sl.registerFactory(() => LoginCubit(loginUseCase: sl()));
  sl.registerFactory(() => SignupCubit(registerUseCase: sl()));
  sl.registerFactory(() => OtpCubit(verifyOtpUseCase: sl(), resendOtpUseCase: sl()));

  // ── Groups feature ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ListGroupsUseCase(sl()));
  sl.registerLazySingleton(() => CreateGroupUseCase(sl()));
  sl.registerLazySingleton(() => JoinGroupUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupMembersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGroupUseCase(sl()));
  sl.registerLazySingleton(() => RemoveMemberUseCase(sl()));
  sl.registerLazySingleton(() => TransferAdminUseCase(sl()));
  sl.registerLazySingleton(() => LeaveGroupUseCase(sl()));
  sl.registerLazySingleton(() => DeleteGroupUseCase(sl()));

sl.registerLazySingleton(() => ListGroupsCubit(sl(), sl()));
  sl.registerFactory(() => CreateGroupCubit(sl(), sl()));
  sl.registerFactory(() => JoinGroupCubit(sl(), sl()));
  sl.registerFactory(() => GetGroupCubit(sl(), sl()));
  sl.registerFactory(
      () => GroupSettingsCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));

  // ── Lists feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => CreateListUseCase(sl()));
  sl.registerLazySingleton(() => GetGroupListsUseCase(sl()));
  sl.registerLazySingleton(() => GetListUseCase(sl()));
  sl.registerLazySingleton(() => DeleteListUseCase(sl()));
  sl.registerLazySingleton(() => RenameListUseCase(sl()));

  sl.registerFactory(() => CreateListCubit(sl()));
  sl.registerFactory(() => GroupListsCubit(sl(), sl(), sl()));

  // ── Items feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetListItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAllItemsUseCase(sl()));
  sl.registerLazySingleton(() => SetPurchasedUseCase(sl()));

  sl.registerFactory(() => ListItemsCubit(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => AddItemCubit(sl(), sl()));
  sl.registerFactory(() => CatalogCubit(sl(), sl(), sl()));
  sl.registerFactory(() => ActiveTripCubit(sl(), sl(), sl()));
  sl.registerFactory(() => CompleteTripCubit(sl()));

  // ── Notifications feature (Story 7) ──────────────────────────────────
  sl.registerLazySingleton(() => HeadingToStoreUseCase(sl()));
  sl.registerLazySingleton(() => AssignBuyerUseCase(sl()));
  sl.registerLazySingleton(() => RemindMemberUseCase(sl()));
  sl.registerLazySingleton(() => RemindMeUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveTripUseCase(sl()));
  sl.registerLazySingleton(() => CompleteTripUseCase(sl()));

  sl.registerFactory(() => NotificationsCubit(sl(), sl(), sl(), sl()));

  // General-purpose local-notification popper — anything in the app that
  // wants to show a notification (FCM foreground banners, a reminder, a
  // confirmation) goes through this single instance.
  sl.registerLazySingleton(LocalNotificationService.new);

  // FCM push delivery — separate from the send-side cubit above, this is
  // the receive side (permission, token, register/unregister, tap nav).
  sl.registerLazySingleton(() => PushNotificationService(sl(), sl()));

  // ── Histories feature (Story 8) ───────────────────────────────────────
  sl.registerLazySingleton(() => GetListHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetListTripsUseCase(sl()));
  sl.registerFactory(() => HistoryCubit(sl(), sl(), sl(), sl()));
}
