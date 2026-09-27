import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

/// One team member shown in the About sheet's 3-column grid.
class AboutTeamMember {
  const AboutTeamMember({required this.name, this.assetPath});

  final String name;

  /// Path under `assets/images/team/`. Null falls back to initials.
  final String? assetPath;
}

/// 3-column grid of team member avatars + names for the About sheet.
class AboutTeamGrid extends StatelessWidget {
  const AboutTeamGrid({super.key, required this.members});

  final List<AboutTeamMember> members;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 18,
        crossAxisSpacing: 10,
        // Same bug class as catalog_card.dart's grid, same fix: this
        // cell's content (66px avatar + gap + up-to-2-line name) is fixed
        // pixels, not proportional to cell width, so a fixed aspect ratio
        // can't hold across device widths — a fixed mainAxisExtent gives
        // every cell the same row height regardless of width instead.
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) {
        final member = members[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: member.assetPath != null
                  ? Image.asset(
                      member.assetPath!,
                      width: 66,
                      height: 66,
                      fit: BoxFit.cover,
                    )
                  : ZaytonaAvatar(name: member.name, size: 66),
            ),
            const SizedBox(height: ZaytonaSpacing.space2),
            Text(
              member.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: ZaytonaType.fieldLabel.copyWith(
                color: ZaytonaColors.navy,
                fontWeight: ZaytonaType.fwBold,
                fontSize: 12.5,
              ),
            ),
          ],
        );
      },
    );
  }
}
