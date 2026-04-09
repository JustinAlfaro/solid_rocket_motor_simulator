# Simulador de Motor Cohete de Propelente Sólido

**SpaceLabs · ITCR · Costa Rica**

Simulador interactivo de motores cohete de propelente sólido, desarrollado en el marco del proyecto de cohetería experimental del Instituto Tecnológico de Costa Rica.

Disponible en dos versiones: **HTML** (sin instalación, abre en el navegador) y **Flutter** (app nativa para Linux, Windows, macOS, Android e iOS).

---

## Versión HTML

### Requisitos

Ninguno. Solo un navegador moderno (Chrome, Firefox, Edge, Safari).

### Cómo ejecutar

1. Descargar o clonar el repositorio.
2. Hacer doble clic en `index.html`.

No requiere servidor, instalación ni conexión a internet (excepto para cargar Chart.js desde CDN la primera vez).

---

## Versión Flutter

### Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — versión estable ≥ 3.x
- En Linux, las siguientes dependencias del sistema:
  ```bash
  sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
  ```

> En Ubuntu/Debian, Flutter puede instalarse vía Snap:
> ```bash
> sudo snap install flutter --classic
> ```
> El SDK se descarga la primera vez que se ejecuta `flutter` (~1.4 GB).

### Cómo ejecutar en modo desarrollo

```bash
cd flutter_app
flutter run -d linux      # Linux
flutter run -d windows    # Windows
flutter run -d macos      # macOS
flutter run               # Android o iOS (requiere dispositivo/emulador conectado)
```

> Si Flutter fue instalado con Snap, usar la ruta completa:
> ```bash
> ~/snap/flutter/common/flutter/bin/flutter run -d linux
> ```

### Compilar ejecutable (release)

```bash
cd flutter_app
flutter build linux --release
```

El binario queda en `flutter_app/build/linux/x64/release/bundle/srm_simulator`.  
Para ejecutarlo directamente:

```bash
./build/linux/x64/release/bundle/srm_simulator
```

---

## Características

- **Propelentes:** KNSU, KNDX, KNMX, KNER, APCP estándar, APCP rápido, parámetros personalizados
- **Geometrías de grano:** Bates, tubular, end-burner, estrella (star grain), finocyl, C-slot
- **Casing:** cálculo de P_burst y MEOP con fórmula de Barlow; 11 materiales predefinidos + personalizado; calculadora de Sy (datasheet, hidrostático o desde Su)
- **Tobera:** Dt, De y semiángulo divergente configurables
- **Resultados en tiempo real:** empuje, presión de cámara, Isp, tiempo de combustión, clase Tripoli/NAR
- **Gráficas:** F(t), P(t) e Isp(t)
- **Análisis de viabilidad:** 8 criterios automáticos con veredicto VIABLE / NO VIABLE / VIABLE CON ADVERTENCIAS
- **Tabla completa:** t, F, P, Isp, r_b, Ab, Kn, It acumulado por paso de tiempo
- **Exportación:** CSV completo y formato `.eng` compatible con OpenRocket y RASAero
- **Clasificación automática** Tripoli/NAR (A–L+)

---

## Motor de referencia

Motor KNSU / PVC SDR26 1½" — Prototipo 1 — Clase I (MD-2026-001 Rev. B)

| Parámetro | Valor |
|---|---|
| Propelente | KNSU (KNO₃ + sacarosa) |
| Casing | PVC SDR26 1½" (OD = 48 mm, ID = 44.31 mm) |
| Grano | Bates 3 × 80 mm, OD = 42.31 mm, core = 12 mm |
| Garganta | Dt = 10.92 mm |
| Salida tobera | De = 19 mm, Ae/At = 3.03 |
| Pc diseño | 0.691 MPa (100 PSI) |
| Empuje nominal | ~87 N |
| Tiempo de combustión | ~4.6 s |
| Impulso total | ~404 N·s |
| Clase | I (Tripoli/NAR) |

---

## Fundamento teórico

- Presión de cámara: `Pc = (ρp · a · c* · Kn)^(1/(1-n))`
- Tasa de combustión (ley de Saint-Robert): `r_b = a · Pc^n`
- Empuje: `F = CF · Pc · At`
- Impulso total: `It = ∫F dt`
- Impulso específico: `Isp = F / (ṁ · g₀)`
- Presión de rotura del casing (fórmula de Barlow): `P_burst = 2·Sy·t / OD`

---

## Referencias bibliográficas

[1] R. Nakka, *Teoría sobre motores cohete de propelente sólido*, trad. S. Garofalo.

[2] D. T. Harrje y F. H. Reardon (eds.), *Liquid Propellant Rocket Combustion Instability*, NASA SP-194, NASA, Washington D.C., 1972.

[3] *Solid Rocket Motor Performance Analysis and Prediction*, NASA.

---

## Licencia

MIT License — libre uso, modificación y distribución con atribución.

## Créditos

Desarrollo: Justin G. Alfaro Araya — SpaceLabs ITCR
