# Modelo de Hábitat de Krill Antártico (FAE 2026)

Este repositorio contiene la implementación del modelo **Hurdle** para la distribución de *Euphausia superba* en la subárea CCAMLR 48.1.

## Documentación Científica y EDA
- [**Análisis Exploratorio (EDA) y Justificación del Modelo**](EDA_Y_JUSTIFICACION_MODELO.md): Explicación detallada de la lógica científica, selección de variables e interpretación de resultados.

## Estructura del Proyecto
- data/: Datasets utilizados (Krillbase, GEBCO, Hielo, SAM, Fotoperiodo) y el **Master Join Final**.
- scripts/: Código en R para la unificación de datos y el entrenamiento del modelo.
- models/: Modelos entrenados en formato .rds.
- docs/: Reportes de diagnóstico, efectos parciales y gráficos de evidencia visual.
- papers/: Literatura científica base (Freer 2025, Ryabov 2023).

## Parte 1: Modelo Binomial (Presencia/Ausencia)
Se utiliza un **GAM (Generalized Additive Model)** para capturar las respuestas no lineales del krill ante predictores estructurales y ambientales.

- **AUC-ROC logrado:** 0.9396
- **Predictores clave:** Distancia al talud, Anomalía de hielo invernal previo, Índice SAM.

## Próximamente
- Parte 2: Modelo de Abundancia (XGBoost/GAM Gaussiano).
