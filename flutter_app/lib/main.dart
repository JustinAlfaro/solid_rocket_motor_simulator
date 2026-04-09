import 'package:flutter/material.dart';
import 'simulation_engine.dart';
import 'tabs/tab_propellant.dart';
import 'tabs/tab_casing.dart';
import 'tabs/tab_results.dart';
import 'tabs/tab_viability.dart';
import 'tabs/tab_table.dart';

void main() {
  runApp(const SrmApp());
}

class SrmApp extends StatelessWidget {
  const SrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador Motor Cohete — SpaceLabs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A5C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SimulatorHome(),
    );
  }
}

class SimulatorHome extends StatefulWidget {
  const SimulatorHome({super.key});

  @override
  State<SimulatorHome> createState() => _SimulatorHomeState();
}

class _SimulatorHomeState extends State<SimulatorHome>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SimParams _params = SimParams();
  SimResult? _result;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _runSimulation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _runSimulation() {
    setState(() {
      _result = simulate(_params);
    });
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Acerca del simulador',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('SpaceLabs · ITCR · Costa Rica',
                  style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
              const SizedBox(height: 14),
              const Text('Referencias bibliográficas',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _RefItem(
                num: 1,
                text: 'R. Nakka, Teoría sobre motores cohete de propelente sólido, '
                    'trad. S. Garofalo.',
              ),
              _RefItem(
                num: 2,
                text: 'D. T. Harrje y F. H. Reardon (eds.), Liquid Propellant Rocket '
                    'Combustion Instability, NASA SP-194, NASA, 1972.',
              ),
              _RefItem(
                num: 3,
                text: 'Solid Rocket Motor Performance Analysis and Prediction, NASA.',
              ),
              const SizedBox(height: 14),
              const Text('Desarrollo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Justin G. Alfaro Araya\nMotor de referencia: MD-2026-001 Rev. B',
                  style: TextStyle(fontSize: 12, color: Color(0xFF555555), height: 1.6)),
              const SizedBox(height: 12),
              const Text('MIT License',
                  style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        titleSpacing: 12,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulador Motor Cohete de Propelente Sólido',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              'SpaceLabs · ITCR · Costa Rica',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            tooltip: 'Acerca de / Fuentes',
            onPressed: () => _showAbout(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'Propelente y grano'),
            Tab(text: 'Casing y tobera'),
            Tab(text: 'Resultados'),
            Tab(text: 'Viabilidad'),
            Tab(text: 'Tabla completa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TabPropellant(params: _params, onChanged: _runSimulation),
          TabCasing(params: _params, onChanged: _runSimulation),
          TabResults(result: _result),
          TabViability(result: _result, params: _params),
          TabTable(result: _result),
        ],
      ),
    );
  }
}

class _RefItem extends StatelessWidget {
  final int num;
  final String text;
  const _RefItem({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('[$num] ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A3A5C))),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF444444), height: 1.5))),
        ],
      ),
    );
  }
}
