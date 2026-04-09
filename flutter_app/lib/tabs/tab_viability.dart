import 'package:flutter/material.dart';
import '../simulation_engine.dart';
import '../widgets.dart';

class TabViability extends StatelessWidget {
  final SimResult? result;
  final SimParams params;
  const TabViability({super.key, required this.result, required this.params});

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) return const Center(child: CircularProgressIndicator());

    final p = params;
    final idCas = p.od, tCas = p.tw;
    final idInner = idCas - 2 * tCas;

    final checks = <_Check>[
      _Check(
        label: 'Presión de cámara dentro del límite del casing',
        ok: r.pcNom <= r.pw && r.pw > 0,
        val: 'Pc = ${r.pcNom.toStringAsFixed(3)} MPa | MEOP = ${r.pw.toStringAsFixed(3)} MPa',
        msgOk: 'La presión de diseño está por debajo del límite máximo de operación del casing.',
        msgFail: 'La presión de cámara (${r.pcNom.toStringAsFixed(3)} MPa) supera el MEOP del casing (${r.pw.toStringAsFixed(3)} MPa). '
          'Soluciones: (1) Aumente el diámetro de garganta Dt, (2) reduzca el área de combustión, (3) cambie a material con mayor Sy.',
      ),
      _Check(
        label: 'Factor de seguridad estructural suficiente',
        ok: r.pb > 0 && r.pcNom > 0 && (r.pb / r.pcNom) >= r.fs_,
        val: 'FS real = ${r.pcNom > 0 ? (r.pb / r.pcNom).toStringAsFixed(2) : "—"}x | FS mínimo = ${r.fs_.toStringAsFixed(1)}x',
        msgOk: 'El casing tiene un margen estructural de ${r.pcNom > 0 ? (r.pb / r.pcNom).toStringAsFixed(2) : "—"}x.',
        msgFail: 'FS real insuficiente. Tripoli recomienda FS≥4 para PVC y FS≥3 para metales.',
      ),
      _Check(
        label: 'Kn en rango de combustión estable (100 – 300)',
        ok: r.knNom >= 100 && r.knNom <= 300,
        val: 'Kn = ${r.knNom.toStringAsFixed(0)}',
        msgOk: 'Kn inicial de ${r.knNom.toStringAsFixed(0)} está dentro del rango estable.',
        msgFail: r.knNom < 100
          ? 'Kn = ${r.knNom.toStringAsFixed(0)} es demasiado bajo (<100). Puede provocar apagado prematuro. Reduzca Dt o aumente el área de grano.'
          : 'Kn = ${r.knNom.toStringAsFixed(0)} es demasiado alto (>300). Puede generar sobrepresión. Aumente Dt o reduzca el área de grano.',
      ),
      _Check(
        label: 'El grano cabe dentro del casing',
        ok: p.odG < idInner && idInner > 0,
        val: 'OD grano = ${p.odG.toStringAsFixed(1)} mm | ID casing = ${idInner.toStringAsFixed(1)} mm',
        msgOk: 'El grano (OD ${p.odG.toStringAsFixed(1)} mm) cabe en el casing con holgura de ${(idInner - p.odG).toStringAsFixed(1)} mm.',
        msgFail: 'El grano (OD ${p.odG.toStringAsFixed(1)} mm) no cabe en el casing (ID ${idInner.toStringAsFixed(1)} mm).',
      ),
      _Check(
        label: 'Canal central (core) definido y funcional',
        ok: p.coreD >= 3 && p.coreD < p.odG,
        val: 'Core Ø = ${p.coreD.toStringAsFixed(1)} mm | OD grano = ${p.odG.toStringAsFixed(1)} mm',
        msgOk: 'Canal central de ${p.coreD.toStringAsFixed(1)} mm es suficiente para la ignición.',
        msgFail: p.coreD < 3
          ? 'Core (${p.coreD.toStringAsFixed(1)} mm) muy pequeño. Mínimo recomendado: 3 mm.'
          : 'Core mayor o igual al OD del grano. No hay propelente.',
      ),
      _Check(
        label: 'Tobera con sección divergente (Ae/At > 1)',
        ok: r.ae / r.at > 1.0,
        val: 'Ae/At = ${(r.ae / r.at).toStringAsFixed(2)} | De = ${p.deD.toStringAsFixed(1)} mm | Dt = ${p.dtD.toStringAsFixed(1)} mm',
        msgOk: 'Relación de expansión Ae/At = ${(r.ae / r.at).toStringAsFixed(2)}. Nakka recomienda 2–12 para motores amateur.',
        msgFail: 'De (${p.deD.toStringAsFixed(1)} mm) ≤ Dt (${p.dtD.toStringAsFixed(1)} mm). La tobera no tiene divergente. Aumente De.',
      ),
      _Check(
        label: 'Impulso total clasificado Tripoli/NAR',
        ok: r.it >= 2.5,
        val: 'It = ${r.it.toStringAsFixed(0)} N·s | Clase ${r.clase}',
        msgOk: '${r.it.toStringAsFixed(0)} N·s, clase ${r.clase}. A partir de clase H se requiere certificación Level 1.',
        msgFail: 'Impulso inferior a 2.5 N·s (clase A). Revise la masa del grano y los parámetros del propelente.',
      ),
      _Check(
        label: 'Tiempo de combustión razonable (0.5 – 30 s)',
        ok: r.tb >= 0.5 && r.tb <= 30,
        val: 'tb = ${r.tb.toStringAsFixed(2)} s',
        msgOk: 'Tiempo de combustión de ${r.tb.toStringAsFixed(2)} s es adecuado.',
        msgFail: r.tb < 0.5
          ? 'Combustión muy rápida (${r.tb.toStringAsFixed(2)} s). Puede generar picos de presión difíciles de controlar.'
          : 'Combustión excesivamente larga (${r.tb.toStringAsFixed(2)} s). Revise la configuración del grano.',
      ),
    ];

    final nOk = checks.where((c) => c.ok).length;
    final viable = nOk == checks.length;
    final criticos = !checks[0].ok || !checks[1].ok;
    final estado = viable ? BadgeType.ok : criticos ? BadgeType.err : BadgeType.warn;
    final etiq = viable ? '✓ MOTOR VIABLE'
        : criticos ? '✗ NO VIABLE — Problemas críticos'
        : '⚠ VIABLE CON ADVERTENCIAS';

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SrmSection(
          title: 'Análisis de viabilidad del motor',
          children: [
            Row(
              children: [
                StatusBadge(text: etiq, type: estado),
                const SizedBox(width: 10),
                Text('$nOk de ${checks.length} criterios', style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
            if (viable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FB),
                  border: Border.all(color: const Color(0xFF9DC0F0)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Todos los criterios de diseño están dentro de los rangos recomendados. '
                  'El motor está listo para proceder a la fabricación y prueba hidrostática.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF185FA5), height: 1.5),
                ),
              ),
            ],
            const SizedBox(height: 10),
            ...checks.map((c) => _ViabRow(check: c)),
          ],
        ),
      ],
    );
  }
}

class _Check {
  final String label, val, msgOk, msgFail;
  final bool ok;
  const _Check({required this.label, required this.ok, required this.val, required this.msgOk, required this.msgFail});
}

class _ViabRow extends StatelessWidget {
  final _Check check;
  const _ViabRow({super.key, required this.check});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(check.ok ? '✅' : '❌', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(check.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(check.val, style: const TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'monospace')),
                const SizedBox(height: 2),
                Text(
                  check.ok ? check.msgOk : check.msgFail,
                  style: TextStyle(
                    fontSize: 12, height: 1.5,
                    color: check.ok ? const Color(0xFF1E7A3B) : const Color(0xFFA32D2D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
