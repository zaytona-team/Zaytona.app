/// A person invited to a group, pending or confirmed.
class InvitedPerson {
  final String phoneNumber;
  final String? name;

  const InvitedPerson({required this.phoneNumber, this.name});
}
