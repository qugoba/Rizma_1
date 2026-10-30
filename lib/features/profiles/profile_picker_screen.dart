import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/app_database.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/profile_palette.dart';
import '../../core/widgets/dashed_border.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/offline_chip.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/widgets/tag_chip.dart';
import 'active_profile_provider.dart';
import 'profile_providers.dart';

class ProfilePickerScreen extends ConsumerWidget {
  const ProfilePickerScreen({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, Profile p) async {
    if (p.pinHash != null) {
      context.push(AppRoutes.pin(p.id));
      return;
    }
    await ref.read(activeProfileIdProvider.notifier).select(p.id);
    if (context.mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value;
    final stars = ref.watch(starsByProfileProvider).value ?? const {};

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ArStrings.pickerTopTitle,
                      style: AppTextStyles.heading22,
                    ),
                  ),
                  const OfflineChip(),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(ArStrings.pickerTitle, style: AppTextStyles.title26),
                  Text(
                    ArStrings.pickerSubtitle,
                    style: AppTextStyles.body15.copyWith(
                      color: AppColors.soft,
                    ),
                  ),
                ],
              ),
              if (profiles != null)
                _ProfilesGrid(
                  profiles: profiles,
                  stars: stars,
                  onOpen: (p) => _open(context, ref, p),
                ),
              _NewProfileButton(
                onTap: () => context.push(AppRoutes.createStep1),
              ),
              const _SafeCard(),
              TextButton(
                onPressed: () => context.push(AppRoutes.restore),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  textStyle: AppTextStyles.label14,
                ),
                child: const Wrap(
                  spacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    Text(ArStrings.pickerRestoreTitle),
                    Text(ArStrings.pickerRestoreSubtitle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilesGrid extends StatelessWidget {
  const _ProfilesGrid({
    required this.profiles,
    required this.stars,
    required this.onOpen,
  });

  final List<Profile> profiles;
  final Map<String, int> stars;
  final ValueChanged<Profile> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        for (var i = 0; i < profiles.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                for (final k in [i, i + 1])
                  Expanded(
                    child: k < profiles.length
                        ? _ProfileCard(
                            profile: profiles[k],
                            stars: stars[profiles[k].id] ?? 0,
                            onTap: () => onOpen(profiles[k]),
                          ).fadeIn(k)
                        : const SizedBox(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.stars,
    required this.onTap,
  });

  final Profile profile;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = profile.pinHash != null;
    final grade = ArStrings.gradeName(profile.grade);

    return Semantics(
      button: true,
      label: ArStrings.profileSemantics(profile.name, grade, locked),
      excludeSemantics: true,
      child: LedgeBox(
        radius: 22,
        clip: true,
        child: Material(
          color: AppColors.card,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 14),
              child: Column(
                spacing: 4,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: locked
                        ? const TagChip(
                            label: ArStrings.pickerLocked,
                            icon: 'lock',
                            background: AppColors.sky,
                            foreground: AppColors.soft,
                          )
                        : const TagChip(
                            label: ArStrings.pickerReady,
                            icon: 'checkc',
                          ),
                  ),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: profile.color.avatarBackground,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Mascot(size: 72, color: profile.color),
                  ),
                  Text(
                    profile.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.section18,
                  ),
                  Text(
                    grade,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption13,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TagChip(
                      label: ArStrings.stars(stars),
                      icon: 'starf',
                      background: AppColors.amberTint,
                      foreground: AppColors.amberInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).pressable();
  }
}

class _NewProfileButton extends StatelessWidget {
  const _NewProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: ArStrings.pickerNewTitle,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DashedBorderBox(
          color: AppColors.sky2,
          radius: 20,
          dash: 8,
          gap: 6,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Text(
                ArStrings.pickerNewTitle,
                style: AppTextStyles.h3_17.copyWith(color: AppColors.teal),
              ),
              const IconTile(
                iconName: 'plus',
                iconColor: AppColors.teal,
                color: AppColors.tealTint,
                size: 36,
                iconSize: 20,
                radius: 18,
              ),
            ],
          ),
        ),
      ),
    ).pressable();
  }
}

class _SafeCard extends StatelessWidget {
  const _SafeCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ArStrings.pickerSafeTitle, style: AppTextStyles.h3_17),
                  Text(
                    ArStrings.pickerSafeBody,
                    style: AppTextStyles.caption13,
                  ),
                ],
              ),
            ),
            const IconTile(
              iconName: 'shield',
              iconColor: AppColors.teal,
              color: AppColors.tealTint,
              size: 44,
              iconSize: 22,
            ),
          ],
        ),
      ),
    );
  }
}

