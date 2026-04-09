import 'dart:math';

const double g0 = 9.80665;

class PropellantData {
  final double rho, a, n, cstar, cf, tc;
  const PropellantData({
    required this.rho,
    required this.a,
    required this.n,
    required this.cstar,
    required this.cf,
    required this.tc,
  });
}

class MaterialData {
  final String id, name, nota;
  final double? sy;
  const MaterialData({
    required this.id,
    required this.name,
    required this.nota,
    this.sy,
  });
}

const Map<String, PropellantData> kProps = {
  'knsu':          PropellantData(rho:1780, a:3.8,  n:0.40, cstar:660,  cf:1.35, tc:1720),
  'kndx':          PropellantData(rho:1740, a:7.1,  n:0.32, cstar:670,  cf:1.36, tc:1710),
  'knmx':          PropellantData(rho:1840, a:3.4,  n:0.38, cstar:650,  cf:1.33, tc:1650),
  'kner':          PropellantData(rho:1720, a:5.5,  n:0.33, cstar:655,  cf:1.34, tc:1680),
  'apcp_standard': PropellantData(rho:1700, a:5.0,  n:0.35, cstar:1580, cf:1.62, tc:3200),
  'apcp_fast':     PropellantData(rho:1730, a:6.2,  n:0.33, cstar:1600, cf:1.65, tc:3300),
};

const List<MaterialData> kMats = [
  MaterialData(id:'pvc_sdr26', name:'PVC SDR26',    sy:48,  nota:'Agua a presión — Rating fab. 1.103 MPa'),
  MaterialData(id:'pvc_sch40', name:'PVC SCH40',    sy:48,  nota:'Uso general hasta ~2 MPa de Pc'),
  MaterialData(id:'al6061',    name:'Al 6061-T6',   sy:276, nota:'El más usado en cohetería amateur'),
  MaterialData(id:'al6063',    name:'Al 6063-T5',   sy:145, nota:'Más accesible, menor resistencia'),
  MaterialData(id:'al2024',    name:'Al 2024-T3',   sy:345, nota:'Alto rendimiento, más costoso'),
  MaterialData(id:'st_a36',    name:'Acero A36',    sy:250, nota:'Económico, pesado (7.85 g/cc)'),
  MaterialData(id:'st_1018',   name:'Acero 1018',   sy:370, nota:'Bueno para casings y toberas'),
  MaterialData(id:'st_304',    name:'Inox 304',     sy:207, nota:'Resistente a corrosión'),
  MaterialData(id:'st_316',    name:'Inox 316',     sy:207, nota:'Mayor resist. química que 304'),
  MaterialData(id:'frp',       name:'Fibra vidrio', sy:200, nota:'Liviano y buen aislante térmico'),
  MaterialData(id:'cfrp',      name:'Fibra carbono',sy:350, nota:'Máximo rendimiento, frágil'),
  MaterialData(id:'custom',    name:'Personalizado',sy:null,nota:'Configure Sy con la calculadora'),
];

double calcAb(
  String geo, double rg, double rc,
  double nseg, double lseg,
  double starN, double starF,
  double finN, double finW,
) {
  const pi = pi_val;
  switch (geo) {
    case 'bates':
      return pi * (rg * rg - rc * rc) * 2 * nseg + pi * rc * 2 * lseg * nseg;
    case 'tubular':
      return pi * rc * 2 * lseg * nseg;
    case 'endburner':
      return pi * rg * rg * nseg;
    case 'star':
      final ri = rg * starF;
      return (2 * rg * sin(pi / starN) * starN + 2 * ri * sin(pi / starN) * starN) * 0.5 * lseg * nseg;
    case 'finocyl':
      return pi * rc * 2 * lseg * nseg + finN * 2 * (rg - rc) * lseg * nseg;
    case 'moon':
      return pi * rc * lseg * nseg * 1.4;
    default:
      return pi * (rg * rg - rc * rc) * 2 * nseg + pi * rc * 2 * lseg * nseg;
  }
}

const double pi_val = pi;

class SimResult {
  final List<double> ts, fs, ps, isps, rbs, abs_, kns;
  final double it, fNom, fAvg, pcNom, pcAvg, ispNom, ispAvg, tb, pw, pb, pct;
  final double at, ae, dt;
  final String clase;
  final double odG, coreD, nseg, lseg, dtD, knNom, fs_, od, tw, sy;

  const SimResult({
    required this.ts, required this.fs, required this.ps,
    required this.isps, required this.rbs, required this.abs_,
    required this.kns, required this.it,
    required this.fNom, required this.fAvg,
    required this.pcNom, required this.pcAvg,
    required this.ispNom, required this.ispAvg,
    required this.tb, required this.pw, required this.pb,
    required this.pct, required this.at, required this.ae,
    required this.dt, required this.clase,
    required this.odG, required this.coreD, required this.nseg,
    required this.lseg, required this.dtD, required this.knNom,
    required this.fs_, required this.od, required this.tw, required this.sy,
  });
}

SimResult simulate(SimParams p) {
  final ams = p.a / 1000.0;
  final at = pi * pow(p.dtD / 2, 2);
  final ae = pi * pow(p.deD / 2, 2);
  final pb = (p.od > 0 && p.tw > 0) ? 2 * p.sy * p.tw / p.od : 1.0;
  final pw = pb / p.fs;
  const dt = 0.010;

  double t = 0, rg = p.odG / 2, rc = p.coreD / 2;
  final ts = <double>[], fsList = <double>[], psList = <double>[];
  final ispsList = <double>[], rbsList = <double>[];
  final absList = <double>[], knsList = <double>[];
  double it = 0;

  for (int i = 0; i < 15000; i++) {
    final ab = calcAb(p.geo, rg, rc, p.nseg, p.lseg, p.starN, p.starF, p.finN, p.finW);
    if (ab <= 0 || rc >= rg) break;
    final kn = ab / at;
    final pc = pow(p.rho * ams * p.cstar * kn * 1e-6, 1.0 / (1.0 - p.n)).toDouble();
    final rb = (ams * pow(pc, p.n) * 1000).toDouble();
    final f = p.cf * pc * 1e6 * at * 1e-6;
    final mdot = p.rho * rb * 1e-3 * ab * 1e-6;
    final isp = mdot > 0 ? f / (mdot * g0) : 0.0;
    ts.add(t); fsList.add(f); psList.add(pc);
    ispsList.add(isp.clamp(0.0, 500.0)); rbsList.add(rb);
    absList.add(ab); knsList.add(kn);
    it += f * dt;
    switch (p.geo) {
      case 'bates':
      case 'tubular':
      case 'finocyl':
      case 'moon':
        rc += rb * dt;
        break;
      case 'endburner':
        // burns single step
        i = 15000;
        break;
      case 'star':
        rc += rb * dt * 0.8;
        break;
    }
    t += dt;
  }

  final double fNom = fsList.isNotEmpty ? fsList.first : 0.0;
  final double pcNom = psList.isNotEmpty ? psList.first : 0.0;
  final double ispNom = ispsList.isNotEmpty ? ispsList.first : 0.0;
  final double tb = ts.isNotEmpty ? ts.last : 0.0;
  final double fAvg = fsList.isEmpty ? 0.0 : fsList.reduce((a, b) => a + b) / fsList.length;
  final double pcAvg = psList.isEmpty ? 0.0 : psList.reduce((a, b) => a + b) / psList.length;
  final double ispAvg = ispsList.isEmpty ? 0.0 : ispsList.reduce((a, b) => a + b) / ispsList.length;
  final double knNom = knsList.isNotEmpty ? knsList.first : 0.0;

  String clase;
  if (it < 2.5) clase = 'A';
  else if (it < 5) clase = 'B';
  else if (it < 10) clase = 'C';
  else if (it < 20) clase = 'D';
  else if (it < 40) clase = 'E';
  else if (it < 80) clase = 'F';
  else if (it < 160) clase = 'G';
  else if (it < 320) clase = 'H';
  else if (it < 640) clase = 'I';
  else if (it < 1280) clase = 'J';
  else if (it < 2560) clase = 'K';
  else clase = 'L+';

  return SimResult(
    ts: ts, fs: fsList, ps: psList, isps: ispsList,
    rbs: rbsList, abs_: absList, kns: knsList,
    it: it, fNom: fNom, fAvg: fAvg, pcNom: pcNom, pcAvg: pcAvg,
    ispNom: ispNom, ispAvg: ispAvg, tb: tb, pw: pw, pb: pb,
    pct: p.pct, at: at, ae: ae, dt: dt, clase: clase,
    odG: p.odG, coreD: p.coreD, nseg: p.nseg, lseg: p.lseg,
    dtD: p.dtD, knNom: knNom, fs_: p.fs, od: p.od, tw: p.tw, sy: p.sy,
  );
}

class SimParams {
  double rho, a, n, cstar, cf, tc;
  double odG, coreD, nseg, lseg;
  double starN, starF, finN, finW;
  double dtD, deD;
  double od, tw, sy, fs, pct;
  double divAng;
  String geo;

  SimParams({
    this.rho = 1780, this.a = 3.8, this.n = 0.40,
    this.cstar = 660, this.cf = 1.35, this.tc = 1720,
    this.odG = 42.31, this.coreD = 12, this.nseg = 3, this.lseg = 80,
    this.starN = 5, this.starF = 0.45, this.finN = 4, this.finW = 4,
    this.dtD = 10.92, this.deD = 19.0,
    this.od = 48, this.tw = 1.84, this.sy = 48, this.fs = 4, this.pct = 1.0,
    this.divAng = 15,
    this.geo = 'bates',
  });
}
