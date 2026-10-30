import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/strings/ar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/pin_hasher.dart';
import '../../../core/utils/student_code.dart';
import '../../../core/widgets/pin_pad.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profiles/profile_providers.dart';
import '../../profiles/profile_repository.dart';
import '../../sync/sync_api.dart';
import '../../sync/sync_providers.dart';
import '../../sync/sync_service.dart';

enum DeleteOutcome {
  cancelled,

  deletedLocally,

  removedFromPhone,

  deletedEverywhere,
}

Future<DeleteOutcome> showDeleteProfileSheet(
  BuildContext context,
  Profile profile,
) async {
  final outcome = await showModalBottomSheet<DeleteOutcome>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _DeleteProfileSheet(profile: profile),
  );
  return outcome ?? DeleteOutcome.cancelled;
}

enum _Stage { pin, confirmLocal, choose, removing, everywhere }

class _DeleteProfileSheet extends ConsumerStatefulWidget {
  const _DeleteProfileSheet({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_DeleteProfileSheet> createState() =>
      _DeleteProfileSheetState();
}

class _DeleteProfileSheetState extends ConsumerState<_DeleteProfileSheet> {
  late _Stage _stage = widget.profile.pinHash != null
      ? _Stage.pin
      : _afterPin();
  String _entry = '';
  bool _wrong = false;
  bool _busy = false;
  int _lockedSeconds = 0;
  Timer? _ticker;

  int? _unsynced;

  final _code = TextEditingController();
  String? _codeMessage;

  SyncService? get _service => ref.read(syncServiceProvider);

  _Stage _afterPin() => ref.read(syncServiceProvider) == null
      ? _Stage.confirmLocal
      : _Stage.choose;

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _close(DeleteOutcome outcome) => Navigator.of(context).pop(outcome);

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
          _stage = _afterPin();
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

  Future<void> _startRemoving() async {
    setState(() {
      _stage = _Stage.removing;
      _unsynced = null;
    });
    final service = _service!;
    await service.syncProfile(widget.profile.id);
    final left = await service.unsyncedResults(widget.profile.id);
    if (mounted) setState(() => _unsynced = left);
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    Haptics.heavy();
    try {
      await _service!.unlink(widget.profile.id);
    } catch (_) {
    }
    if (mounted) _close(DeleteOutcome.removedFromPhone);
  }

  Future<void> _deleteEverywhere() async {
    setState(() {
      _busy = true;
      _codeMessage = null;
    });
    String? message;
    try {
      final ok = await _service!.requestDeletion(widget.profile.id, _code.text);
      if (ok) {
        Haptics.heavy();
        if (mounted) _close(DeleteOutcome.deletedEverywhere);
        return;
      }
      message = ArStrings.forgotCodeWrong;
    } on SyncApiException catch (e) {
      message = e.error == SyncError.network
          ? ArStrings.deleteEverywhereOffline
          : ArStrings.deleteEverywhereFailed;
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _codeMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          24,
          24,
          24,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (_stage) {
            _Stage.pin => _pinStage(),
            _Stage.confirmLocal => _confirmLocalStage(),
            _Stage.choose => _chooseStage(),
            _Stage.removing => _removingStage(),
            _Stage.everywhere => _everywhereStage(),
          },
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

  Widget _confirmLocalStage() {
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
            _close(DeleteOutcome.deletedLocally);
          },
        ),
        TextButton(
          onPressed: () => _close(DeleteOutcome.cancelled),
          child: const Text(ArStrings.deleteCancel),
        ),
      ],
    );
  }

  Widget _chooseStage() {
    return Column(
      key: const ValueKey('choose'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          ArStrings.deleteChooseTitle(widget.profile.name),
          style: AppTextStyles.section18,
        ),
        _Option(
          title: ArStrings.deleteRemoveOption,
          note: ArStrings.deleteRemoveOptionNote,
          color: AppColors.teal,
          tint: AppColors.tealTint,
          onTap: _startRemoving,
        ),
        _Option(
          title: ArStrings.deleteEverywhereOption,
          note: ArStrings.deleteEverywhereOptionNote,
          color: AppColors.coral,
          tint: AppColors.coralTint,
          onTap: () => setState(() => _stage = _Stage.everywhere),
        ),
        TextButton(
          onPressed: () => _close(DeleteOutcome.cancelled),
          child: const Text(ArStrings.deleteCancel),
        ),
      ],
    );
  }

  Widget _removingStage() {
    final left = _unsynced;
    return Column(
      key: const ValueKey('removing'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(ArStrings.deleteRemoveOption, style: AppTextStyles.section18),
        if (left == null) ...[
          const Center(child: CircularProgressIndicator(color: AppColors.teal)),
          Text(
            ArStrings.deleteSyncing,
            textAlign: TextAlign.center,
            style: AppTextStyles.label14,
          ),
        ] else if (left == 0) ...[
          _Box(
            text: ArStrings.deleteSafe(widget.profile.studentCode),
            color: AppColors.tealDark,
            tint: AppColors.tealTint,
          ),
          PrimaryButton(
            label: ArStrings.deleteRemoveConfirm,
            backgroundColor: AppColors.coral,
            onPressed: _busy ? null : _remove,
          ),
          TextButton(
            onPressed: () => _close(DeleteOutcome.cancelled),
            child: const Text(ArStrings.deleteCancel),
          ),
        ] else ...[
          _Box(
            text: ArStrings.deleteUnsyncedWarning(left),
            color: AppColors.red,
            tint: AppColors.redTint,
          ),
          PrimaryButton(
            label: ArStrings.deleteCancel,
            onPressed: () => _close(DeleteOutcome.cancelled),
          ),
          TextButton(
            onPressed: _busy ? null : _remove,
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text(ArStrings.deleteRemoveAnyway),
          ),
        ],
      ],
    );
  }

  Widget _everywhereStage() {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.line, width: 2),
    );
    return Column(
      key: const ValueKey('everywhere'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(ArStrings.deleteEverywhereOption, style: AppTextStyles.section18),
        Text(ArStrings.deleteEverywhereBody, style: AppTextStyles.body15),
        SizedBox(
          height: 52,
          child: TextField(
            controller: _code,
            textDirection: TextDirection.ltr,
            style: AppTextStyles.input17,
            cursorColor: AppColors.teal,
            onChanged: (_) => setState(() => _codeMessage = null),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 -]')),
              LengthLimitingTextInputFormatter(StudentCode.length + 2),
              TextInputFormatter.withFunction(
                (_, v) => v.copyWith(text: v.text.toUpperCase()),
              ),
            ],
            decoration: InputDecoration(
              hintText: ArStrings.forgotCodeHint,
              hintStyle: AppTextStyles.input17.copyWith(
                color: AppColors.disabled,
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: const BorderSide(color: AppColors.coral, width: 2),
              ),
            ),
          ),
        ),
        if (_codeMessage != null) _message(_codeMessage!),
        PrimaryButton(
          label: ArStrings.deleteEverywhereConfirm,
          backgroundColor: AppColors.coral,
          onPressed: _busy || _code.text.trim().isEmpty
              ? null
              : _deleteEverywhere,
        ),
        TextButton(
          onPressed: () => _close(DeleteOutcome.cancelled),
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

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.note,
    required this.color,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String note;
  final Color color;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body16Strong.copyWith(color: color),
                ),
                Text(note, style: AppTextStyles.caption13),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.text, required this.color, required this.tint});

  final String text;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text, style: AppTextStyles.label14.copyWith(color: color)),
      ),
    );
  }
}
