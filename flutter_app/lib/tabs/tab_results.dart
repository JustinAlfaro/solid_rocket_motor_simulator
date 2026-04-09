import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../simulation_engine.dart';
import '../widgets.dart';
import '../exporter.dart';

class TabResults extends StatelessWidget {
  final SimResult? result;
  const TabResults({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final safe = r.pcNom <= r.pw;
    final pctPc = r.pw > 0 ? (r.pcNom / r.pw * 100) : 999;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SrmSection(
          title: 'Indicadores clave',
          children: [
            _MetricsGrid(r: r),
            const SizedBox(height: 8),
            StatusBadge(
              text: safe
                  ? 'Dentro del MEOP — Pc es ${pctPc.toStringAsFixed(1)}% del MEOP'
                  : 'SUPERA EL MEOP — Pc es ${pctPc.toStringAsFixed(1)}% del MEOP',
              type: safe ? BadgeType.ok : BadgeType.err,
            ),
            if (!safe) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F2),
                  border: Border.all(color: const Color(0xFFE08080)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'La presión de cámara supera el límite seguro del casing. '
                  'Para solucionarlo: aumente el diámetro de la garganta (Dt), '
                  'reduzca el OD del grano, disminuya el número de segmentos, '
                  'o use un casing con mayor resistencia (Sy más alto).',
                  style: TextStyle(fontSize: 12, color: Color(0xFFA32D2D), height: 1.5),
                ),
              ),
            ],
          ],
        ),
        SrmSection(
          title: 'Curvas F(t) y P(t)',
          children: [
            _ChartFP(r: r),
          ],
        ),
        SrmSection(
          title: 'Impulso específico Isp(t)',
          children: [
            _ChartIsp(r: r),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy, foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                onPressed: () => exportCSV(context, r),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Exportar CSV'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontSize: 12)),
                onPressed: () => exportEng(context, r),
                icon: const Icon(Icons.rocket_launch, size: 16),
                label: const Text('Exportar .eng (OpenRocket / RASAero)'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final SimResult r;
  const _MetricsGrid({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: MetricCard(label: 'Empuje nominal',  value: r.fNom.toStringAsFixed(1),  unit: 'N')),
          const SizedBox(width: 6),
          Expanded(child: MetricCard(label: 'Empuje promedio', value: r.fAvg.toStringAsFixed(1),  unit: 'N')),
          const SizedBox(width: 6),
          Expanded(child: MetricCard(label: 'Impulso total',   value: r.it.toStringAsFixed(0),    unit: 'N·s')),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: MetricCard(label: 'Tiempo comb.',    value: r.tb.toStringAsFixed(2),    unit: 's')),
          const SizedBox(width: 6),
          Expanded(child: MetricCard(label: 'Clase Tripoli',   value: r.clase)),
          const SizedBox(width: 6),
          Expanded(child: MetricCard(label: 'Ae/At',           value: (r.ae / r.at).toStringAsFixed(2))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: MetricCard(label: 'Pc nominal',     value: r.pcNom.toStringAsFixed(3), unit: 'MPa')),
          const SizedBox(width: 6),
          Expanded(child: MetricCard(label: 'MEOP (FS ${r.fs_.toStringAsFixed(1)})', value: r.pw.toStringAsFixed(3), unit: 'MPa')),
          const SizedBox(width: 6),
          Expanded(child: MetricCard(label: 'Isp nominal',    value: r.ispNom.toStringAsFixed(0), unit: 's')),
        ]),
      ],
    );
  }
}

// ── Gráfica F(t) y P(t) ───────────────────────────────────────────────────────
class _ChartFP extends StatelessWidget {
  final SimResult r;
  const _ChartFP({required this.r});

  @override
  Widget build(BuildContext context) {
    final step = (r.ts.length / 150).ceil().clamp(1, r.ts.length);
    final List<FlSpot> fSpots = [], pSpots = [];
    for (int i = 0; i < r.ts.length; i += step) {
      fSpots.add(FlSpot(r.ts[i], r.fs[i]));
      pSpots.add(FlSpot(r.ts[i], r.ps[i] * 50));
    }

    return Column(
      children: [
        Row(children: [
          _Legend(color: const Color(0xFF378ADD), label: 'Empuje F (N)', dashed: false),
          const SizedBox(width: 12),
          _Legend(color: const Color(0xFFD85A30), label: 'Presión P×50 (MPa)', dashed: true),
        ]),
        const SizedBox(height: 6),
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(spots: fSpots, color: const Color(0xFF378ADD), barWidth: 2, dotData: const FlDotData(show: false), isCurved: true),
              LineChartBarData(spots: pSpots, color: const Color(0xFFD85A30), barWidth: 1.5, dotData: const FlDotData(show: false), isCurved: true, dashArray: [6, 3]),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 9)))),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 9)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
          )),
        ),
      ],
    );
  }
}

class _ChartIsp extends StatelessWidget {
  final SimResult r;
  const _ChartIsp({required this.r});

  @override
  Widget build(BuildContext context) {
    final step = (r.ts.length / 150).ceil().clamp(1, r.ts.length);
    final spots = <FlSpot>[];
    for (int i = 0; i < r.ts.length; i += step) {
      spots.add(FlSpot(r.ts[i], r.isps[i]));
    }

    return SizedBox(
      height: 140,
      child: LineChart(LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: const Color(0xFF1D9E75),
            barWidth: 2,
            dotData: const FlDotData(show: false),
            isCurved: true,
            belowBarData: BarAreaData(show: true, color: const Color(0x141D9E75)),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 9)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 9)))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      )),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _Legend({required this.color, required this.label, required this.dashed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18, height: 3,
          decoration: BoxDecoration(color: dashed ? Colors.transparent : color, borderRadius: BorderRadius.circular(2)),
          child: dashed
            ? CustomPaint(painter: _DashPainter(color: color))
            : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 2;
    canvas.drawLine(Offset.zero, Offset(size.width / 2, 0), p);
  }
  @override bool shouldRepaint(_) => false;
}
