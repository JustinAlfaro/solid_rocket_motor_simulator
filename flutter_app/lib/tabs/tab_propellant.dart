import 'package:flutter/material.dart';
import 'dart:math';
import '../simulation_engine.dart';
import '../widgets.dart';

const _geoOptions = [
  ('bates',    'Bates — cilíndrico hueco, inhibido total'),
  ('tubular',  'Tubular — solo superficie lateral'),
  ('endburner','End-burner — cara plana'),
  ('star',     'Estrella — star grain'),
  ('finocyl',  'Finocyl — aletas + cilíndrico'),
  ('moon',     'C-slot — ranura en C'),
];

const _propOptions = [
  ('knsu',          'KNSU — KNO₃ + sacarosa'),
  ('kndx',          'KNDX — KNO₃ + dextrosa'),
  ('knmx',          'KNMX — KNO₃ + sorbitol'),
  ('kner',          'KNER — KNO₃ + eritritol'),
  ('apcp_standard', 'APCP estándar (74% AP)'),
  ('apcp_fast',     'APCP rápido (76% AP)'),
  ('custom',        'Personalizado'),
];

class TabPropellant extends StatefulWidget {
  final SimParams params;
  final VoidCallback onChanged;
  const TabPropellant({super.key, required this.params, required this.onChanged});

  @override
  State<TabPropellant> createState() => _TabPropellantState();
}

class _TabPropellantState extends State<TabPropellant> {
  String _propKey = 'knsu';
  String _geoKey = 'bates';

  SimParams get p => widget.params;

  void _onPropChange(String key) {
    setState(() => _propKey = key);
    if (key == 'custom') return;
    final d = kProps[key]!;
    p.rho = d.rho; p.a = d.a; p.n = d.n;
    p.cstar = d.cstar; p.cf = d.cf; p.tc = d.tc;
    widget.onChanged();
  }

  void _onGeoChange(String key) {
    setState(() => _geoKey = key);
    p.geo = key;
    widget.onChanged();
  }

  void _upd(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SrmSection(
          title: 'Propelente',
          children: [
            DropdownButtonFormField<String>(
              value: _propKey,
              decoration: const InputDecoration(
                labelText: 'Tipo de propelente',
                labelStyle: TextStyle(fontSize: 12),
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: _propOptions.map((o) =>
                DropdownMenuItem(value: o.$1, child: Text(o.$2, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) _onPropChange(v); },
            ),
            const SizedBox(height: 10),
            SliderField(label: 'Densidad ρ (kg/m³)',            min:1200, max:2100, step:10,   value:p.rho,   decimals:0, onChanged:(v)=>_upd(()=>p.rho=v)),
            SliderField(label: 'Coef. quema a (mm/s @ 1 MPa)', min:0.5,  max:30,   step:0.1,  value:p.a,     decimals:1, onChanged:(v)=>_upd(()=>p.a=v)),
            SliderField(label: 'Exponente de presión n',        min:0.05, max:0.85, step:0.01, value:p.n,     decimals:2, onChanged:(v)=>_upd(()=>p.n=v)),
            SliderField(label: 'Velocidad característica c* (m/s)', min:300, max:1800, step:10, value:p.cstar, decimals:0, onChanged:(v)=>_upd(()=>p.cstar=v)),
            SliderField(label: 'Coeficiente de empuje CF',      min:1.0,  max:1.9,  step:0.01, value:p.cf,    decimals:2, onChanged:(v)=>_upd(()=>p.cf=v)),
            SliderField(label: 'Temperatura de llama Tc (K)',   min:800,  max:3500, step:50,   value:p.tc,    decimals:0, onChanged:(v)=>_upd(()=>p.tc=v)),
          ],
        ),
        SrmSection(
          title: 'Geometría del grano',
          children: [
            DropdownButtonFormField<String>(
              value: _geoKey,
              decoration: const InputDecoration(
                labelText: 'Tipo de geometría',
                labelStyle: TextStyle(fontSize: 12),
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: _geoOptions.map((o) =>
                DropdownMenuItem(value: o.$1, child: Text(o.$2, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) { if (v != null) _onGeoChange(v); },
            ),
            const SizedBox(height: 10),
            Center(child: _GeoPreview(geo: _geoKey, odG: p.odG, coreD: p.coreD, starN: p.starN.toInt(), starF: p.starF, finN: p.finN.toInt())),
            const SizedBox(height: 8),
            SliderField(label: 'OD grano (mm)',              min:8,   max:200, step:0.5,  value:p.odG,   decimals:2, onChanged:(v)=>_upd(()=>p.odG=v)),
            SliderField(label: 'Core Ø / ancho ranura (mm)', min:2,   max:100, step:0.5,  value:p.coreD, decimals:1, onChanged:(v)=>_upd(()=>p.coreD=v)),
            SliderField(label: 'N° de segmentos',            min:1,   max:10,  step:1,    value:p.nseg,  decimals:0, onChanged:(v)=>_upd(()=>p.nseg=v)),
            SliderField(label: 'Longitud por segmento (mm)', min:10,  max:400, step:1,    value:p.lseg,  decimals:0, onChanged:(v)=>_upd(()=>p.lseg=v)),
            if (_geoKey == 'star') ...[
              SliderField(label: 'N° de puntas (estrella)',  min:4,   max:8,   step:1,    value:p.starN, decimals:0, onChanged:(v)=>_upd(()=>p.starN=v)),
              SliderField(label: 'Fracción de punta ε',      min:0.2, max:0.8, step:0.01, value:p.starF, decimals:2, onChanged:(v)=>_upd(()=>p.starF=v)),
            ],
            if (_geoKey == 'finocyl') ...[
              SliderField(label: 'N° de aletas (finocyl)',   min:3,   max:8,   step:1,    value:p.finN,  decimals:0, onChanged:(v)=>_upd(()=>p.finN=v)),
              SliderField(label: 'Ancho de aleta (mm)',      min:1,   max:20,  step:0.5,  value:p.finW,  decimals:1, onChanged:(v)=>_upd(()=>p.finW=v)),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Preview SVG-like del grano ────────────────────────────────────────────────
class _GeoPreview extends StatelessWidget {
  final String geo;
  final double odG, coreD, starF;
  final int starN, finN;
  const _GeoPreview({required this.geo, required this.odG, required this.coreD, required this.starN, required this.starF, required this.finN});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, height: 100,
      child: CustomPaint(painter: _GeoPainter(geo: geo, odG: odG, coreD: coreD, starN: starN, starF: starF, finN: finN)),
    );
  }
}

class _GeoPainter extends CustomPainter {
  final String geo;
  final double odG, coreD, starF;
  final int starN, finN;
  const _GeoPainter({required this.geo, required this.odG, required this.coreD, required this.starN, required this.starF, required this.finN});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final rg = odG / 2, rc = coreD / 2;
    final scale = (size.width * 0.45) / rg;
    final R = rg * scale, Rc = rc * scale;

    final outerPaint = Paint()..color = const Color(0xFFF0D080)..style = PaintingStyle.fill;
    final outerStroke = Paint()..color = const Color(0xFFA08030)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final corePaint = Paint()..color = const Color(0xFF1A3A5C)..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx, cy);

    switch (geo) {
      case 'bates':
      case 'tubular':
        canvas.drawCircle(Offset.zero, R, outerPaint);
        canvas.drawCircle(Offset.zero, R, outerStroke);
        canvas.drawCircle(Offset.zero, Rc, corePaint);
        break;
      case 'endburner':
        canvas.drawCircle(Offset.zero, R, outerPaint);
        canvas.drawCircle(Offset.zero, R, outerStroke);
        canvas.drawCircle(Offset.zero, 3, corePaint);
        break;
      case 'star':
        final ri = R * starF;
        final path = Path();
        for (int i = 0; i < starN * 2; i++) {
          final a = pi * i / starN - pi / 2;
          final r = i % 2 == 0 ? R : ri;
          final x = r * cos(a), y = r * sin(a);
          if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        path.close();
        canvas.drawPath(path, outerPaint);
        canvas.drawPath(path, outerStroke);
        canvas.drawCircle(Offset.zero, 3, corePaint);
        break;
      case 'finocyl':
        canvas.drawCircle(Offset.zero, R, outerPaint);
        canvas.drawCircle(Offset.zero, R, outerStroke);
        canvas.drawCircle(Offset.zero, Rc, corePaint..color = corePaint.color.withAlpha(100));
        final finPaint = Paint()..color = const Color(0xFF1A3A5C)..strokeWidth = 3..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
        for (int i = 0; i < finN; i++) {
          final a = 2 * pi * i / finN;
          canvas.drawLine(Offset(Rc * cos(a), Rc * sin(a)), Offset(R * cos(a), R * sin(a)), finPaint);
        }
        break;
      case 'moon':
        canvas.drawCircle(Offset.zero, R, outerPaint);
        canvas.drawCircle(Offset.zero, R, outerStroke);
        final slotPaint = Paint()..color = const Color(0xFF1A3A5C).withAlpha(128)..style = PaintingStyle.fill;
        canvas.drawOval(Rect.fromCenter(center: Offset(Rc * 0.5, 0), width: Rc * 2.2, height: Rc * 2), slotPaint);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GeoPainter old) =>
    old.geo != geo || old.odG != odG || old.coreD != coreD || old.starN != starN || old.starF != starF || old.finN != finN;
}
