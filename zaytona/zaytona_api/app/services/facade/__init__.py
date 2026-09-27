"""ZaytonaFacade — the single orchestration layer (HBnB-style).

The API namespaces never touch providers or repositories directly; they
call the facade, which coordinates:
  * UserRepository     — the USER table (identity lives here, not Supabase Auth)
  * GroupRepository    — GROUP / GROUP_MEMBER (+ group-scoped list/recipe delete)
  * CategoryRepository — CATEGORY reference data
  * ListRepository     — SHOPPING_LIST
  * ItemRepository     — LIST_ITEM
  * RecipeRepository   — RECIPE / RECIPE_INGREDIENT
  * HistoryRepository  — LIST_ACTION (activity log)
  * TripRepository     — TRIP (locks a list to a buyer for a shopping run)
  * UserDeviceRepository — USER_DEVICE (registered FCM push tokens)
  * Authentica         — OTP send + verify (US-36). Authentica does not fail
                         over between channels itself, so send_otp's own
                         whatsapp -> sms -> email fallback lives in
                         AuthenticaProvider (see that module's docstring).
  * FirebaseProvider   — FCM push notifications (e.g. notifying a trip's
                         buyer when someone else adds an item mid-trip).
  * SupabaseStorageProvider — user-uploaded list-item photos (item-images
                         bucket); separate from the fixed preset-avatar
                         bucket used by /auth/avatars.
  * SocketIO (`self.socketio`) — real-time group/list/trip sync; the
                         emit/room helpers live in RealtimeFacadeMixin
                         (realtime.py), used by groups/lists/items/recipes/trips.

`ZaytonaFacade` itself only wires up repositories/providers and exposes
one method per use case; the methods live in per-domain mixins (SRP) so
no single file has to hold the whole surface area:

  guards.py     — membership/role authorization, shared by every other mixin
  realtime.py   — Socket.IO emit/room helpers, shared by groups/items/trips
  auth.py       — US-01/02/03/36 (register, login, OTP, profile)
  groups.py     — US-04..US-12 (group CRUD, membership, admin transfer)
  categories.py — reference-data reads
  lists.py      — US-13..US-15 (shopping list CRUD)
  items.py      — US-16..US-26 (list items: add/update/delete/purchase)
  recipes.py    — US-33..US-37 (recipes + import into a list)
  history.py    — LIST_ACTION activity feed
  trips.py      — trip start/complete/cancel (buyer lock + notify trigger)
  devices.py    — FCM push-token registration

Every namespace in app/api/v1 still just does
`from app.services.facade import get_facade, FacadeError` and calls
`facade.<use_case>(...)` — this package boundary is invisible to callers.
"""
from app.persistence.repositories.category_repository import CategoryRepository
from app.persistence.repositories.group_repository import GroupRepository
from app.persistence.repositories.history_repository import HistoryRepository
from app.persistence.repositories.item_repository import ItemRepository
from app.persistence.repositories.list_repository import ListRepository
from app.persistence.repositories.recipe_repository import RecipeRepository
from app.persistence.repositories.trip_repository import TripRepository
from app.persistence.repositories.user_device_repository import UserDeviceRepository
from app.persistence.repositories.user_repository import UserRepository
from app.services.facade.auth import AuthFacadeMixin
from app.services.facade.categories import CategoryFacadeMixin
from app.services.facade.devices import DeviceFacadeMixin
from app.services.facade.errors import FacadeError
from app.services.facade.groups import GroupFacadeMixin
from app.services.facade.guards import GuardsMixin
from app.services.facade.history import HistoryFacadeMixin
from app.services.facade.items import ItemFacadeMixin
from app.services.facade.lists import ListFacadeMixin
from app.services.facade.notifications import NotificationFacadeMixin
from app.services.facade.realtime import RealtimeFacadeMixin
from app.services.facade.recipes import RecipeFacadeMixin
from app.services.facade.trips import TripFacadeMixin
from app.utils.util import _is_uuid
from app.extensions import socketio
from app.services.providers.authentica_provider import AuthenticaProvider
from app.services.providers.firebase_provider import FirebaseProvider
from app.services.providers.supabase_storage_provider import SupabaseStorageProvider

__all__ = ["ZaytonaFacade", "FacadeError", "get_facade", "_is_uuid"]


class ZaytonaFacade(
    GuardsMixin,
    RealtimeFacadeMixin,
    AuthFacadeMixin,
    GroupFacadeMixin,
    CategoryFacadeMixin,
    ListFacadeMixin,
    ItemFacadeMixin,
    RecipeFacadeMixin,
    HistoryFacadeMixin,
    TripFacadeMixin,
    DeviceFacadeMixin,
    NotificationFacadeMixin,
):
    def __init__(self):
        self.users = UserRepository()
        self.groups = GroupRepository()
        self.categories = CategoryRepository()
        self.lists = ListRepository()
        self.authentica = AuthenticaProvider()
        self.items = ItemRepository()
        self.recipes = RecipeRepository()
        self.history = HistoryRepository()
        self.trips = TripRepository()
        self.user_devices = UserDeviceRepository()
        self.notifications = FirebaseProvider()
        self.storage = SupabaseStorageProvider()
        self.socketio = socketio


_facade = None


def get_facade() -> "ZaytonaFacade":
    global _facade
    if _facade is None:
        _facade = ZaytonaFacade()
    return _facade
