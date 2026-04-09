import 'package:flutter/material.dart';
import '../simulation_engine.dart';
import '../widgets.dart';
import '../exporter.dart';

class TabTable extends StatelessWidget {
  final SimResult? result;
  const TabTable({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) return const Center(child: CircularProgressIndicator());

    final step = (r.ts.length / 80).ceil().clamp(1, r.ts.length);
    double acum = 0;
    final rows = <DataRow>[];
    for (int i = 0; i < r.ts.length; i += step) {
      acum += r.fs[i] * r.dt;
      rows.add(DataRow(cells: [
        DataCell(Text(r.ts[i].toStringAsFixed(3),  style: const TextStyle(fontSize: 11))),
        DataCell(Text(r.fs[i].toStringAsFixed(2),  style: const TextStyle(fontSize: 11))),
        DataCell(Text(r.ps[i].toStringAsFixed(4),  style: const TextStyle(fontSize: 11))),
        DataCell(Text(r.isps[i].toStringAsFixed(1),style: const TextStyle(fontSize: 11))),
        DataCell(Text(r.rbs[i].toStringAsFixed(3), style: const TextStyle(fontSize: 11))),
        DataCell(Text(r.abs_[i].toStringAsFixed(0),style: const TextStyle(fontSize: 11))),
        DataCell(Text(r.kns[i].toStringAsFixed(1), style: const TextStyle(fontSize: 11))),
        DataCell(Text(acum.toStringAsFixed(2),      style: const TextStyle(fontSize: 11))),
      ]));
    }

    const colStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF888888));
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SrmSection(
          title: 'Tabla de resultados — paso de tiempo completo',
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 28,
                dataRowMaxHeight: 28,
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('t (s)',     style: colStyle)),
                  DataColumn(label: Text('F (N)',     style: colStyle), numeric: true),
                  DataColumn(label: Text('P (MPa)',   style: colStyle), numeric: true),
                  DataColumn(label: Text('Isp (s)',   style: colStyle), numeric: true),
                  DataColumn(label: Text('r_b mm/s',  style: colStyle), numeric: true),
                  DataColumn(label: Text('Ab (mm²)',  style: colStyle), numeric: true),
                  DataColumn(label: Text('Kn',        style: colStyle), numeric: true),
                  DataColumn(label: Text('It (N·s)',  style: colStyle), numeric: true),
                ],
                rows: rows,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy, foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12),
              ),
              onPressed: () => exportCSV(context, r),
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Exportar CSV completo'),
            ),
          ],
        ),
      ],
    );
  }
}
