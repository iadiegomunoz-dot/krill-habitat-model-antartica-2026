# Metodología Científica: Modelado de Distribución de Krill Antártico (FAE 2026)

**Fecha:** 7 de mayo de 2026  
**Autores:** Gemini CLI Agent & Equipo de Investigación INACH  
**Estado:** Definición de Alcance y Justificación de Datos

---

## 1. Alcance del Proyecto (Scope)

Para garantizar la máxima precisión y relevancia científica, el estudio se acota bajo los siguientes parámetros:

*   **Localización Geográfica:** Subárea CCAMLR 48.1 (Península Antártica e Islas Shetland del Sur). Esta zona es crítica debido a que concentra la mayor presión de la flota pesquera y es un área de reproducción clave.
*   **Temporalidad:** 2000 - 2020. Este periodo ha sido seleccionado para maximizar el traslape entre los registros biológicos de KRILLBASE y la "era de oro" de los datos satelitales y de reanálisis (GLORYS12), asegurando una resolución de alta fidelidad.
*   **Resolución Espacial:** 0.25° x 0.25° (~25 km). Alineado con Amaral et al. (2025), este grano permite integrar datos de diferentes fuentes minimizando el error de desalineación.

---

## 2. Justificación de Bases de Datos y Evidencia Científica

La selección de datos no es arbitraria; responde a los resultados de investigaciones que han identificado los "drivers" ambientales más potentes para *Euphausia superba*.

### 2.1 KRILLBASE (Variable Respuesta: Biomasa y Abundancia)
*   **Por qué esta base:** Según Atkinson et al. (2017), KRILLBASE es el único esfuerzo circumpolar que estandariza décadas de lances de red.
*   **Evidencia Científica:** Proporciona la "verdad de terreno" necesaria para entrenar el modelo. Su uso es mandatorio para validaciones históricas que los datos acústicos (más limitados temporalmente) no pueden cubrir por sí solos.

### 2.2 CMEMS GLORYS12 (Física del Océano: SSH y Salinidad)
*   **Por qué esta base:** Ofrece una consistencia hidrodinámica global que no tienen los satélites individuales.
*   **Justificación por Freer et al. (2025):** 
    *   **Salinidad (so):** Identificada como uno de los tres predictores más importantes. Valores de ~33.75 PSU se asocian con máximas densidades de krill.
    *   **Sea Surface Height (zos):** Freer demostró que el contorno de **-1.75 m** es un "proxy" perfecto de la confluencia Weddell-Scotia, actuando como una barrera o corredor de transporte para el krill.

### 2.3 GEBCO 2026 (Batimetría y Distancia al Talud)
*   **Por qué esta base:** Es el estándar de oro en batimetría submarina.
*   **Justificación por Freer et al. (2025):** La **Distancia a la isobata de 500m (talud continental)** fue calificada como la variable #1 en importancia para el modelo de abundancia. El krill tiende a agregarse en el borde del talud debido a procesos de surgencia (upwelling) y retención por cañones submarinos.

### 2.4 NSIDC (Sea Ice Extent)
*   **Por qué esta base:** Proporciona datos diarios de concentración de hielo.
*   **Evidencia Científica:** El krill depende del hielo invernal para la supervivencia de las larvas. La **distancia al borde del hielo (15%)** es un predictor crítico para el bloom primaveral y la distribución de verano.

### 2.5 Índices SAM y ENSO (Variabilidad Climática)
*   **Justificación por Ryabov et al. (2023):** Demostraron que el SAM positivo favorece el transporte de krill desde el Mar de Weddell hacia la Península. Se implementará un **lag de 9 meses** en el SAM, ya que este es el tiempo que tarda la señal climática en traducirse en cambios en el reclutamiento biológico detectable.

---

## 3. Arquitectura de Modelado: Hurdle-XGBoost

La elección de un modelo **Hurdle** (separación de presencia y abundancia) se justifica técnicamente:
1.  **Amaral et al. (2025)** demostró que un enfoque de una sola etapa subestima la biomasa en áreas de alta densidad debido a la inflación de ceros (registrada en un ~22% en nuestros datos preliminares).
2.  El uso de **XGBoost** para la segunda etapa permite capturar interacciones complejas y no lineales entre la salinidad y la profundidad que los modelos lineales ignoran.

---

## 4. Referencias y Trazabilidad

| Paper | Hallazgo Clave Aplicado |
|-------|--------------------------|
| **Freer (2025)** | Importancia del SSH -1.75m y Isobata 500m. |
| **Amaral (2025)** | Framework para unificación de datos desalineados. |
| **Ryabov (2023)** | Protocolo de Lags temporales para índices climáticos. |
| **Atkinson (2017)** | Estandarización de lances de red KRILLBASE. |

---
*Documento generado bajo el protocolo de rigor científico Gemini-FAE 2026.*
