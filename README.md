# Simulador de Motor Cohete de Propelente Sólido

**SpaceLabs · ITCR · Costa Rica**

Simulador interactivo de motores cohete de propelente sólido, desarrollado en el marco del proyecto de cohetería experimental del Instituto Tecnológico de Costa Rica.

## Demo

Abrir `index.html` en cualquier navegador moderno. No requiere instalación ni servidor.

## Características

- **Propelentes:** KNSU, KNDX, KNMX, KNER, APCP estándar, APCP rápido, parámetros personalizados
- **Geometrías de grano:** Bates, tubular, end-burner, estrella (star grain), finocyl, C-slot
- **Tobera:** Dt, De, semiángulo divergente configurables
- **Casing:** presión de rating con alerta visual de seguridad
- **Gráficas en tiempo real:** F(t), P(t), Isp(t)
- **Tabla completa:** t, F, P, Isp, r_b, Ab, Kn, It acumulado por paso de tiempo
- **Exportación:** CSV completo y formato `.eng` compatible con OpenRocket y RASAero
- **Clasificación automática** Tripoli / NAR (A–L+)

## Parámetros del motor de referencia

Motor KNSU / PVC SDR26 1½" — Prototipo 1 — Clase I

| Parámetro | Valor |
|---|---|
| Propelente | KNSU (KNO₃ + sacarosa) |
| Casing | PVC SDR26 1½" (OD=48mm, ID=44.31mm) |
| Grano | Bates 3×80mm, OD=42.31mm, core=12mm |
| Garganta | Tuerca 1/2"-13 UNC, Dt=10.92mm |
| Salida tobera | De=19mm, Ae/At=3.03 |
| Pc diseño | 0.691 MPa (100 PSI) |
| Empuje | ~87 N |
| Tiempo comb. | ~4.6 s |
| Impulso total | ~404 N·s |
| Clase | I (Tripoli/NAR) |

## Fundamento teórico

Basado en la teoría de [Richard Nakka](https://www.nakka-rocketry.net):

- Modelo de equilibrio de presión de cámara: `Pc = (ρp · a · c* · Kn)^(1/(1-n))`
- Tasa de combustión: `r_b = a · Pc^n` (ley de Saint-Robert)
- Empuje: `F = CF · Pc · At`
- Impulso total: `It = ∫F dt`
- Isp: `Isp = F / (ṁ · g₀)`

## Uso

1. Abrir `index.html` en el navegador
2. Seleccionar propelente y geometría de grano
3. Ajustar parámetros con los sliders
4. Ver resultados en tiempo real en la pestaña **Resultados**
5. Exportar datos en CSV o formato `.eng` para OpenRocket

## Licencia

MIT License — libre uso, modificación y distribución con atribución.

## Créditos

- Teoría: Richard Nakka (*Solid Propellant Rocket Motor Theory*)
- Desarrollo: Justin G. Alfaro Araya — SpaceLabs ITCR
- Motor de referencia: MD-2026-001 Rev. B
