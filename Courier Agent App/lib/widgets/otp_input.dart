import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/text_styles.dart';

class OtpInputRow extends StatefulWidget {
  const OtpInputRow({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // paste support
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final focusIndex = digits.length.clamp(0, widget.length - 1);
      _nodes[focusIndex].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    widget.onChanged?.call(_code);
    if (_code.length == widget.length) widget.onCompleted(_code);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (i) {
        return SizedBox(
          width: widget.length == 4 ? 64 : 48,
          height: widget.length == 4 ? 72 : 56,
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTextStyles.h2,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (v) => _onChanged(i, v),
          ),
        );
      }),
    );
  }
}

class ResendTimer extends StatefulWidget {
  const ResendTimer({super.key, required this.onResend, this.seconds = 30});

  final VoidCallback onResend;
  final int seconds;

  @override
  State<ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<ResendTimer> {
  late int _remaining;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _remaining = widget.seconds;
    _canResend = false;
    _tick();
  }

  void _tick() async {
    while (_remaining > 0 && mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _remaining--);
    }
    if (mounted) setState(() => _canResend = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_canResend) {
      return TextButton(
        onPressed: () {
          widget.onResend();
          _start();
        },
        child: Text(
          'Resend code',
          style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
      );
    }
    return Text(
      'Resend in 0:${_remaining.toString().padLeft(2, '0')}',
      style: AppTextStyles.caption,
    );
  }
}
