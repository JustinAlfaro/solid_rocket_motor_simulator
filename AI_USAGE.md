# Nota de uso de inteligencia artificial

Este documento describe de forma transparente el rol que tuvo la inteligencia artificial en el desarrollo de este proyecto.

---

## Herramienta utilizada

**Claude Sonnet 4.6** (Anthropic), accedido a través de **Claude Code** — interfaz de línea de comandos para asistencia en ingeniería de software.

---

## Alcance del uso

La IA participó activamente en las siguientes etapas del desarrollo:

### 1. Implementación del simulador HTML (`index.html`)
- Estructuración del documento HTML con las 5 pestañas (Propelente y grano, Casing y tobera, Resultados, Viabilidad, Tabla completa)
- Implementación del motor de simulación en JavaScript, incluyendo:
  - Modelo de presión de cámara: `Pc = (ρp · a · c* · Kn)^(1/(1-n))`
  - Ley de Saint-Robert: `r_b = a · Pc^n`
  - Cálculo de empuje, Isp e impulso total
  - Seis geometrías de grano (Bates, tubular, end-burner, estrella, finocyl, C-slot)
- Implementación del análisis de viabilidad con 8 criterios automáticos
- Diseño del sistema de sliders sincronizados con inputs numéricos editables
- Exportación a CSV y formato `.eng` (OpenRocket / RASAero)
- Calculadora de tensión de fluencia Sy (3 métodos: datasheet, hidrostático, desde Su)
- Sistema de clasificación Tripoli/NAR (clases A–L+)

### 2. Port a Flutter (`flutter_app/`)
- Creación del proyecto Flutter desde cero (`flutter create`)
- Port completo de la lógica de simulación de JavaScript a Dart (`simulation_engine.dart`)
- Diseño de la arquitectura de widgets: `SliderField`, `MetricCard`, `StatusBadge`, `SrmSection`
- Implementación de las 5 pestañas como widgets independientes
- Integración de gráficas con el paquete `fl_chart`
- Sistema de exportación de archivos a `~/Downloads`
- Resolución de conflictos de dependencias nativas (JNI / snap de Flutter)
- Compilación y verificación del build para Linux

### 3. Documentación y mantenimiento
- Redacción del `README.md` con instrucciones para ambas versiones
- Creación de este documento (`AI_USAGE.md`)
- Revisión y corrección de texto en la interfaz (español técnico)
- Gestión de commits y publicación en GitHub

---

## Rol del desarrollador humano

**Justin G. Alfaro Araya** — SpaceLabs ITCR — aportó:

- **Diseño del sistema:** definición de los parámetros físicos, propelentes, materiales y geometrías a modelar
- **Fundamento teórico:** conocimiento de propulsión sólida (ley de Saint-Robert, fórmula de Barlow, teoría de flujo en toberas)
- **Motor de referencia:** datos experimentales reales del motor KNSU/PVC SDR26 1½" (MD-2026-001 Rev. B)
- **Criterios de viabilidad:** definición de los rangos aceptables de Kn, FS, tiempos de combustión y criterios de seguridad
- **Revisión y validación:** verificación de que los resultados del simulador son físicamente coherentes con datos experimentales conocidos
- **Decisiones de diseño:** elección del stack tecnológico (HTML puro + Flutter), estructura de pestañas, parámetros predeterminados y flujo de uso
- **Dirección del proyecto:** todas las instrucciones, correcciones y prioridades fueron definidas por el desarrollador

---

## Verificación de resultados

Los valores producidos por el simulador fueron comparados contra datos conocidos del motor de referencia MD-2026-001 Rev. B. La validación final de la exactitud física es responsabilidad del desarrollador humano.

---

## Fecha

Desarrollo realizado el **9 de abril de 2026**.
