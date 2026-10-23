# Diagrama Entidad-Relación · Base de Datos Local (`rumbo.db`)
> **Sistema RUMBO · Mobile Learning Moodle**  
> *Facultad de Ingeniería de Sistemas e Informática (FISI) — UNMSM*

---

## 📌 Imagen del Diagrama
El diagrama visual en alta definición se encuentra generado en:
- [`Docs/diagrama_er_base_de_datos.png`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagrama_er_base_de_datos.png)
- [`Docs/diagramas/diagrama_er_base_de_datos.png`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagramas/diagrama_er_base_de_datos.png)

---

## 🏛️ Representación Mermaid (ER Diagram)

```mermaid
erDiagram
    estudiantes ||--o{ cursos : "1 : N (Matrícula)"
    estudiantes ||--o{ metricas : "1 : N (Telemetría)"
    estudiantes ||--o{ predicciones : "1 : N (Riesgo)"
    estudiantes ||--o{ historial_accesos : "1 : N (Días Activos)"
    estudiantes ||--o{ revisiones_diagnostico : "1 : N (Revisiones)"

    cursos ||--o{ metricas : "1 : N"
    cursos ||--o{ predicciones : "1 : N (Inferencia ML)"
    cursos ||--o{ historial_accesos : "1 : N"
    cursos ||--o{ revisiones_diagnostico : "1 : N"

    estudiantes {
        TEXT id_estudiante PK "Código único (ej: EST-GUILLERMO1234)"
        TEXT username UK "Usuario de Moodle (ej: guillermo1234)"
        TEXT nombre "Nombre completo del estudiante"
        TEXT correo "Correo institucional @unmsm.edu.pe"
        TEXT carrera "Carrera profesional"
        TEXT ciclo "Ciclo académico"
        TEXT token_moodle "Token de sesión oficial Moodle"
        INTEGER moodle_userid "ID numérico en MoodleCloud"
        TIMESTAMP last_login "Fecha y hora del último acceso"
    }

    cursos {
        TEXT id_curso PK "Identificador único del curso (ej: CUR-001)"
        TEXT id_estudiante PK,FK "Referencia a estudiantes.id_estudiante"
        INTEGER moodle_id "ID del curso en Moodle"
        TEXT nombre "Nombre de la asignatura"
        TEXT codigo "Código oficial del curso (ej: GS-G1-2026)"
        TEXT docente "Nombre del docente titular"
        INTEGER creditos "Cantidad de créditos académicos"
        TEXT fecha_estimacion "Fecha legible del cálculo"
    }

    metricas {
        INTEGER id PK "Autoincremental"
        TEXT id_curso FK "Referencia a cursos.id_curso"
        TEXT id_estudiante FK "Referencia a estudiantes.id_estudiante"
        INTEGER dias_inactividad "Días transcurridos desde el último acceso"
        INTEGER tareas_totales "Total de actividades evaluativas asignadas"
        INTEGER tareas_pendientes "Tareas sin entregar a la fecha"
        REAL promedio_quizzes "Calificación promedio en cuestionarios"
        INTEGER accesos_esta_semana "Conteo de sesiones en la semana actual"
        REAL promedio_historico "Promedio ponderado acumulado (0..20)"
        REAL tendencia_calificaciones "Pendiente de regresión de notas (Slope)"
        REAL margen_entrega_horas "Horas de anticipación respecto al plazo límite"
        REAL asistencia_formal "Proporción de asistencia formal a clases"
        REAL asistencia_virtual "Proporción de regularidad virtual (0..1)"
        TEXT fecha_corte "Fecha y hora del corte analítico"
    }

    predicciones {
        INTEGER id PK "Autoincremental"
        TEXT id_curso FK "Referencia a cursos.id_curso"
        TEXT id_estudiante FK "Referencia a estudiantes.id_estudiante"
        REAL probabilidad "Probabilidad cruda de riesgo (0.0..1.0)"
        INTEGER porcentaje "Porcentaje visual de riesgo (0..100 %)"
        TEXT nivel_riesgo "Categoría: BAJO | MODERADO | CRITICO"
        INTEGER rango_min "Límite inferior de confianza (Heurística H6)"
        INTEGER rango_max "Límite superior de confianza (Heurística H6)"
        TEXT alerta_titulo "Encabezado contextual de alerta"
        TEXT alerta_mensaje "Mensaje empático y orientativo para el alumno"
        TEXT accion_recomendada "Sugerencia correctiva prioritaria"
        TEXT paso_titulo "Paso concreto a seguir en Moodle"
        TEXT paso_subtitulo "Detalle y fecha límite del paso"
        TEXT paso_tipo "Categoría visual del paso (tarea, quiz, etc.)"
        INTEGER is_sin_estimacion "Bandera (0 | 1) para cursos con datos insuficientes"
        TEXT factores_json "DTO serializado con pesos de impacto SHAP"
        TIMESTAMP updated_at "Marca de tiempo de la última inferencia"
    }

    historial_accesos {
        INTEGER id PK "Autoincremental"
        TEXT id_estudiante FK "Referencia a estudiantes.id_estudiante"
        TEXT id_curso FK "Referencia a cursos.id_curso"
        INTEGER timestamp "Marca de tiempo UNIX del acceso"
    }

    revisiones_diagnostico {
        INTEGER id PK "Autoincremental"
        TEXT id_estudiante FK "Referencia a estudiantes.id_estudiante"
        TEXT id_curso FK "Referencia a cursos.id_curso"
        TEXT semana_lunes "Fecha del lunes de la semana activa (YYYY-MM-DD)"
        TIMESTAMP created_at "Marca de tiempo de la revisión"
    }
```

---

## 🔬 Especificación Técnica de las Tablas

### 1. Tabla `estudiantes`
- **Propósito**: Almacena las cuentas sincronizadas desde el aula virtual Moodle LMS y el perfil universitario.
- **Clave Primaria**: `id_estudiante` (`TEXT`).
- **Restricción Unique**: `username` (`TEXT UNIQUE`) para evitar perfiles duplicados.

### 2. Tabla `cursos`
- **Propósito**: Asignaturas en las que está matriculado cada estudiante.
- **Clave Primaria Compuesta**: `(id_curso, id_estudiante)` (`TEXT`).
- **Clave Foránea**: `id_estudiante REFERENCES estudiantes(id_estudiante)`.

### 3. Tabla `metricas`
- **Propósito**: Almacena la telemetría conductual y académica extraída desde las APIs Web Services de Moodle.
- **Variables Clave para ML**:
  - `dias_inactividad`: Días transcurridos sin entrar al curso en Moodle.
  - `tareas_pendientes` / `tareas_totales`: Tasa de rezago de entregas.
  - `promedio_quizzes` y `promedio_historico`: Rendimiento cognitivo previo.
  - `tendencia_calificaciones` (Slope): Pendiente de notas en los cortes del semestre.
  - `margen_entrega_horas`: Hábitos de entrega (anticipación vs última hora).
  - `asistencia_virtual`: Regularidad de días activos a la semana.

### 4. Tabla `predicciones`
- **Propósito**: Guarda los resultados de inferencia del modelo de Machine Learning (`RandomForestClassifier`) y los factores explicativos SHAP.
- **Campos Notables**:
  - `probabilidad` y `porcentaje`: Nivel numérico de riesgo de desaprobación.
  - `nivel_riesgo`: Clasificación semafórica (`BAJO`, `MODERADO`, `CRITICO`).
  - `rango_min` y `rango_max`: Rango de incertidumbre basado en la **Heurística H6 de Jakob Nielsen** (*Recognition rather than recall & Error tolerance*).
  - `factores_json`: Objeto serializado que nutre los 4 gráficos interactivos de la pantalla [`FactorsScreen`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Frontend/lib/views/screens/factors_screen.dart).

### 5. Tabla `historial_accesos`
- **Propósito**: Registro de accesos por día y curso para auditar la actividad real en Moodle.
- **Restricción Unique**: `UNIQUE(id_estudiante, id_curso, timestamp)`.
- **Integración con Gamificación**: Alimenta la misión **«Constancia Semanal»** (requiere $\ge 4$ días activos reales para desbloquearse).

### 6. Tabla `revisiones_diagnostico`
- **Propósito**: Registro metacognitivo que asegura que el estudiante consulte la pantalla de diagnóstico **«¿Por qué este resultado?»**.
- **Restricción Unique**: `UNIQUE(id_estudiante, id_curso, semana_lunes)`.
- **Integración con Gamificación**: Alimenta el logro **«Estratega del Aprendizaje»** (revisar el diagnóstico de todos los cursos matriculados durante la semana).

---

## 🛡️ Garantías Arquitecturales del Motor SQLite
1. **Modo WAL (`PRAGMA journal_mode = WAL;`)**: Permite que las lecturas concurrentes del cliente Flutter no bloqueen las transacciones de escritura del backend.
2. **Integridad Referencial (`PRAGMA foreign_keys = ON;`)**: Evita registros huérfanos entre estudiantes, asignaturas y predicciones.
3. **Alineación con la Teoría del Curso**: Cumple con las diapositivas de *Diseño de Software Móvil I* (Dr. Iván Petrlik Azabache, Diapositivas 13 a 17) sobre el modelo relacional de cursos y tareas con restricciones y transacciones ACID.
