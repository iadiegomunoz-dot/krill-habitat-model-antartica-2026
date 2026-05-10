# Análisis Exploratorio (EDA) y Justificación Científica

Este documento detalla la lógica científica, el análisis de datos y la interpretación de resultados que fundamentan la elección del modelo **Hurdle (GAM + XGBoost)** para el krill antártico.

---

## 1. Justificación del Modelo Hurdle
La distribución del krill (*Euphausia superba*) presenta dos desafíos estadísticos mayores:
1.  **Inflación de Ceros:** El ~22% de los muestreos no registran presencia de krill.
2.  **Agregación Extrema:** Cuando está presente, su densidad puede variar en varios órdenes de magnitud (enjambres).

**Solución:** Separar el proceso en dos etapas:
*   **Etapa 1 (Binomial GAM):** Predice la *probabilidad de presencia* (Idoneidad del hábitat). Captura umbrales físicos y climáticos.
*   **Etapa 2 (Abundancia):** Predice la *densidad* donde ya se confirmó la presencia. Captura pulsos de productividad biológica.

---

## 2. Selección de Variables y Lógica Ecológica

### A. Estructura Geofísica (GEBCO)
*   **Distancia al Talud continental (`dist_talud`):** El krill se concentra en la isobata de -500m. 
    *   *Evidencia:* Las visualizaciones muestran una "línea de vida" donde la presencia es casi constante a lo largo del quiebre de la plataforma.
*   **Pendiente y Profundidad:** Los cañones submarinos generan surgencias (upwelling) que concentran nutrientes y, por ende, krill.

### B. Restricciones Térmicas y Alimento (NASA)
*   **SST (Temperatura Superficial):** El análisis revela un **techo de idoneidad en los 2.0°C**. Superado este umbral, la probabilidad de encontrar krill cae drásticamente.
*   **Clorofila-a (`chl_final`):** Existe un umbral mínimo de arranque biológico (~0.12 mg/m³). Sin este "festín" de fitoplancton, el krill no permanece en la zona.

### C. Historia Climática (NSIDC / SAM)
*   **Anomalía de Hielo Invernal (Lag de Atkinson):** El éxito del reclutamiento de verano depende críticamente de la extensión de hielo del invierno previo. 
    *   *Interpretación:* El hielo protege a las larvas de los depredadores y les proporciona alimento (algas de hielo).
*   **Índice SAM:** Regula el transporte de masas de agua y biomasa desde el Mar de Weddell hacia la Península.

---

## 3. Interpretación de Gráficos de Evidencia

### 📈 Tolerancia Térmica (SST vs. Presencia)
*   **Qué vemos:** Una bimodalidad en la presencia. Dos picos de densidad: uno en el frío extremo (~0.5°C) y otro en aguas de plataforma (~1.2°C).
*   **Conclusión:** La temperatura actúa como un filtro de exclusión. Después de los 2°C, el hábitat deja de ser idóneo.

### 📉 Efecto Comida (Clorofila vs. Presencia)
*   **Qué vemos:** Un "salto" en la probabilidad de presencia una vez que la clorofila supera niveles basales.
*   **Conclusión:** La clorofila es el "combustible" del modelo de abundancia, pero también un validador de presencia en primavera.

### 📉 El Lag de Atkinson (Hielo previo vs. Krill)
*   **Qué vemos:** Una correlación significativa (R = -0.35 en la Subárea 48.1) entre el hielo del invierno pasado y la biomasa actual.
*   **Conclusión:** El modelo debe tener "memoria" temporal para ser preciso.

---

## 4. Conclusiones del Modelo Binomial (V1)
El primer componente del Hurdle (GAM) alcanzó un **AUC-ROC de 0.9396**, lo cual es excepcionalmente alto.

**Interpretación de Resultados:**
1.  **Altísima Significancia del Hielo:** La anomalía del invierno previo es el predictor dinámico más fuerte.
2.  **Influencia del SAM:** Confirmamos que el Modo Anular del Sur dicta la llegada de nuevas poblaciones a la Península.
3.  **Efecto Espacial:** El suavizado (tensor product) de Latitud/Longitud indica que existen factores de transporte (corrientes) que complementan la geofísica pura.

---
*Este análisis asegura que el modelo no sea una "caja negra", sino una representación fiel de la oceanografía biológica antártica.*
