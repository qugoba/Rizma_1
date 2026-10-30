import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/app_database.dart';
import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/student_code.dart';
import '../../core/widgets/primary_button.dart';
import 'pin_setup_sheet.dart';
import 'profile_repository.dart';

Future<bool> showForgotPinSheet(
  BuildContext context, {
  required ProfileRepository repository,
  required Profile profile,
}) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _ForgotPinSheet(repository: repository, profile: profile),
  );
  return changed ?? false;
}

class _ForgotPinSheet extends StatefulWidget {
  const _ForgotPinSheet({required this.repository, required this.profile});

  final ProfileRepository repository;
  final Profile profile;

  @override
  State<_ForgotPinSheet> createState() => _ForgotPinSheetState();
}

class _ForgotPinSheetState extends State<_ForgotPinSheet> {
  final _controller = TextEditingController();
  bool _verified = false;
  bool _wrongCode = false;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    final ok = await widget.repository.matchesStudentCode(
      widget.profile.id,
      _controller.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _verified = ok;
      _wrongCode = !ok;
    });
  }

  Future<void> _setNewPin() async {
    final pin = await showPinSetupSheet(context);
    if (pin == null || !mounted) return;
    await widget.repository.resetPinWithStudentCode(
      widget.profile.id,
      _controller.text,
      newPin: pin,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _removePin() async {
    await widget.repository.resetPinWithStudentCode(
      widget.profile.id,
      _controller.text,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            24,
            24,
            24,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Text(
                ArStrings.forgotTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.section18,
              ),
              if (!_verified) ..._codeEntry() else ..._choices(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _codeEntry() {
    const maxLength = StudentCode.length;
    final borderColor = _wrongCode ? AppColors.coral : AppColors.line;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: 2),
    );

    return [
      Text(ArStrings.forgotCodeLabel, style: AppTextStyles.body16Strong),
      SizedBox(
        height: 52,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textDirection: TextDirection.ltr,
          textCapitalization: TextCapitalization.characters,
          cursorColor: AppColors.teal,
          style: AppTextStyles.input17,
          onChanged: (_) => setState(() => _wrongCode = false),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
            LengthLimitingTextInputFormatter(maxLength),
            TextInputFormatter.withFunction(
              (old, value) => value.copyWith(text: value.text.toUpperCase()),
            ),
          ],
          decoration: InputDecoration(
            hintText: ArStrings.forgotCodeHint,
            hintStyle: AppTextStyles.input17.copyWith(
              color: AppColors.placeholder,
            ),
            filled: true,
            fillColor: AppColors.card,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: _wrongCode ? AppColors.coral : AppColors.teal,
                width: 2,
              ),
            ),
          ),
        ),
      ),
      if (_wrongCode)
        Text(
          ArStrings.forgotCodeWrong,
          style: AppTextStyles.label14.copyWith(color: AppColors.coral),
        ),
      PrimaryButton(
        label: ArStrings.forgotVerify,
        onPressed: _busy || _controller.text.trim().isEmpty ? null : _verify,
      ),
    ];
  }

  List<Widget> _choices() {
    return [
      Text(
        ArStrings.forgotChoose,
        textAlign: TextAlign.center,
        style: AppTextStyles.body15,
      ),
      PrimaryButton(label: ArStrings.forgotSetNew, onPressed: _setNewPin),
      PrimaryButton(
        label: ArStrings.forgotRemove,
        onPressed: _removePin,
        backgroundColor: AppColors.mute,
        foregroundColor: AppColors.ink,
      ),
    ];
  }
}
