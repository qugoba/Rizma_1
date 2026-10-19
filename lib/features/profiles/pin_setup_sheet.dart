import 'package:flutter/material.dart';

import '../../core/strings/ar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/pin_hasher.dart';
import '../../core/widgets/pin_pad.dart';

Future<String?> showPinSetupSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _PinSetupSheet(),
  );
}

class _PinSetupSheet extends StatefulWidget {
  const _PinSetupSheet();

  @override
  State<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<_PinSetupSheet> {
  String _first = '';
  String _entry = '';
  bool _confirming = false;
  bool _mismatch = false;

  void _onDigit(String digit) {
    if (_entry.length >= PinHasher.pinLength) return;
    setState(() {
      _mismatch = false;
      _entry += digit;
    });
    if (_entry.length == PinHasher.pinLength) _onComplete();
  }

  void _onDelete() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _onComplete() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    if (!_confirming) {
      setState(() {
        _first = _entry;
        _entry = '';
        _confirming = true;
      });
      return;
    }
    if (_entry == _first) {
      Navigator.of(context).pop(_entry);
      return;
    }
    setState(() {
      _mismatch = true;
      _entry = '';
      _first = '';
      _confirming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 14,
            children: [
              Text(
                _confirming
                    ? ArStrings.pinConfirmTitle
                    : ArStrings.pinSetupTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.section18,
              ),
              PinDots(
                length: PinHasher.pinLength,
                filled: _entry.length,
                error: _mismatch,
              ),
              SizedBox(
                height: 24,
                child: _mismatch
                    ? Text(
                        ArStrings.pinMismatch,
                        style: AppTextStyles.label14.copyWith(
                          color: AppColors.coral,
                        ),
                      )
                    : null,
              ),
              PinPad(onDigit: _onDigit, onDelete: _onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
