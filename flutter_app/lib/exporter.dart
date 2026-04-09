import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'simulation_engine.dart';

Future<void> exportCSV(BuildContext context, SimResult r) async {
  final messenger = ScaffoldMessenger.of(context);
  final buf = StringBuffer('t_s,F_N,P_MPa,Isp_s,rb_mms,Ab_mm2,Kn,It_acum_Ns\n');
  double acum = 0;
  for (int i = 0; i < r.ts.length; i++) {
    acum += r.fs[i] * r.dt;
    buf.write('${r.ts[i].toStringAsFixed(4)},${r.fs[i].toStringAsFixed(3)},'
        '${r.ps[i].toStringAsFixed(5)},${r.isps[i].toStringAsFixed(2)},'
        '${r.rbs[i].toStringAsFixed(4)},${r.abs_[i].toStringAsFixed(1)},'
        '${r.kns[i].toStringAsFixed(2)},${acum.toStringAsFixed(3)}\n');
  }
  await _saveFile(messenger, buf.toString(), 'motor_simulado.csv');
}

Future<void> exportEng(BuildContext context, SimResult r) async {
  final messenger = ScaffoldMessenger.of(context);
  final mp = _sq(r.odG / 2) - _sq(r.coreD / 2);
  final mpStr = (3.14159 * mp * r.nseg * r.lseg * 1e-9 * 0.695).toStringAsFixed(4);
  final mtStr = (3.14159 * mp * r.nseg * r.lseg * 1e-9).toStringAsFixed(4);
  final buf = StringBuffer('; Simulado por SpaceLabs ITCR\n'
      '; Motor clase ${r.clase} — It=${r.it.toStringAsFixed(0)} N·s\n'
      'Motor-${r.clase} ${r.odG.toStringAsFixed(0)} ${(r.nseg * r.lseg).toStringAsFixed(0)} 0 $mpStr $mtStr SpaceLabs\n');
  final step = (r.ts.length / 60).ceil().clamp(1, r.ts.length);
  for (int i = 0; i < r.ts.length; i += step) {
    buf.write('${r.ts[i].toStringAsFixed(3)} ${r.fs[i].toStringAsFixed(3)}\n');
  }
  if (r.ts.isNotEmpty) {
    buf.write('${(r.ts.last + r.dt).toStringAsFixed(3)} 0.000\n;');
  }
  await _saveFile(messenger, buf.toString(), 'motor_simulado.eng');
}

double _sq(double x) => x * x;

String _saveDir() {
  if (kIsWeb) return '';
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.';
  final downloads = '$home/Downloads';
  if (Directory(downloads).existsSync()) return downloads;
  return home;
}

Future<void> _saveFile(ScaffoldMessengerState messenger, String content, String filename) async {
  try {
    if (kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Exportación no disponible en web. Use la versión HTML.')),
      );
      return;
    }
    final path = '${_saveDir()}/$filename';
    await File(path).writeAsString(content);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Guardado en: $path'),
        duration: const Duration(seconds: 4),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
  }
}
