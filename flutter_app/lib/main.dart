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
              'SpaceLabs · ITCR · Costa Rica — Teoría de Richard Nakka',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
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
