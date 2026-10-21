import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/pin_hasher.dart';
import '../../../core/widgets/pin_pad.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profiles/profile_providers.dart';
import '../../profiles/profile_repository.dart';
import '../../../core/utils/haptics.dart';

Future<bool> showDeleteProfileSheet(
  BuildContext context,
  Profile profile,
) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _DeleteProfileSheet(profile: profile),
  );
  return confirmed ?? false;
}

class _DeleteProfileSheet extends ConsumerStatefulWidget {
  const _DeleteProfileSheet({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_DeleteProfileSheet> createState() =>
      _DeleteProfileSheetState();
}

class _DeleteProfileSheetState extends ConsumerState<_DeleteProfileSheet> {
  late bool _needsPin = widget.profile.pinHash != null;
  String _entry = '';
  bool _wrong = false;
  bool _busy = false;
  int _lockedSeconds = 0;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_busy || _lockedSeconds > 0 || _entry.length >= PinHasher.pinLength) {
      return;
    }
    setState(() {
      _wrong = false;
      _entry += digit;
    });
    if (_entry.length == PinHasher.pinLength) _verify();
  }

  void _onDelete() {
    if (_busy || _entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final result = await ref
        .read(profileRepositoryProvider)
        .verifyPin(widget.profile.id, _entry);
    if (!mounted) return;

    switch (result.check) {
      case PinCheck.ok:
        setState(() {
          _needsPin = false;
          _busy = false;
        });
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

  void _startCountdown(Duration duration) {
    _ticker?.cancel();
    _lockedSeconds = (duration.inMilliseconds / 1000).ceil();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _lockedSeconds = (_lockedSeconds - 1).clamp(0, 9999));
      if (_lockedSeconds == 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _needsPin ? _pinStage() : _confirmStage(),
        ),
      ),
    );
  }

  Widget _pinStage() {
    return Column(
      key: const ValueKey('pin'),
      mainAxisSize: MainAxisSize.min,
      spacing: 14,
      children: [
        Text(
          ArStrings.deletePinTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.section18,
        ),
        PinDots(
          length: PinHasher.pinLength,
          filled: _entry.length,
          error: _wrong,
        ),
        SizedBox(
          height: 24,
          child: _lockedSeconds > 0
              ? _message(ArStrings.pinLocked(_lockedSeconds))
              : _wrong
              ? _message(ArStrings.pinWrong)
              : null,
        ),
        PinPad(
          onDigit: _onDigit,
          onDelete: _onDelete,
          enabled: !_busy && _lockedSeconds == 0,
        ),
      ],
    );
  }

  Widget _message(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.label14.copyWith(color: AppColors.coral),
    );
  }

  Widget _confirmStage() {
    return Column(
      key: const ValueKey('confirm'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          ArStrings.deleteTitle(widget.profile.name),
          style: AppTextStyles.section18,
        ),
        Text(ArStrings.deleteWarning, style: AppTextStyles.body15),
        const _LossItem(ArStrings.deleteItem1),
        const _LossItem(ArStrings.deleteItem2),
        const _LossItem(ArStrings.deleteItem3),
        const SizedBox(height: 4),
        PrimaryButton(
          label: ArStrings.deleteConfirm,
          backgroundColor: AppColors.coral,
          onPressed: () {
            Haptics.heavy();
            Navigator.of(context).pop(true);
          },
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(ArStrings.deleteCancel),
        ),
      ],
    );
  }
}

class _LossItem extends StatelessWidget {
  const _LossItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        const Icon(Icons.close_rounded, size: 20, color: AppColors.coral),
        Expanded(child: Text(text, style: AppTextStyles.label14)),
      ],
    );
  }
}
