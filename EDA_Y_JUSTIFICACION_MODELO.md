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

## 3. Interpretación Detallada de Gráficos de Evidencia

### 📈 Evidencia Térmica (`evidencia_termica_krill.png`)
*   **Análisis:** Este gráfico muestra la distribución de la Temperatura Superficial del Mar (SST) comparando sitios con presencia y ausencia de krill.
*   **Interpretación:** Se observa un claro "techo térmico". Mientras que las ausencias se distribuyen en un rango amplio de temperaturas, las presencias se concentran masivamente por debajo de los **2.0°C**. Existe un pico de idoneidad cerca de los **0.5°C**, asociado al borde del hielo.
*   **Conclusión para el Modelo:** La SST no es solo una variable continua, sino un **umbral crítico**. El modelo binomial utiliza este predictor para descartar áreas que, aunque tengan alimento, son térmicamente hostiles para el krill.

### 📈 Evidencia de Alimento (`evidencia_comida_krill.png` y `distribucion_comida_krill.png`)
*   **Análisis:** Estos gráficos relacionan la concentración de Clorofila-a con la densidad y presencia de krill.
*   **Interpretación:** Se detecta un **umbral de arranque biológico (~0.12 mg/m³)**. Por debajo de este nivel, los encuentros con krill son esporádicos. La "distribución de comida" muestra que el krill tiende a seguir los filamentos de alta productividad que se desprenden de la costa.
*   **Conclusión para el Modelo:** La clorofila valida la presencia. En el modelo binomial, asegura que las zonas de "desierto biológico" tengan una baja probabilidad de hábitat idóneo, incluso si son frías.

### 📈 El Lag de Atkinson (`evidencia_lag_hielo_krill.png`)
*   **Análisis:** Correlación entre la anomalía de la extensión de hielo marino en invierno (año *n-1*) y la abundancia de krill en verano (año *n*).
*   **Interpretación:** El gráfico confirma una correlación positiva significativa. Años con inviernos rigurosos y gran extensión de hielo preceden a veranos con alta biomasa. Esto se debe a que el hielo actúa como guardería y fuente de alimento (diatomeas de hielo) para las larvas de krill.
*   **Conclusión para el Modelo:** Es el predictor dinámico más potente. Sin este "lag", el modelo perdería su capacidad de capturar la variabilidad interanual del reclutamiento.

### 📈 Evidencia del Talud y Profundidad (`evidencia_talud_krill.png`)
*   **Análisis:** Muestra la densidad de krill en relación con la distancia a la isobata de -500m y la profundidad absoluta.
*   **Interpretación:** La profundidad es una variable fundamental; el krill de la Península es un habitante de plataforma y talud. El gráfico muestra una **agregación masiva a menos de 50km del quiebre del talud continental**. A profundidades mayores a 2000m (océano abierto), la probabilidad de encontrar grandes densidades disminuye drásticamente.
*   **Conclusión para el Modelo:** La profundidad y la distancia al talud son los "anclajes" espaciales del modelo. Definen la estructura básica del hábitat donde todas las demás variables dinámicas operan.

---

## 4. Conclusiones del Modelo Binomial (V1)
El primer componente del Hurdle (GAM) alcanzó un **AUC-ROC de 0.9396**, lo cual es excepcionalmente alto.

**Interpretación de Resultados del Modelo:**
1.  **Altísima Significancia del Hielo:** La anomalía del invierno previo es el predictor dinámico más fuerte.
2.  **Influencia del SAM:** Confirmamos que el Modo Anular del Sur dicta la llegada de nuevas poblaciones a la Península.
3.  **Importancia de la Profundidad:** El modelo confirmó que la batimetría de GEBCO es el predictor estático más robusto, superando incluso a la pendiente simple.
4.  **Efecto Espacial:** El suavizado (tensor product) de Latitud/Longitud indica que existen factores de transporte (corrientes) que complementan la geofísica pura.


---
*Este análisis asegura que el modelo no sea una "caja negra", sino una representación fiel de la oceanografía biológica antártica.*
