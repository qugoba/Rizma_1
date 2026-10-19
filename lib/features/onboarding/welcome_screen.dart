import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/tag_chip.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              const Center(
                child: TagChip(
                  label: ArStrings.welcomeOfflineReady,
                  icon: 'cloudoff',
                ),
              ),
              const _Hero().fadeIn(0),
              const _BundleCard().fadeIn(1),
              Row(
                spacing: 10,
                children: const [
                  Expanded(
                    child: _Value(
                      icon: 'users',
                      tint: AppColors.coralTint,
                      fg: AppColors.coral,
                      title: ArStrings.welcomeValue1Title,
                      note: ArStrings.welcomeValue1Subtitle,
                    ),
                  ),
                  Expanded(
                    child: _Value(
                      icon: 'target',
                      tint: AppColors.tealTint,
                      fg: AppColors.teal,
                      title: ArStrings.welcomeValue2Title,
                      note: ArStrings.welcomeValue2Subtitle,
                    ),
                  ),
                  Expanded(
                    child: _Value(
                      icon: 'cloudoff',
                      tint: AppColors.amberTint,
                      fg: AppColors.amberDark,
                      title: ArStrings.welcomeValue3Title,
                      note: ArStrings.welcomeValue3Subtitle,
                    ),
                  ),
                ],
              ).fadeIn(2),
              RizmaButton(
                label: ArStrings.welcomeStart,
                icon: 'fwd',
                onPressed: () => context.push(AppRoutes.createStep1),
              ),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(ArStrings.restoreNeedsInternet)),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  textStyle: AppTextStyles.label14,
                ),
                child: const Text(ArStrings.welcomeHaveProfile),
              ),
              Text(
                ArStrings.welcomeFooter,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      children: [
        const Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            TagChip(
              label: ArStrings.welcomeHello,
              icon: 'bolt',
              background: AppColors.amberTint,
              foreground: AppColors.amberInk,
            ),
            TagChip(
              label: ArStrings.welcomeCurriculum,
              icon: 'shield',
              foreground: AppColors.coral,
              outline: true,
            ),
          ],
        ),
        const Mascot(size: 170),
        Text(
          ArStrings.appName,
          style: AppTextStyles.display30.copyWith(
            color: AppColors.teal,
            fontSize: 40,
          ),
        ),
        Text(
          ArStrings.welcomeTagline,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyL16.copyWith(color: AppColors.soft),
        ),
      ],
    );
  }
}

class _BundleCard extends StatelessWidget {
  const _BundleCard();

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          const IconTile(
            iconName: 'book',
            iconColor: AppColors.teal,
            color: AppColors.tealTint,
            size: 48,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ArStrings.welcomeCardTitle, style: AppTextStyles.h3_17),
                Text(
                  ArStrings.welcomeCardBody,
                  style: AppTextStyles.caption13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.icon,
    required this.tint,
    required this.fg,
    required this.title,
    required this.note,
  });

  final String icon;
  final Color tint;
  final Color fg;
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
      child: Column(
        spacing: 6,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: AppIcon(icon, size: 20, color: fg),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.label14.copyWith(color: AppColors.ink),
          ),
          Text(
            note,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.caption12,
          ),
        ],
      ),
    );
  }
}
