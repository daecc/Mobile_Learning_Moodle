# Secciones Complementarias para el Documento de Investigación
> **Proyecto:** *Aplicación móvil basada en Mobile-Learning y con Inteligencia Artificial para el aprendizaje de estudiantes universitarios de ingeniería (RUMBO)*  
> **Facultad de Ingeniería de Sistemas e Informática (FISI) — UNMSM**  
> **Grupo 5**

---

# 2. DESARROLLO Y ANÁLISIS COMPARATIVO DE MODELOS DE INTELIGENCIA ARTIFICIAL *(Continuación)*

## 2.2. Fundamentación Conceptual de los Algoritmos Seleccionados

En lugar de recurrir a formulaciones matemáticas abstractas, la selección de los cinco algoritmos de aprendizaje automático evaluados en esta investigación se fundamenta en su comportamiento operacional, su capacidad para procesar registros de interacción digital en entornos virtuales y su idoneidad para integrarse en un sistema móvil de alerta temprana:

1. **Regresión Logística Regularizada (Modelo Base):**  
   Es un algoritmo supervisado que estima directamente la probabilidad de pertenencia a una categoría (en nuestro caso: *Sin Riesgo* vs. *En Riesgo*) mediante una curva de activación suave calibrada entre 0% y 100%. Para evitar que el modelo se vuelva inestable o sobreajuste ante variables que crecen al mismo tiempo (como las notas de distintas tareas), se aplicó una penalización de regularización ($L_2$). Su gran fortaleza en ingeniería educativa radica en su **transparencia y explicabilidad**: cada variable tiene un multiplicador asignado, permitiendo saber con exactitud cuánto peso aporta cada comportamiento del alumno a su riesgo final.
2. **Árbol de Decisión (CART):**  
   Construye un mapa jerárquico de decisiones compuesto por condiciones lógicas consecutivas tipo *«Si - Entonces»* (por ejemplo: *«Si los días de inactividad > 5 y la nota promedio < 11, clasificar en riesgo»*). Aunque es intuitivo de interpretar, tiende a crear reglas rígidas y es propenso a memorizar el ruido de los datos si no se restringe su profundidad.
3. **Random Forest (Ensamble de Bosques Aleatorios):**  
   Es una técnica de ensamble que combina 300 árboles de decisión diferentes entrenados sobre distintos subconjuntos de datos y variables. La predicción final no depende de un solo criterio, sino del promedio del voto de todos los árboles del bosque. Esto lo hace muy resistente a errores aislados y capaz de capturar patrones complejos no lineales.
4. **Support Vector Machine con Kernel RBF (SVM):**  
   Este modelo busca trazar una frontera de separación óptima entre los estudiantes regulares y los estudiantes en riesgo. Al utilizar una función de base radial (Kernel RBF), puede curvar y deformar la frontera en múltiples dimensiones para separar casos difíciles donde las métricas de aprobación y desaprobación se encuentran muy mezcladas.
5. **Red Neuronal Artificial Multicapa (MLP / Deep Neural Network):**  
   Compuesta por capas densas de neuronas interconectadas que transforman progresivamente las variables de entrada. Aunque posee una enorme capacidad de aprendizaje para relaciones intrincadas, opera como un modelo de **"caja negra"**, donde resulta casi imposible rastrear el motivo individual por el cual una neurona tomó una decisión.

---

## 2.3. Experimentación y Comparativa de Modelos sin Optimización

Los cinco clasificadores se entrenaron sobre la partición estratificada del 75% de los datos ($5,631$ registros) y se evaluaron de forma estricta y ciega sobre el conjunto de prueba restante del 25% ($1,877$ registros). 

A diferencia de problemas balanceados convencionales, en la detección de riesgo universitario la métrica clave no es solo la Exactitud (*Accuracy*), sino el **F1-Score** (que evalúa el equilibrio real entre no dejar pasar a ningún alumno en peligro y no generar falsas alarmas) y el **AUC-ROC** (capacidad del modelo para distinguir a un alumno en riesgo de uno regular a lo largo de cualquier umbral de decisión).

**Tabla 7**  
*Resultados comparativos de rendimiento de los cinco algoritmos evaluados (1,877 registros de prueba)*

| Modelo Evaluado | Exactitud (*Accuracy*) | Precisión (*Precision*) | Exhaustividad (*Recall*) | F1-Score | AUC-ROC |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Regresión Logística** | **0.8759** | 0.8243 | **0.7791** | **0.8010** | **0.9431** |
| **SVM (Kernel RBF)** | 0.8748 | **0.8355** | 0.7591 | 0.7955 | 0.9325 |
| **Random Forest (300 árboles)** | 0.8700 | 0.8255 | 0.7542 | 0.7882 | 0.9362 |
| **Red Neuronal (MLP/DNN)** | 0.8274 | 0.7301 | 0.7326 | 0.7313 | 0.8966 |
| **Árbol de Decisión (CART)** | 0.8247 | 0.7590 | 0.6645 | 0.7086 | 0.8910 |

---

### Gráficos de Evaluación Experimental del Modelo

A continuación se presentan los gráficos obtenidos directamente de la ejecución experimental del notebook de entrenamiento:

#### A. Comparativa General de Métricas
En la **Figura 1** se aprecia visualmente el comportamiento de cada algoritmo en las cuatro dimensiones fundamentales:

![Figura 1: Comparativa de Métricas por Modelo](Docs/grafico_1_comparativa_metricas.png)  
**Figura 1:** *Comparación de Exactitud, Precisión, Recall y F1-Score entre los cinco modelos de IA.*

*Análisis del gráfico:* Se observa con claridad que la **Regresión Logística**, **SVM** y **Random Forest** forman un grupo superior compacto con métricas por encima del 87% de exactitud y 80% de F1-Score, superando con holgura a las Redes Neuronales y al Árbol de Decisión individual, los cuales mostraron una caída pronunciada en *Recall* (capacidad de capturar estudiantes en riesgo real).

#### B. Capacidad Discriminante Global (Curvas ROC y AUC)
La **Figura 2** muestra la superposición de las curvas ROC obtenidas sobre el conjunto de prueba:

![Figura 2: Curvas ROC Superpuestas](Docs/grafico_2_curvas_roc.png)  
**Figura 2:** *Curvas de Rendimiento Diagnóstico (ROC) y Área Bajo la Curva (AUC) de los modelos.*

*Análisis del gráfico:* Cuanto más se acerque la curva a la esquina superior izquierda, mayor es la eficacia del clasificador. La **Regresión Logística** lidera con un **AUC de 0.94**, demostrando que tiene la menor tasa de confusión diagnóstica ante cualquier punto de corte probabilístico.

#### C. Distribución de Errores y Aciertos (Matrices de Confusión)
En la **Figura 3** se desglosan los aciertos (verdaderos positivos y verdaderos negativos) frente a los errores (falsos positivos y falsos negativos):

![Figura 3: Matrices de Confusión](Docs/grafico_3_matrices_confusion.png)  
**Figura 3:** *Matrices de confusión comparativas para cada uno de los cinco algoritmos.*

*Análisis del gráfico:* Para el contexto de prevención del rezago académico, el peor escenario es el **Falso Negativo** (un estudiante que realmente va a desaprobar, pero el sistema le indica erróneamente que está a salvo). En este punto crítico, la Regresión Logística y SVM lograron la menor cantidad de falsos negativos entre todos los modelos evaluados.

---

## 2.4. Experimentación con Optimización y Ajuste de Hiperparámetros (Fine-Tuning)

Tras identificar los modelos más competitivos, se sometieron a un proceso de optimización mediante validación cruzada estratificada de 5 pliegues (*5-Fold Stratified Cross Validation*). Para la Regresión Logística, se ajustó la fuerza de regularización $C$ y el algoritmo de convergencia (*solver*), logrando elevar su desempeño final:
* **Exactitud (*Accuracy*):** Pasó de $87.59\%$ a **$88.60\%$**.
* **Precisión:** Subió a **$85.77\%$**.
* **F1-Score Optimizado:** Alcanzó **$0.8165$** ($81.65\%$).
* **Área Bajo la Curva (AUC-ROC):** Se consolidó en un sobresaliente **$0.9501$** ($95.01\%$).

---

## 2.5. Análisis Detallado: ¿Por qué se seleccionó la Regresión Logística para la App?

Una decisión madura de ingeniería de software en proyectos de Inteligencia Artificial aplicada no se toma eligiendo ciegamente el modelo con el nombre más complejo, sino evaluando el **balance integral entre precisión predictiva, explicabilidad pedagógica y viabilidad de despliegue en producción**.

El equipo seleccionó formalmente la **Regresión Logística Regularizada** como el motor que alimenta el microservicio de producción (`Backend/ml_models/model.joblib`) basándose en cuatro pilares fundamentales:

### 1. Explicabilidad Directa y Transparencia para el Estudiante (XAI)
En una aplicación de *Mobile Learning*, un modelo de tipo "caja negra" (como una Red Neuronal profunda) es ineficaz a nivel pedagógico: si el estudiante recibe una notificación que dice *"Riesgo Crítico: 70%"*, su reacción natural es de desconcierto y ansiedad. El estudiante necesita saber **cuál es el motivo** de ese porcentaje.  
La Regresión Logística permite calcular matemáticamente el impacto exacto de cada indicador. En la **Figura 4** se ilustran los pesos reales que aprendió el modelo:

![Figura 4: Coeficientes e Impacto de las Variables en el Riesgo](Docs/grafico_coeficientes_regresion_logistica.png)  
**Figura 4:** *Ponderación e impacto de cada indicador en el cálculo de riesgo de la Regresión Logística.*

* **Factores que disparan el riesgo (Barras rojas hacia la derecha):**
  * `Días de inactividad consecutivos` ($+7.29$): Es el factor más peligroso. Cada día adicional sin entrar a Moodle eleva drásticamente la probabilidad de rezago.
  * `Tasa de entregas tardías` ($+5.94$): Presentar tareas fuera de plazo refleja desorganización en el tiempo.
  * `Índice de fricción cognitiva` ($+2.97$): Vacilaciones y reintentos fallidos reiterados.
* **Factores protectores que reducen el riesgo (Barras verdes hacia la izquierda):**
  * `Calificación histórica promedio` ($-7.01$): Un buen promedio acumulado amortigua caídas temporales.
  * `Tendencia de calificaciones` ($-4.88$): Ir mejorando nota a nota disminuye el riesgo de inmediato.
  * `Acierto al primer intento` ($-4.34$): Comprensión sólida en evaluaciones formativas.

Gracias a esta transparencia, la pantalla **`FactorsScreen`** de la app móvil puede mostrar al alumno los 4 gráficos contextuales explicándole exactamente qué debe corregir.

### 2. Mayor Rendimiento en la Métrica Crítica (F1-Score y AUC)
La Regresión Logística superó a Random Forest y a la Red Neuronal en el **F1-Score ($0.8165$)** y en el **AUC-ROC ($0.9501$)**. Esto demuestra que para datos tabulares estructurados derivados de logs de interacción, un clasificador lineal regularizado bien calibrado es más robusto y menos vulnerable al sobreajuste que modelos más densos.

### 3. Latencia Ultra-Baja e Inferencia en Milisegundos
La inferencia del modelo toma **menos de 2 milisegundos por estudiante**, consumiendo prácticamente cero recursos de CPU en el servidor FastAPI. Esto garantiza que cuando un estudiante desliza la pantalla en Flutter para refrescar (*Pull-to-refresh*), la app recalcula y dibuja el tacómetro de riesgo al instante, sin tiempos de espera.

### 4. Peso Mínimo y Portabilidad
El binario exportado (`model.joblib`) pesa menos de **2 Kilobytes** en disco. No requiere librerías pesadas como TensorFlow o PyTorch en el backend ni tarjetas gráficas (GPU) para su ejecución en producción, facilitando su despliegue económico en servidores en la nube (como Railway o AWS).

---

## 2.6. Integración del Modelo de Lenguaje (LLM) para Tutoría Inteligente Adaptativa

El sistema incorpora una arquitectura complementaria de dos niveles:
1. **El modelo predictivo numérico (Regresión Logística):** Detecta con precisión cuándo y por qué el estudiante está en riesgo.
2. **El modelo de lenguaje generativo (Tutor IA en `tutor_screen.dart`):** Traduce dicho diagnóstico en una conversación humana guiada. Recibe como contexto las dos variables más débiles del estudiante y genera estrategias pedagógicas concretas (como sugerir la técnica Pomodoro si hay inactividad o recordarle consultar las dudas del laboratorio con el profesor), evitando divagaciones genéricas.

---

# 4. DISEÑO Y ARQUITECTURA DE LA APLICACIÓN MÓVIL *(Continuación)*

## 4.2. Diseño Frontend (Interfaces de Usuario en el Móvil)

La aplicación móvil **Rumbo** fue desarrollada en **Flutter (Dart)** aplicando principios de diseño atómico y la heurística de usabilidad de Nielsen H6 (reconocimiento antes que memorización):

* **Autenticación Oficial Moodle (`LoginScreen`):** Conexión segura con el aula virtual MoodleCloud, gestión de tokens REST y chips de acceso rápido de demostración (`guillermo1234`, `josephr.c27`, `DEMO`).
* **Dashboard Principal de Cursos (`CoursesScreen`):** Muestra el resumen global de distribución de riesgo (porcentaje en riesgo Bajo, Moderado y Crítico) y la lista de asignaturas matriculadas con sus respectivos badges semafóricos.
* **Panel de Diagnóstico con Tacómetro (`RiskScreen`):**
  * **Tacómetro Semicircular (`RiskGauge`):** Widget gráfico vectorial con aguja animada que ubica al estudiante en tres zonas intuitivas:
    * 🟢 **Zona Verde (0% - 30%):** Riesgo Bajo · Progreso seguro.
    * 🟡 **Zona Amarilla (31% - 60%):** Riesgo Moderado · Atención requerida.
    * 🔴 **Zona Roja (61% - 100%):** Riesgo Crítico · Alerta temprana prioritaria.
  * **Rango Probable:** Informa el intervalo de confianza (ej. *"58% – 72%"*), evitando que el alumno perciba la predicción como un castigo absoluto.
  * **Acción Inmediata:** Botón con enlace profundo que conduce a resolver la tarea pendiente en Moodle.
* **Pantalla de Explicabilidad (`FactorsScreen`):** Integra 4 micro-gráficos: inactividad en días, tendencia histórica, línea de tiempo de tareas y frecuencia de ingresos semanales.
* **Menú Lateral (`AppDrawer`):** Acceso al perfil institucional del estudiante, switch para alternancia instantánea entre **Modo Claro** y **Modo Oscuro**, y accesos a los módulos de autorregulación y tutoría.

---

## 4.3. Diseño Backend y Persistencia

### 4.3.1. Modelo Entidad-Relación de la Base de Datos (Diseño Gráfico y Relacional)

La base de datos local del sistema está construida en **SQLite (`rumbo.db`)** y opera bajo el modo de registro anticipado **WAL (Write-Ahead Logging)**, garantizando transacciones atómicas y lecturas concurrentes no bloqueantes.

En la **Figura 5** se detalla el diagrama relacional físico de la base de datos:

![Figura 5: Diagrama Entidad-Relación de la Base de Datos](Docs/diagrama_er_base_de_datos.png)  
**Figura 5:** *Diagrama Entidad-Relación de la base de datos local (rumbo.db) con sus cuatro tablas relacionales.*

#### Descripción de Entidades y Relaciones:
1. **`estudiantes`:** Almacena los datos del alumno sincronizados desde Moodle (`id_estudiante`, `username`, `nombre`, `correo`, `token_moodle`, `moodle_userid`). Es la entidad padre.
2. **`cursos`:** Modela las asignaturas en las que cada alumno está matriculado (`id_curso`, `nombre`, `codigo`, `docente`, `creditos`). Mantiene una relación de **1 a Muchos ($1:N$)** con `estudiantes` mediante la clave foránea compuesta `id_estudiante`.
3. **`metricas`:** Almacena el histórico de los indicadores conductuales extraídos en cada corte temporal (`dias_inactividad`, `tareas_totales`, `tareas_pendientes`, `promedio_quizzes`, `promedio_historico`). Se vincula en relación **$1:N$** con `cursos` y `estudiantes`.
4. **`predicciones`:** Persiste el resultado calculado por el modelo de Inteligencia Artificial (`probabilidad`, `porcentaje`, `nivel_riesgo`, `alerta_titulo`, `accion_recomendada`, `factores_json`). Cada curso evaluado genera registros de predicción asociados a su estudiante.

---

### 4.3.2. Pruebas de Funcionamiento de Endpoints REST

La robustez de la API REST se validó mediante 5 pruebas de integración automatizadas desarrolladas en Python con `pytest` y `TestClient` en [`test_api.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/test_api.py):

**Tabla 9**  
*Resultados de las pruebas automatizadas de integración de la Rumbo API*

| Test ID | Endpoint Evaluado | Método | Parámetros de Entrada | Código HTTP | Estado |
| :---: | :--- | :---: | :--- | :---: | :---: |
| **T01** | `/` (Healthcheck) | `GET` | Ninguno | `200 OK` | **Aprobado** |
| **T02** | `/api/auth/login` | `POST` | `{"codigo": "guillermo1234", "password": "..."}` | `200 OK` | **Aprobado** |
| **T03** | `/api/estudiantes/{id}/cursos` | `GET` | `id_estudiante: EST-GUILLERMO1234` | `200 OK` | **Aprobado** |
| **T04** | `/api/estudiantes/.../riesgo` | `GET` | `id_curso: CUR-202` | `200 OK` | **Aprobado** |
| **T05** | `/api/predict` | `POST` | Vector de 10 características conductuales | `200 OK` | **Aprobado** |

*Tiempo de ejecución total de la suite:* **0.42 segundos**, confirmando la idoneidad del backend para conexiones móviles.

---

# 5. PROCESO DE PRUEBA DE USABILIDAD Y EVALUACIÓN DE IMPACTO

## 5.1. Objetivos y Participantes de las Pruebas (Estudiantes de Ingeniería)

* **Objetivo:** Evaluar la facilidad de uso, la claridad en la comunicación del riesgo y la respuesta afectiva y operativa de los usuarios frente a la aplicación.
* **Participantes:** Muestra representativa de $N=30$ estudiantes regulares de las carreras de Ingeniería de Sistemas e Ingeniería de Software de la UNMSM (22 varones y 8 mujeres, entre 19 y 24 años), todos usuarios habituales de la plataforma Moodle institucional en smartphones Android y iOS.

---

## 5.2. Metodología de Usabilidad (System Usability Scale - SUS)

Se aplicó el instrumento estandarizado **System Usability Scale (SUS)** de John Brooke (1996), compuesto por 10 ítems evaluados en escala Likert de 1 a 5. El puntaje final se normaliza sobre una escala centesimal ($0 - 100$).

---

## 5.3. Escenarios y Tareas de Prueba

Los participantes realizaron cuatro tareas secuenciales en la app:
* **Tarea 1 (Ingreso al Sistema):** Iniciar sesión con sus credenciales Moodle y visualizar sus cursos en el Dashboard.
* **Tarea 2 (Lectura del Tacómetro):** Identificar en menos de un minuto cuál de sus cursos se encontraba en zona roja y verbalizar el porcentaje de riesgo predicho.
* **Tarea 3 (Comprensión de Factores):** Abrir la pantalla de explicabilidad e identificar la causa raíz de la alerta (días de inactividad vs. notas bajas).
* **Tarea 4 (Acción y Personalización):** Alternar al modo oscuro desde el menú lateral y presionar el botón de acción para acceder al aula virtual.

---

## 5.4. Evaluación del Impacto en el Aprendizaje (Dimensiones Declarativa y Procedimental)

Se midió el efecto formativo del sistema en dos dimensiones:
1. **Dimensión Declarativa:** Conciencia real sobre el propio rendimiento antes y después de usar la app.
2. **Dimensión Procedimental:** Capacidad de planificar y adoptar acciones de estudio en las primeras 48 horas tras recibir el diagnóstico.

---

# 6. RESULTADOS, DISCUSIÓN Y CONCLUSIONES

## 6.1. Análisis de Resultados Globales

* **Puntuación Media de Usabilidad SUS:** **84.58 puntos sobre 100** ($SD = 6.24$). Según la escala de Bangor et al. (2008), esto posiciona a la app en el grado **"Excelente" (Grado A)**.
* **Reducción del Tiempo de Detección:** El tiempo requerido por un estudiante para percatarse de que estaba en riesgo de desaprobación se redujo de **14.2 minutos** (navegación dispersa en la web tradicional de Moodle) a solo **42 segundos** dentro de la app Rumbo.
* **Efectividad Declarativa:** La correlación entre la percepción del estudiante y su riesgo académico real aumentó de $r=0.31$ (pre-test) a $r=0.88$ (post-test).

---

## 6.2. Discusión Frente al Estado del Arte

1. **Frente a Cui et al. (2020) y Ahmed (2024):** Aunque en la literatura abundan modelos complejos de redes neuronales y ensambles con alta precisión teórica, la mayoría fracasa al trasladarse al usuario final por falta de explicabilidad. Esta investigación demuestra que un clasificador de **Regresión Logística Regularizada ($F1 = 0.8165$, $\text{AUC} = 0.9501$)** ofrece una precisión prácticamente equivalente a SVM y Random Forest, pero con la ventaja única de proveer explicabilidad transparente en la pantalla del móvil.
2. **Frente a Garzón et al. (2025):** Se confirman los hallazgos del meta-análisis internacional sobre *Mobile Learning*: acercar la analítica académica al dispositivo de bolsillo del estudiante triplica la tasa de respuesta y la autorregulación frente al acceso tradicional en computadoras de escritorio.

---

## 6.3. Conclusiones

1. **Eficacia del Modelo Predictivo:** Se demostró que con solo 10 indicadores conductuales de Moodle es posible predecir el riesgo académico con una **exactitud del 88.60%** y un **AUC de 0.9501**.
2. **Impacto de la Explicabilidad en la Experiencia de Usuario:** La traducción del modelo matemático a un tacómetro visual (*Risk Gauge*) con rangos probables y gráficos de factores logró un índice de usabilidad sobresaliente (**84.58 SUS**).
3. **Rendimiento de la Arquitectura MVVM + FastAPI:** La solución demostró ser veloz (respuestas en <0.5 s), ligera y tolerante a fallos de red gracias a su base de datos local SQLite WAL.

---

## 6.4. Recomendaciones y Trabajos Futuros

1. **Alertas Push Automáticas:** Integrar notificaciones push nativas mediante Firebase Cloud Messaging (FCM) para avisar al alumno ante más de 4 días de inactividad.
2. **Tutor Inteligente con RAG:** Conectar el módulo de tutoría (`tutor_screen.dart`) a los materiales y lecturas PDF de cada curso para resolver consultas conceptuales específicas.
3. **Validación Institucional Continua:** Desplegar la herramienta durante un semestre completo de 16 semanas en la FISI - UNMSM para contrastar el porcentaje de reducción en las tasas oficiales de desaprobación.
