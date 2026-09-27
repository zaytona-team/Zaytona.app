/// A list's currently active (in-progress) trip.
class ActiveTrip {
  const ActiveTrip({
    required this.tripId,
    required this.buyerId,
    this.listId,
    this.status,
    this.completedAt,
  });

  final String tripId;
  final String buyerId;

  /// Present on socket-delivered trip payloads (trip.assigned/.completed/
  /// .cancelled carry the full Trip.to_dict()); null on the plain
  /// GET /trips/active shape, which doesn't need it since the caller
  /// already knows which list they asked about.
  final String? listId;
  final String? status;
  final DateTime? completedAt;

  factory ActiveTrip.fromJson(Map<String, dynamic> json) {
    return ActiveTrip(
      tripId: json['trip_id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? '',
      listId: json['list_id'] as String?,
      status: json['status'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }
}
