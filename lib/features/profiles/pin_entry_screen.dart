import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/pin_hasher.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/icon_tile.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/pin_pad.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../../core/widgets/tag_chip.dart';
import 'active_profile_provider.dart';
import 'forgot_pin_sheet.dart';
import 'profile_providers.dart';
import 'profile_repository.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key, required this.profileId});

  final String profileId;

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _entry = '';
  bool _wrong = false;
  bool _busy = false;
  int _lockedSeconds = 0;
  Timer? _ticker;

  bool get _isLocked => _lockedSeconds > 0;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_busy || _isLocked || _entry.length >= PinHasher.pinLength) return;
    setState(() {
      _wrong = false;
      _entry += digit;
    });
    if (_entry.length == PinHasher.pinLength) _verify();
  }

  void _onDelete() {
    if (_busy || _entry.isEmpty) return;
    setState(() {
      _wrong = false;
      _entry = _entry.substring(0, _entry.length - 1);
    });
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.verifyPin(widget.profileId, _entry);
    if (!mounted) return;

    switch (result.check) {
      case PinCheck.ok:
        await _enter();
      case PinCheck.wrong:
        setState(() {
          _wrong = true;
          _entry = '';
          _busy = false;
        });
      case PinCheck.locked:
        _startCountdown(result.lockedFor ?? const Duration(seconds: 30));
        setState(() {
          _wrong = false;
          _entry = '';
          _busy = false;
        });
    }
  }

  Future<void> _enter() async {
    await ref.read(activeProfileIdProvider.notifier).select(widget.profileId);
    if (mounted) context.go(AppRoutes.home);
  }

  void _startCountdown(Duration duration) {
    _ticker?.cancel();
    _lockedSeconds = (duration.inMilliseconds / 1000).ceil();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _lockedSeconds = (_lockedSeconds - 1).clamp(0, 9999));
      if (_lockedSeconds == 0) timer.cancel();
    });
  }

  Future<void> _forgot() async {
    final profile = ref.read(profileByIdProvider(widget.profileId)).value;
    if (profile == null) return;
    final changed = await showForgotPinSheet(
      context,
      repository: ref.read(profileRepositoryProvider),
      profile: profile,
    );
    if (changed && mounted) await _enter();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileByIdProvider(widget.profileId)).value;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ScreenTopBar(
                title: ArStrings.pinScreenTitle,
                showOffline: false,
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.profiles),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
                child: profile == null
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          Center(
                            child: Container(
                              width: 116,
                              height: 116,
                              decoration: const BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sky2,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Mascot(
                                size: 92,
                                color: profile.color,
                                mood: _wrong
                                    ? MascotMood.thinking
                                    : MascotMood.happy,
                              ),
                            ),
                          ),
                          Center(
                            child: TagChip(
                              label: ArStrings.pinProfileChip(
                                profile.name,
                                ArStrings.gradeName(profile.grade),
                              ),
                              icon: 'user',
                            ),
                          ),
                          Text(
                            ArStrings.pinEnterTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title26.copyWith(
                              color: _wrong ? AppColors.coral : AppColors.ink,
                            ),
                          ),
                          Text(
                            _wrong ? ArStrings.pinCalm : ArStrings.pinEnterSub,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body15.copyWith(
                              color: AppColors.soft,
                            ),
                          ),
                          Center(
                            child: PinDots(
                              length: PinHasher.pinLength,
                              filled: _entry.length,
                              error: _wrong,
                            ),
                          ),
                          _StatusCard(
                            wrong: _wrong,
                            lockedSeconds: _lockedSeconds,
                          ),
                          PinPad(
                            onDigit: _onDigit,
                            onDelete: _onDelete,
                            enabled: !_isLocked && !_busy,
                          ),
                          const Spacer(),
                          _ForgotCard(onTap: _forgot),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.wrong, required this.lockedSeconds});

  final bool wrong;
  final int lockedSeconds;

  @override
  Widget build(BuildContext context) {
    final text = lockedSeconds > 0
        ? ArStrings.pinLocked(lockedSeconds)
        : (wrong ? ArStrings.pinWrong : null);
    if (text == null) return const SizedBox(height: 8);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.redTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.label14.copyWith(color: AppColors.red),
              ),
            ),
            const IconTile(
              iconName: 'retry',
              iconColor: AppColors.red,
              color: AppColors.card,
              size: 36,
              iconSize: 18,
              radius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotCard extends StatelessWidget {
  const _ForgotCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.amberTint,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Text(
                    ArStrings.pinForgot,
                    style: AppTextStyles.label14.copyWith(
                      color: AppColors.amberInk,
                    ),
                  ),
                ),
                const AppIcon('bulb', size: 22, color: AppColors.amberInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
