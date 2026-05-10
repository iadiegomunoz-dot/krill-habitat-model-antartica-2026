# Protocolo de Implementación: Modelo Binomial (Parte 1 - Hurdle)

Este documento detalla el paso a paso técnico y científico para la creación del modelo de **Presencia/Ausencia** de krill antártico.

---

## 1. Preparación del Dataset Maestro (The Master Join)

El éxito del modelo depende de la precisión de la unión entre la biología y el ambiente.

### Paso 1.1: Transformación de la Variable Y
*   **Acción:** Convertir `STANDARDISED_KRILL_UNDER_1M2` de Krillbase en una variable binaria (`Presence`).
    *   Si `valor > 0` → **1** (Presencia)
    *   Si `valor == 0` → **0** (Ausencia)
*   **Justificación:** El krill presenta una distribución altamente agregada. El modelo Hurdle requiere primero superar el "obstáculo" de la presencia antes de estimar la densidad (**Freer et al. 2025**).

### Paso 1.2: Cruce Espacial (GEBCO)
*   **Acción:** Usar las coordenadas (`lat`, `lon`) de Krillbase para extraer los valores de `distancia_talud`, `slope` y `depth` de nuestros archivos NetCDF procesados.
*   **Técnica:** Interpolación de vecino más cercano hacia nuestra grilla de 0.25°.

### Paso 1.3: Cruce Temporal (NASA / NSIDC / Clima)
*   **Acción:** Vincular cada registro de Krillbase con el mes y año correspondiente de las variables dinámicas.
*   **Variables:** SST, Clorofila (NASA), Anomalía de Hielo (NSIDC), SAM y ENSO.
*   **Manejo del "Corte" de Clorofila:** Para los meses de invierno (Mayo-Agosto), se imputará un valor basal mínimo (0.01 mg/m³) para evitar la pérdida de registros por el artefacto instrumental de la noche polar.

---

## 2. Configuración del Modelo GAM (Generalized Additive Model)

Utilizaremos un GAM para capturar las respuestas no lineales del krill.

### Fórmula del Modelo:
`Presence ~ s(dist_talud) + s(slope) + s(sst) + s(ice_anomaly) + s(month) + s(lat, lon)`

### Justificación de Predictores:
1.  **`s(dist_talud)`:** Captura la agregación en el borde de la plataforma continental (**Freer 2025**).
2.  **`s(ice_anomaly)`:** Integra la "Hipótesis del Hielo" de **Atkinson (2004)**, donde el reclutamiento depende del éxito del invierno previo.
3.  **`s(sst)`:** Define los límites de tolerancia térmica metabólica.
4.  **`s(lat, lon)`:** Un suavizado espacial (tensor product) para capturar el sesgo geográfico y factores no medidos (corrientes) que el modelo deba compensar (**Amaral et al. 2025**).

---

## 3. Entrenamiento y Validación

### Paso 3.1: División de Datos (Split)
*   **Regla:** NO usaremos un shuffle aleatorio simple. Usaremos un **Split Temporal/Espacial**.
*   **Técnica:** Entrenar con datos hasta 2012 y validar con el periodo 2013-2016.
*   **Justificación:** Evita la autocorrelación temporal; el modelo debe ser capaz de predecir el futuro, no solo de memorizar el pasado (**Ryabov 2023**).

### Paso 3.2: Métricas de Éxito
1.  **AUC-ROC:** Meta > 0.75 para considerar el modelo "científicamente útil".
2.  **Curvas de Respuesta (Partial Effects):** Validación visual de que las curvas tienen sentido biológico (ej: que la probabilidad de krill baje cuando la distancia al talud es muy grande).

---

## 4. Mitigación de Sesgos Identificados

1.  **Sesgo de Muestreo:** Se aplicará una máscara de "Área de Aplicabilidad" para que el modelo no genere predicciones de alta confianza en el cuadrante noreste desprovisto de datos.
2.  **Pesca Comercial:** Se cruzará el resultado con datos de esfuerzo pesquero (CCAMLR) en la fase de validación para verificar si las ausencias detectadas coinciden con zonas de alta extracción humana.

---
*Este protocolo asegura que el modelo binomial sea una representación fiel de la dinámica antártica y no solo un ejercicio estadístico.*
