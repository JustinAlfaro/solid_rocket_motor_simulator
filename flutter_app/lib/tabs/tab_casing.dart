import 'package:flutter/material.dart';
import '../simulation_engine.dart';
import '../widgets.dart';

class TabCasing extends StatefulWidget {
  final SimParams params;
  final VoidCallback onChanged;
  const TabCasing({super.key, required this.params, required this.onChanged});

  @override
  State<TabCasing> createState() => _TabCasingState();
}

class _TabCasingState extends State<TabCasing> {
  String _selectedMat = 'pvc_sdr26';
  String _syMethod = 'direct';
  double _syDirect = 100;
  double _syHydroP = 2.0;
  double _suVal = 200;

  SimParams get p => widget.params;

  void _upd(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  void _selectMat(String id) {
    setState(() => _selectedMat = id);
    final m = kMats.firstWhere((x) => x.id == id);
    if (m.sy != null) {
      p.sy = m.sy!;
    }
    widget.onChanged();
  }

  void _applySy(double sy, {bool updateSlider = true}) {
    final clamped = sy.clamp(20.0, 700.0);
    setState(() { if (updateSlider) p.sy = clamped; });
    widget.onChanged();
  }

  double get _pburst => (p.od > 0 && p.tw > 0) ? 2 * p.sy * p.tw / p.od : 0;
  double get _meop => _pburst / p.fs;

  String _syResultText() {
    switch (_syMethod) {
      case 'direct':
        return 'Sy = ${_syDirect.toStringAsFixed(1)} MPa (ingresado manualmente)';
      case 'hydro':
        if (p.od > 0 && p.tw > 0) {
          final sy = _syHydroP * p.od / (2 * p.tw);
          return 'P_fluencia = $_syHydroP MPa → Sy ≈ ${sy.toStringAsFixed(1)} MPa';
        }
        return '';
      case 'su':
        return 'Estimado como 70% de Su = $_suVal MPa → Sy ≈ ${(_suVal * 0.70).toStringAsFixed(1)} MPa';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = _selectedMat == 'custom';
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SrmSection(
          title: 'Material del casing',
          children: [
            Text(
              'La presión de rotura se calcula con la fórmula de Barlow: '
              'P_burst = 2·Sy·t/OD',
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.5),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: kMats.map((m) => _MatCard(
                mat: m,
                selected: m.id == _selectedMat,
                onTap: () => _selectMat(m.id),
              )).toList(),
            ),
            if (isCustom) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF0),
                  border: Border.all(color: const Color(0xFFE8D080)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calcular tensión de fluencia (Sy) — material personalizado',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF7A5500))),
                    const SizedBox(height: 6),
                    const Text(
                      'Si no conoce el Sy de su material, puede estimarlo a partir de una '
                      'prueba hidrostática o desde el Su (resistencia última).',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7A5500), height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _syMethod,
                      decoration: const InputDecoration(
                        labelText: 'Método',
                        labelStyle: TextStyle(fontSize: 12),
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      items: const [
                        DropdownMenuItem(value: 'direct', child: Text('Ingresar Sy directamente (datasheet)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'hydro',  child: Text('Calcular desde prueba hidrostática', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'su',     child: Text('Calcular desde resistencia última Su', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _syMethod = v);
                        if (v == 'direct') _applySy(_syDirect);
                        if (v == 'hydro' && p.od > 0 && p.tw > 0) {
                          _applySy(_syHydroP * p.od / (2 * p.tw));
                        }
                        if (v == 'su') _applySy(_suVal * 0.70);
                      },
                    ),
                    const SizedBox(height: 8),
                    if (_syMethod == 'direct')
                      _NumInput(
                        label: 'Sy conocido (MPa)',
                        value: _syDirect,
                        onChanged: (v) { setState(() => _syDirect = v); _applySy(v); },
                      ),
                    if (_syMethod == 'hydro')
                      _NumInput(
                        label: 'Presión de fluencia hidrostática (MPa)',
                        value: _syHydroP,
                        onChanged: (v) {
                          setState(() => _syHydroP = v);
                          if (p.od > 0 && p.tw > 0) _applySy(v * p.od / (2 * p.tw));
                        },
                      ),
                    if (_syMethod == 'su')
                      _NumInput(
                        label: 'Su — resistencia última (MPa)',
                        value: _suVal,
                        onChanged: (v) { setState(() => _suVal = v); _applySy(v * 0.70); },
                      ),
                    const SizedBox(height: 6),
                    StatusBadge(text: _syResultText(), type: BadgeType.info),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            SliderField(label: 'Diámetro exterior OD (mm)',    min:20,  max:200, step:0.5,  value:p.od,  decimals:1, onChanged:(v)=>_upd(()=>p.od=v)),
            SliderField(label: 'Espesor de pared t (mm)',      min:0.5, max:20,  step:0.1,  value:p.tw,  decimals:2, onChanged:(v)=>_upd(()=>p.tw=v)),
            SliderField(label: 'Tensión de fluencia Sy (MPa)', min:20,  max:700, step:5,    value:p.sy,  decimals:0, onChanged:(v)=>_upd(()=>p.sy=v)),
            SliderField(label: 'Factor de seguridad FS',       min:1.5, max:8,   step:0.5,  value:p.fs,  decimals:1, onChanged:(v)=>_upd(()=>p.fs=v)),
            SliderField(label: 'Límite de uso (% del MEOP)',   min:30,  max:100, step:5,    value:p.pct*100, decimals:0, onChanged:(v)=>_upd(()=>p.pct=v/100)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                StatusBadge(text: 'P_burst = ${_pburst.toStringAsFixed(2)} MPa', type: BadgeType.info),
                StatusBadge(text: 'MEOP (FS ${p.fs.toStringAsFixed(1)}) = ${_meop.toStringAsFixed(3)} MPa', type: BadgeType.ok),
                StatusBadge(text: 'OD/t = ${p.tw > 0 ? (p.od / p.tw).toStringAsFixed(1) : "—"}', type: BadgeType.info),
              ],
            ),
          ],
        ),
        SrmSection(
          title: 'Tobera',
          children: [
            SliderField(label: 'Diámetro de garganta Dt (mm)', min:1,  max:60,  step:0.1, value:p.dtD, decimals:2, onChanged:(v)=>_upd(()=>p.dtD=v)),
            SliderField(label: 'Diámetro de salida De (mm)',   min:2,  max:120, step:0.5, value:p.deD, decimals:1, onChanged:(v)=>_upd(()=>p.deD=v)),
            SliderField(label: 'Semiángulo divergente (°)',    min:5,  max:30,  step:1,   value:p.divAng, decimals:0, onChanged:(v)=>_upd(()=>p.divAng=v)),
          ],
        ),
      ],
    );
  }
}

class _MatCard extends StatelessWidget {
  final MaterialData mat;
  final bool selected;
  final VoidCallback onTap;
  const _MatCard({required this.mat, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F0FB) : Colors.white,
          border: Border.all(color: selected ? kNavy : const Color(0xFFDDDDDD), width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mat.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(mat.sy != null ? 'Sy = ${mat.sy} MPa' : 'Personalizado',
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
            Text(mat.nota, style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _NumInput extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _NumInput({required this.label, required this.value, required this.onChanged});

  @override
  State<_NumInput> createState() => _NumInputState();
}

class _NumInputState extends State<_NumInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(fontSize: 12),
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        style: const TextStyle(fontSize: 13),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (s) {
          final v = double.tryParse(s);
          if (v != null) widget.onChanged(v);
        },
      ),
    );
  }
}
