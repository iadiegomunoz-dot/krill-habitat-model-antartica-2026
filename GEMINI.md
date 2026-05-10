# Instrucciones del Proyecto: Modelado de Krill Antártico (FAE 2026)

Este archivo contiene los mandatos arquitectónicos y científicos obligatorios para este repositorio.

## 1. Arquitectura del Modelo
- **Modelo:** Hurdle de dos partes.
- **Parte 1 (Binomial):** Clasificador de Presencia/Ausencia (GAM - Modelos Aditivos Generalizados).
- **Parte 2 (Abundancia):** Estimador de Densidad (XGBoost / GAM Gaussiano).

## 2. Protocolo del Modelo Binomial
Para la predicción de idoneidad de hábitat (Presencia 0/1), se deben utilizar las siguientes variables:

### Predictores Estructurales (GEBCO 2026)
- `dist_talud`: Distancia geodésica a la isobata de -500m (Predictor #1).
- `slope`: Pendiente batimétrica en grados.
- `profundidad`: Profundidad absoluta del fondo marino.

### Predictores Ambientales (NASA / CMEMS)
- `sst`: Temperatura superficial (Resolución 0.1°C).
- `salinity`: Salinidad de CMEMS (Mesoescala).
- `climatology_chl`: Promedio histórico mensual de Clorofila-a (NASA).
- `photoperiod`: Horas de luz solar para mitigar el sesgo de la noche polar.

### Predictores Climáticos (NSIDC / NOAA)
- `ice_anomaly_lag`: Anomalía de hielo del invierno previo (Jul-Sep).
- `sam_index`: Índice del Modo Anular del Sur (rolling 9m).

## 3. Mandatos Científicos
- **Validación:** Se prohíbe el shuffle aleatorio. Se debe usar un **Split Temporal** (Entrenar hasta 2012, Validar 2013-2016).
- **Tratamiento de Invierno:** No imputar ceros a la clorofila ciegamente. Usar la Climatología + Fotoperiodo para explicar la ausencia de datos satelitales.
- **Referencias de Oro:** Atkinson et al. (2004/2008), Ryabov et al. (2023), Freer et al. (2025).

## 4. Documentación Relacionada
- `METODOLOGIA_PROCESAMIENTO.md`: Detalle técnico de la ingeniería de variables.
- `CONCLUSION_EVIDENCIA_CIENTIFICA.md`: Síntesis de las pruebas visuales y estadísticas.
- `PROTOCOLO_MODELO_BINOMIAL.md`: Paso a paso del entrenamiento.
