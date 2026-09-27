import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import 'about_team_grid.dart';

/// "About" bottom sheet — brand mark, version, name-origin story, and the
/// team grid. Opened from a row in [SettingsPage].
class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team = [
      AboutTeamMember(
        name: l10n.aboutTeamMember1Name,
        assetPath: 'assets/images/team/Reem.png',
      ),
      AboutTeamMember(
        name: l10n.aboutTeamMember2Name,
        assetPath: 'assets/images/team/Abdullah.png',
      ),
      AboutTeamMember(
        name: l10n.aboutTeamMember3Name,
        assetPath: 'assets/images/team/Randa.png',
      ),
      AboutTeamMember(
        name: l10n.aboutTeamMember4Name,
        assetPath: 'assets/images/team/Mousa.png',
      ),
      AboutTeamMember(
        name: l10n.aboutTeamMember5Name,
        assetPath: 'assets/images/team/Alhanouf.png',
      ),
      AboutTeamMember(
        name: l10n.aboutTeamMember6Name,
        assetPath: 'assets/images/team/Aljawharah.png',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(ZaytonaSpacing.gutter, ZaytonaSpacing.space1, ZaytonaSpacing.gutter, ZaytonaSpacing.space8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ZaytonaSheetHeader(
              title: l10n.aboutTitle,
              onClose: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: ZaytonaSpacing.space5),
            Center(
              child: Image.asset(
                'assets/images/zaytona.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space5),
            Text(
              l10n.builtWithLoveInRiyadh,
              textAlign: TextAlign.center,
              style: ZaytonaType.screenTitle.copyWith(
                color: ZaytonaColors.navy,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space2),
            Text(
              l10n.appVersion,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: ZaytonaType.fieldLabel.copyWith(
                color: ZaytonaColors.textMuted,
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space5),
            DecoratedBox(
              decoration: BoxDecoration(
                color: ZaytonaColors.surfaceSunken,
                borderRadius: ZaytonaRadius.brLg,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZaytonaSpacing.space4,
                  vertical: ZaytonaSpacing.space5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/zaytona_doll_cut.png',
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: ZaytonaSpacing.space3),
                    Text(
                      l10n.aboutNameStoryTitle,
                      style: ZaytonaType.screenTitle.copyWith(
                        color: ZaytonaColors.navy,
                        fontSize: 16.5,
                      ),
                    ),
                    const SizedBox(height: ZaytonaSpacing.space3),
                    Text(
                      l10n.aboutNameStoryQuote,
                      textAlign: TextAlign.center,
                      style: ZaytonaType.fieldLabel.copyWith(
                        color: ZaytonaColors.redPress,
                        fontWeight: ZaytonaType.fwBold,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: ZaytonaSpacing.space3),
                    Text(
                      l10n.aboutNameStoryBody,
                      textAlign: TextAlign.center,
                      style: ZaytonaType.fieldLabel.copyWith(
                        color: ZaytonaColors.textBody,
                        fontWeight: ZaytonaType.fwRegular,
                        fontSize: 13.5,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space6),
            Text(
              l10n.aboutTeamHeading,
              textAlign: TextAlign.center,
              style: ZaytonaType.fieldLabel.copyWith(
                color: ZaytonaColors.textHint,
                fontWeight: ZaytonaType.fwBold,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space4),
            AboutTeamGrid(members: team),
          ],
        ),
      ),
    );
  }
}
