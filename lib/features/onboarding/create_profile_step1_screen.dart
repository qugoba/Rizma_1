import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../../core/widgets/tag_chip.dart';
import 'create_profile_draft.dart';
import 'widgets/step_progress_card.dart';

class CreateProfileStep1Screen extends ConsumerStatefulWidget {
  const CreateProfileStep1Screen({super.key});

  @override
  ConsumerState<CreateProfileStep1Screen> createState() =>
      _CreateProfileStep1ScreenState();
}

class _CreateProfileStep1ScreenState
    extends ConsumerState<CreateProfileStep1Screen> {
  final _nameController = TextEditingController();
  int? _selectedGrade;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(createProfileDraftProvider);
    if (draft != null) {
      _nameController.text = draft.name;
      _selectedGrade = draft.grade;
    }
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _selectedGrade != null && _nameController.text.trim().isNotEmpty;

  void _continue() {
    ref
        .read(createProfileDraftProvider.notifier)
        .save(name: _nameController.text.trim(), grade: _selectedGrade!);
    context.push(AppRoutes.createStep2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenTopBar(
                title: ArStrings.createProfileTitle,
                showOffline: false,
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.welcome),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    const StepProgressCard(
                      label: ArStrings.step1Progress,
                      value: 0.5,
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ArStrings.step1Heading,
                                style: AppTextStyles.title26,
                              ),
                              Text(
                                ArStrings.step1Sub,
                                style: AppTextStyles.caption13,
                              ),
                            ],
                          ),
                        ),
                        Mascot(size: 64),
                      ],
                    ),
                    _NameField(controller: _nameController),
                    _GradeGrid(
                      selected: _selectedGrade,
                      onSelected: (grade) =>
                          setState(() => _selectedGrade = grade),
                    ),
                    const _PacksInfo(),
                    RizmaButton(
                      label: ArStrings.step1Next,
                      icon: 'fwd',
                      onPressed: _canContinue ? _continue : null,
                    ),
                    Text(
                      ArStrings.gradeChangeLater,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption12,
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

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: AppColors.line, width: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text(
          ArStrings.nameLabel,
          style: AppTextStyles.label14.copyWith(color: AppColors.ink),
        ),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            style: AppTextStyles.input17,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            cursorColor: AppColors.teal,
            decoration: InputDecoration(
              hintText: ArStrings.nameHint,
              hintStyle: AppTextStyles.input17.copyWith(
                color: AppColors.disabled,
              ),
              filled: true,
              fillColor: AppColors.card,
              suffixIcon: const Padding(
                padding: EdgeInsets.all(16),
                child: AppIcon('type', size: 20, color: AppColors.teal),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: const BorderSide(color: AppColors.teal, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradeGrid extends StatelessWidget {
  const _GradeGrid({required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final secondary = selected != null && selected! >= 11;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                ArStrings.gradeTitle,
                style: AppTextStyles.label14.copyWith(color: AppColors.ink),
              ),
            ),
            TagChip(
              label: secondary
                  ? ArStrings.stageSecondary
                  : ArStrings.stageBasic,
              icon: 'bulb',
              background: AppColors.blueTint,
              foreground: AppColors.blue,
            ),
          ],
        ),
        for (var row = 0; row < 3; row++)
          Row(
            spacing: 10,
            children: [
              for (var col = 1; col <= 4; col++)
                Expanded(
                  child: _GradeTile(
                    grade: row * 4 + col,
                    selected: row * 4 + col == selected,
                    onTap: () {
                      Haptics.tap();
                      onSelected(row * 4 + col);
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _GradeTile extends StatelessWidget {
  const _GradeTile({
    required this.grade,
    required this.selected,
    required this.onTap,
  });

  final int grade;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.teal : AppColors.card;

    return Semantics(
      button: true,
      selected: selected,
      label: ArStrings.gradeSemantics(grade),
      excludeSemantics: true,
      child: LedgeBox(
        color: bg,
        radius: 18,
        clip: true,
        child: Material(
          color: bg,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ArStrings.gradeTileLabel,
                    style: AppTextStyles.caption12.copyWith(
                      color: selected ? AppColors.onTeal : AppColors.muteText,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    '$grade',
                    style: AppTextStyles.gradeNumber24.copyWith(
                      color: selected ? AppColors.card : AppColors.ink,
                      height: 1.15,
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

class _PacksInfo extends StatelessWidget {
  const _PacksInfo();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sky,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ArStrings.step1InfoTitle, style: AppTextStyles.h3_17),
                  Text(
                    ArStrings.step1InfoBody,
                    style: AppTextStyles.caption13,
                  ),
                ],
              ),
            ),
            IconTile(
              iconName: 'cloudoff',
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
