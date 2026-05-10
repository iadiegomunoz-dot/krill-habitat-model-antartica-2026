# Modelo de Hábitat de Krill Antártico (FAE 2026)

Este repositorio contiene la implementación del modelo **Hurdle** para la distribución de *Euphausia superba* en la subárea CCAMLR 48.1.

## Estructura del Proyecto
- `data/`: Datasets utilizados (Krillbase, GEBCO, Hielo, SAM, Fotoperiodo) y el **Master Join Final**.
- `scripts/`: Código en R para la unificación de datos y el entrenamiento del modelo.
- `models/`: Modelos entrenados en formato `.rds`.
- `docs/`: Reportes de diagnóstico y efectos parciales.
- `papers/`: Literatura científica base (Freer 2025, Ryabov 2023).

## Parte 1: Modelo Binomial (Presencia/Ausencia)
Se utiliza un **GAM (Generalized Additive Model)** para capturar las respuestas no lineales del krill ante predictores estructurales y ambientales.

- **AUC-ROC logrado:** 0.9396
- **Predictores clave:** Distancia al talud, Anomalía de hielo invernal previo, Índice SAM.

## Próximamente
- Parte 2: Modelo de Abundancia (XGBoost/GAM Gaussiano).
