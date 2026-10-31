import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/student_code.dart';
import '../../core/widgets/ledge.dart';
import '../../core/widgets/mascot.dart';
import '../../core/widgets/rizma_button.dart';
import '../../core/widgets/screen_top_bar.dart';
import '../profiles/active_profile_provider.dart';
import 'sync_providers.dart';
import 'sync_service.dart';

class RestoreScreen extends ConsumerStatefulWidget {
  const RestoreScreen({super.key});

  @override
  ConsumerState<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends ConsumerState<RestoreScreen> {
  final _code = TextEditingController();
  final _name = TextEditingController();

  bool _busy = false;
  String? _message;

  String? _profileId;

  bool _pendingDeletion = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.launch);

  static int _minutesUntil(DateTime? t) => t == null
      ? 15
      : (t.difference(DateTime.now()).inSeconds / 60).ceil().clamp(1, 600);

  Future<void> _check({bool cancelDeletion = false}) async {
    final service = ref.read(syncServiceProvider);
    if (service == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    RestoreResult? result;
    try {
      result = await service.restore(
        _code.text,
        cancelDeletion: cancelDeletion,
      );
    } catch (_) {
      result = null;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pendingDeletion = result?.status == RestoreStatus.pendingDeletion;
      switch (result?.status) {
        case RestoreStatus.restored:
          _profileId = result!.profileId;
        case RestoreStatus.wrongCode:
          _message = ArStrings.restoreWrongCode;
        case RestoreStatus.codeLocked:
          _message = ArStrings.restoreCodeLocked(
            _minutesUntil(result!.retryAt),
          );
        case RestoreStatus.deviceLocked:
          _message = ArStrings.restoreDeviceLocked(
            _minutesUntil(result!.retryAt),
          );
        case RestoreStatus.pendingDeletion:
          _message = ArStrings.restorePendingDeletion;
        case RestoreStatus.offline:
          _message = ArStrings.restoreOffline;
        case null:
          _message = ArStrings.restoreFailed;
      }
    });
  }

  Future<void> _finish() async {
    final service = ref.read(syncServiceProvider);
    final id = _profileId;
    if (service == null || id == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await service.completeRestore(profileId: id, name: _name.text);
      await ref.read(activeProfileIdProvider.notifier).select(id);
      if (mounted) context.go(AppRoutes.home);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _message = ArStrings.restoreFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(syncServiceProvider) != null;
    final found = _profileId != null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenTopBar(
                title: ArStrings.restoreTitle,
                showOffline: false,
                onBack: _back,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    Center(
                      child: Mascot(
                        size: 110,
                        mood: _message == null || found
                            ? MascotMood.happy
                            : MascotMood.thinking,
                      ),
                    ),
                    Text(
                      found
                          ? ArStrings.restoreFoundTitle
                          : ArStrings.restoreHeading,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title26,
                    ),
                    if (!available)
                      _Note(text: ArStrings.restoreUnavailable)
                    else if (!found) ...[
                      Text(
                        ArStrings.restoreIntro,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body15.copyWith(
                          color: AppColors.soft,
                        ),
                      ),
                      _Field(
                        label: ArStrings.restoreCodeLabel,
                        controller: _code,
                        hint: ArStrings.forgotCodeHint,
                        ltr: true,
                        onChanged: () => setState(() => _message = null),
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp('[A-Za-z0-9 -]'),
                          ),
                          LengthLimitingTextInputFormatter(
                            StudentCode.length + 2,
                          ),
                          TextInputFormatter.withFunction(
                            (_, v) => v.copyWith(text: v.text.toUpperCase()),
                          ),
                        ],
                      ),
                      if (_message != null) _Note(text: _message!, warn: true),
                      if (_pendingDeletion)
                        RizmaButton(
                          label: ArStrings.restoreCancelDeletion,
                          kind: ButtonKind.amber,
                          onPressed: _busy
                              ? null
                              : () => _check(cancelDeletion: true),
                        )
                      else
                        RizmaButton(
                          label: ArStrings.restoreCheck,
                          icon: 'retry',
                          onPressed: _busy || _code.text.trim().isEmpty
                              ? null
                              : _check,
                        ),
                    ] else ...[
                      _Field(
                        label: ArStrings.restoreNameLabel,
                        controller: _name,
                        hint: ArStrings.nameHint,
                        onChanged: () => setState(() {}),
                        formatters: [LengthLimitingTextInputFormatter(40)],
                      ),
                      _Note(text: ArStrings.restoreNameNote),
                      if (_message != null) _Note(text: _message!, warn: true),
                      RizmaButton(
                        label: ArStrings.restoreFinish,
                        icon: 'fwd',
                        onPressed: _busy || _name.text.trim().isEmpty
                            ? null
                            : _finish,
                      ),
                    ],
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.formatters = const [],
    this.ltr = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  final List<TextInputFormatter> formatters;
  final bool ltr;

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
          label,
          style: AppTextStyles.label14.copyWith(color: AppColors.ink),
        ),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            textDirection: ltr ? TextDirection.ltr : null,
            style: AppTextStyles.input17,
            cursorColor: AppColors.teal,
            inputFormatters: formatters,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.input17.copyWith(
                color: AppColors.disabled,
              ),
              filled: true,
              fillColor: AppColors.card,
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

class _Note extends StatelessWidget {
  const _Note({required this.text, this.warn = false});

  final String text;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return LedgeBox(
      color: warn ? AppColors.redTint : AppColors.sky,
      radius: 16,
      depth: 0,
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        style: AppTextStyles.label14.copyWith(
          color: warn ? AppColors.red : AppColors.soft,
        ),
      ),
    );
  }
}
