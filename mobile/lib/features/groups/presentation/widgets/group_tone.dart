import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../domain/entities/group.dart';

/// Presentation-only tone for a group's star glyph (no backend field):
/// private space is always lilac (prototype), shared groups get a stable
/// tone from their id so a group keeps its color everywhere.
extension GroupTone on Group {
  ZaytonaStarTone get tone {
    if (isPrivate) return ZaytonaStarTone.lilac;
    const shared = [
      ZaytonaStarTone.red,
      ZaytonaStarTone.indigo,
      ZaytonaStarTone.mint,
    ];
    return shared[groupId.hashCode.abs() % shared.length];
  }
}
