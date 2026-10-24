import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/app_database.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../../core/widgets/tag_chip.dart';
import '../profiles/active_profile_provider.dart';
import 'account_providers.dart';

class StudentCodeScreen extends ConsumerWidget {
  const StudentCodeScreen({super.key});

  void _back(BuildContext context) {
    context.canPop() ? context.pop() : context.go(AppRoutes.account);
  }

  Future<void> _copy(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(ArStrings.codeCopied)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider).value;
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;

    return Scaffold(
      body: SafeArea(
        child: profile == null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenTopBar(
                      title: ArStrings.codeTitle,
                      onBack: () => _back(context),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        8,
                        20,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 14,
                        children: [
                          _StudentHeader(profile: profile).fadeIn(0),
                          _CodeCard(code: profile.studentCode).fadeIn(1),
                          const _KeepSafeCard().fadeIn(2),
                          RizmaButton(
                            label: ArStrings.codeCopy,
                            icon: 'copy',
                            onPressed: () =>
                                _copy(context, profile.studentCode),
                          ),
                          RizmaButton(
                            label: ArStrings.codeShare,
                            icon: 'share',
                            kind: ButtonKind.outlined,
                            onPressed: () => ref.read(shareTextProvider)(
                              ArStrings.codeShareMessage(profile.studentCode),
                            ),
                          ),
                          const _WhyCard().fadeIn(3),
                          _InfoRow(
                            icon: 'sync',
                            iconColor: AppColors.teal,
                            tint: AppColors.tealTint,
                            title: ArStrings.codeNeverSynced,
                            caption: pending == 0
                                ? ArStrings.codeNothingPending
                                : ArStrings.codePending(pending),
                          ),
                          if (profile.classCode != null)
                            _InfoRow(
                              icon: 'users',
                              iconColor: AppColors.amberDark,
                              tint: AppColors.amberTint,
                              title: ArStrings.codeClassGroup,
                              caption: ArStrings.codeClassLine(
                                profile.classCode!,
                              ),
                            ),
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

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                ArStrings.codeStudentCard(profile.name),
                style: AppTextStyles.heading22,
              ),
              TagChip(
                label: ArStrings.gradeName(profile.grade),
                icon: 'book',
              ),
            ],
          ),
        ),
        Mascot(size: 64, color: profile.color),
      ],
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 22,
      edge: AppColors.tealDark,
      border: Border.all(color: AppColors.teal, width: 2),
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.teal,
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
            child: Row(
              spacing: 8,
              children: [
                const AppIcon('key', size: 18, color: AppColors.card),
                Expanded(
                  child: Text(
                    ArStrings.codeBandTitle,
                    style: AppTextStyles.label14.copyWith(
                      color: AppColors.card,
                    ),
                  ),
                ),
                const TagChip(
                  label: ArStrings.codeAlwaysValid,
                  background: AppColors.mint,
                  foreground: AppColors.tealDark,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 8,
              children: [
                Text(ArStrings.codeYours, style: AppTextStyles.caption13),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.sky,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    code,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.display30.copyWith(
                      color: AppColors.teal,
                      fontSize: 34,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepSafeCard extends StatelessWidget {
  const _KeepSafeCard();

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      color: AppColors.amberTint,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ArStrings.codeKeepSafeTitle,
                  style: AppTextStyles.h3_17.copyWith(
                    color: AppColors.amberInk,
                  ),
                ),
                Text(
                  ArStrings.codeKeepSafe,
                  style: AppTextStyles.caption13.copyWith(
                    color: AppColors.amberInk,
                  ),
                ),
              ],
            ),
          ),
          const IconTile(
            iconName: 'warn',
            iconColor: AppColors.amberDark,
            color: AppColors.card,
            size: 40,
            iconSize: 20,
            radius: 12,
          ),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  const _WhyCard();

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 2,
        children: [
          Text(ArStrings.codeWhyTitle, style: AppTextStyles.h3_17),
          const _WhyRow(icon: 'phone', text: ArStrings.codeWhy1),
          const _WhyRow(icon: 'users', text: ArStrings.codeWhy2),
          const _WhyRow(icon: 'shield', text: ArStrings.codeWhy3),
        ],
      ),
    );
  }
}

class _WhyRow extends StatelessWidget {
  const _WhyRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 12,
        children: [
          IconTile(
            iconName: icon,
            iconColor: AppColors.teal,
            color: AppColors.tealTint,
            size: 34,
            iconSize: 18,
            radius: 10,
          ),
          Expanded(child: Text(text, style: AppTextStyles.body15)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.title,
    required this.caption,
  });

  final String icon;
  final Color iconColor;
  final Color tint;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          IconTile(
            iconName: icon,
            iconColor: iconColor,
            color: tint,
            size: 40,
            iconSize: 20,
            radius: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body15),
                Text(caption, style: AppTextStyles.caption13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
