import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings/ar.dart';
import '../../core/strings/ar_kids.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/illustration.dart';
import '../../core/widgets/mascot_items.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/widgets/rizma_button.dart';
import '../catalog/catalog_models.dart';
import '../content/speech_service.dart';
import '../learning/widgets/round_panels.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'home_state.dart';

class KidsHomeBody extends ConsumerWidget {
  const KidsHomeBody({
    super.key,
    required this.state,
    required this.subjects,
    required this.onGame,
    required this.onSubject,
  });

  final HomeState state;

  final List<CatalogSubject> subjects;
  final VoidCallback onGame;
  final ValueChanged<String> onSubject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = state.profile;
    final greeting = ArKids.greeting(profile.name);

    Future<void> speak() async {
      final ok = await ref
          .read(speechServiceProvider)
          .speak(greeting, language: 'ar');
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(ArKids.gameNoSpeech)));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.tealTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Text(
                    ArStrings.gradeName(profile.grade),
                    style: AppTextStyles.chip13.copyWith(color: AppColors.teal),
                  ),
                ),
              ),
              const Spacer(),
              StarsChip(count: state.stars),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: LedgeBox(
                  radius: 24,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        Text(
                          greeting,
                          style: AppTextStyles.heading22.copyWith(height: 1.6),
                        ),
                        RizmaButton(
                          label: ArKids.listen,
                          kind: ButtonKind.outlined,
                          icon: 'volume',
                          height: 46,
                          onPressed: speak,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MascotWithItems(
                size: 96,
                color: profile.color,
                items: ref.watch(activeEquippedProvider),
              ),
            ],
          ).fadeIn(0),
          Semantics(
            button: true,
            label: '${ArKids.todayGame}، ${ArKids.todayGameNote}',
            excludeSemantics: true,
            child: Material(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onGame,
                child: Ink(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.amberDark, width: 6),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    spacing: 14,
                    children: [
                      const Illustration('apple', size: 64),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ArKids.todayGame,
                              style: AppTextStyles.title26.copyWith(
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              ArKids.todayGameNote,
                              style: AppTextStyles.body15.copyWith(
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const AppIcon('play', size: 28, color: AppColors.ink),
                    ],
                  ),
                ),
              ),
            ).pressable(),
          ).fadeIn(1),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.05,
            children: [
              for (final s in subjects)
                _SubjectTile(subject: s, onTap: () => onSubject(s.id)),
            ],
          ).fadeIn(2),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject, required this.onTap});

  final CatalogSubject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = subject.color;
    return Semantics(
      button: true,
      label: subject.title,
      excludeSemantics: true,
      child: LedgeBox(
        color: tone.tint,
        edge: tone.fg,
        radius: 28,
        depth: 6,
        clip: true,
        child: Material(
          color: tone.tint,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(subject.icon, size: 34, color: tone.fg),
                  ),
                ),
                Text(
                  subject.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.section18.copyWith(color: AppColors.ink),
                ),
              ],
            ),
          ),
        ),
      ).pressable(),
    );
  }
}
