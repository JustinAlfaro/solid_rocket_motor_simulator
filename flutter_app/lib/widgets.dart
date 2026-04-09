import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kNavy = Color(0xFF1A3A5C);
const Color kBlue = Color(0xFF378ADD);

// ── Sección con título ────────────────────────────────────────────────────────
class SrmSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SrmSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500,
              color: Color(0xFF888888), letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ── Slider + input numérico editable ─────────────────────────────────────────
class SliderField extends StatefulWidget {
  final String label;
  final double min, max, step, value;
  final int decimals;
  final ValueChanged<double> onChanged;

  const SliderField({
    super.key,
    required this.label,
    required this.min,
    required this.max,
    required this.step,
    required this.value,
    this.decimals = 1,
    required this.onChanged,
  });

  @override
  State<SliderField> createState() => _SliderFieldState();
}

class _SliderFieldState extends State<SliderField> {
  late TextEditingController _ctrl;
  late double _val;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
    _ctrl = TextEditingController(text: _fmt(_val));
  }

  @override
  void didUpdateWidget(SliderField old) {
    super.didUpdateWidget(old);
    if ((old.value - widget.value).abs() > 1e-10) {
      _val = widget.value;
      final newText = _fmt(_val);
      if (_ctrl.text != newText) {
        _ctrl.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(double v) => v.toStringAsFixed(widget.decimals);

  void _fromInput(String s) {
    final parsed = double.tryParse(s);
    if (parsed == null) return;
    final clamped = parsed.clamp(widget.min, widget.max);
    setState(() => _val = clamped);
    widget.onChanged(clamped);
  }

  void _onBlur() {
    final clamped = _val.clamp(widget.min, widget.max);
    setState(() {
      _val = clamped;
      _ctrl.text = _fmt(clamped);
    });
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: kNavy,
                    thumbColor: kNavy,
                    overlayColor: kNavy.withAlpha(30),
                    trackHeight: 2,
                  ),
                  child: Slider(
                    value: _val.clamp(widget.min, widget.max),
                    min: widget.min,
                    max: widget.max,
                    divisions: ((widget.max - widget.min) / widget.step).round().clamp(1, 1000),
                    onChanged: (v) {
                      setState(() {
                        _val = v;
                        _ctrl.text = _fmt(v);
                      });
                      widget.onChanged(v);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 68,
                child: Focus(
                  onFocusChange: (hasFocus) { if (!hasFocus) _onBlur(); },
                  child: TextField(
                    controller: _ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: kBlue),
                      ),
                    ),
                    onChanged: _fromInput,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Métrica ───────────────────────────────────────────────────────────────────
class MetricCard extends StatelessWidget {
  final String label, value, unit;
  const MetricCard({super.key, required this.label, required this.value, this.unit = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(unit, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Badge de estado ───────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  const StatusBadge({super.key, required this.text, this.type = BadgeType.info});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (type) {
      case BadgeType.ok:   bg = const Color(0xFFEAFAF1); fg = const Color(0xFF1E7A3B); break;
      case BadgeType.warn: bg = const Color(0xFFFEF9E7); fg = const Color(0xFFB7770D); break;
      case BadgeType.err:  bg = const Color(0xFFFDF2F2); fg = const Color(0xFFA32D2D); break;
      case BadgeType.info: bg = const Color(0xFFE8F0FB); fg = const Color(0xFF185FA5); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

enum BadgeType { ok, warn, err, info }
