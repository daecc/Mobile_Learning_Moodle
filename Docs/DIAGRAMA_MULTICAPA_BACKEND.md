# Diagrama Multicapa del Backend · RUMBO
> **Arquitectura de Componentes C4 (FastAPI, Machine Learning & Servicios Externos)**  
> *Facultad de Ingeniería de Sistemas e Informática (FISI) — UNMSM*  
> *Curso: Taller de Construcción de Software Móvil — Docente: Dr. Iván Carlo Petrlik Azabache*

---

## 📌 Imagen del Diagrama Multicapa del Backend
El diagrama visual en alta definición se encuentra disponible en:
- [`Docs/diagrama_multicapa_backend.png`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagrama_multicapa_backend.png)
- [`Docs/diagramas/diagrama_multicapa_backend.png`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagramas/diagrama_multicapa_backend.png)

![Diagrama Multicapa del Backend](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagrama_multicapa_backend.png)

---

## 🏗️ Representación del Diagrama C4 en Mermaid

```mermaid
flowchart TD
    %% Cliente Móvil
    Client["📱 App Móvil Flutter (MVVM)<br/><b>[Software System]</b><br/>Cliente Móvil (Dart & Provider)<br/><i>• Riesgo H6 • Tutor IA • 6 Rangos XP • Metacognición</i>"]

    %% Sistema Backend FastAPI
    subgraph System["Sistema Backend FastAPI [Software System]"]
        subgraph Container["Aplicación FastAPI [Container]"]
            
            %% Capa 1: Red y Controladores
            subgraph Layer1["Capa de Red y Controladores REST FastAPI"]
                Main["⚡ main.py<br/><b>[Component: FastAPI]</b><br/>CORS + Middleware + Uvicorn ASGI Server<br/>Swagger UI en /docs"]
                CursosRouter["🛣️ cursos.py<br/><b>[Component: FastAPI Router]</b><br/>/api/estudiantes<br/>Cursos, Riesgo H6, Gamificación & Metacognición"]
                PredictRouter["🛣️ predict.py<br/><b>[Component: FastAPI Router]</b><br/>/api/predict<br/>Inferencia Directa de Riesgo (7 Variables)"]
                AuthRouter["🛣️ auth.py<br/><b>[Component: FastAPI Router]</b><br/>/api/auth<br/>Autenticación Moodle WS y Tokens"]
                TutorRouter["🛣️ tutor.py<br/><b>[Component: FastAPI Router]</b><br/>/api/tutor<br/>Chatbot Tutor IA Pedagógico & Andamiaje"]
            end

            %% Capa 2: Servicios y Negocio
            subgraph Layer2["Capa de Servicios y Negocio"]
                DataService["📦 data_service.py<br/><b>[Component: Service / Repository]</b><br/>Adaptador y Perfiles de Estudiante"]
                MoodleService["☁️ moodle_service.py<br/><b>[Component: Service]</b><br/>Orquestador Moodle REST: Telemetría 7 Variables"]
                MLService["🤖 ml_service.py<br/><b>[Component: Service]</b><br/>Pipeline Scikit-Learn: LogisticRegression + XAI"]
            end

            %% Capa 3: Persistencia y Modelos
            subgraph Layer3["Capa de Persistencia y Modelos"]
                MLModels["📂 ml_models/<br/><b>[Component: Artifacts]</b><br/>model.joblib · scaler.joblib · features.joblib"]
                ModelsPydantic["📐 models.py<br/><b>[Component: Models]</b><br/>Esquemas Pydantic v2 (DTOs & Validación)"]
                DB["🗄️ database.py<br/><b>[Component: Database]</b><br/>SQLite con Modo WAL (rumbo.db)<br/><i>6 Tablas: estudiantes, cursos, metricas, predicciones, accesos, revisiones</i>"]
            end

        end
    end

    %% Sistemas Externos
    subgraph External["Sistemas Externos"]
        Gemini["✨ Google Gemini API (LLM)<br/><b>[Software System]</b><br/>LLM Cloud (gemini-1.5-flash / gemini-pro)<br/>Motor Cognitivo del Tutor Pedagógico"]
        MoodleCloud["🎓 MoodleCloud LMS<br/><b>[Software System]</b><br/>Web Services REST API (moodle_mobile_app)<br/>LMS Académico Institucional"]
    end

    %% Relaciones
    Client -->|HTTP / JSON| Main
    Main -.->|Rutea peticiones| CursosRouter
    Main -.->|Rutea peticiones| PredictRouter
    Main -.->|Rutea peticiones| AuthRouter
    Main -.->|Rutea peticiones| TutorRouter

    CursosRouter -.->|Usa| DataService
    CursosRouter -.->|Usa| MoodleService
    PredictRouter -.->|Usa| MLService
    AuthRouter -.->|Usa| MoodleService
    TutorRouter -.->|Usa (Contexto)| MoodleService
    MoodleService -.->|Orquesta| MLService

    TutorRouter -.->|Llama a| Gemini
    MoodleService -.->|Llama a| MoodleCloud

    MLService -.->|Carga modelos desde| MLModels
    ModelsPydantic -.->|Mapea DTOs| DB
    MoodleService -.->|Consulta / Escribe| DB
    DataService -.->|Consulta / Escribe| DB
    TutorRouter -.->|Historial Chat| DB
```

---

## 🔍 Explicación Detallada de las Capas del Backend

### 1. Capa de Red y Controladores REST FastAPI
Es el punto de entrada que expone los endpoints HTTP consumidos por el cliente Flutter en formato JSON:
- [`main.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/main.py): Inicializa la aplicación FastAPI, configura las políticas CORS para admitir peticiones desde emuladores y dispositivos móviles reales, monta el middleware y expone la documentación interactiva Swagger en `/docs`.
- [`cursos.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/routes/cursos.py): Controlador central que gestiona:
  - Lista de cursos del estudiante con su semáforo de riesgo en tiempo real (`/api/estudiantes/{id}/cursos`).
  - Detalle analítico con tacómetro Risk Gauge e intervalo de confianza H6 (`/api/estudiantes/{id}/cursos/{id_curso}/riesgo`).
  - Motor de **Gamificación** (cálculo de 6 rangos de Novato a Erudito, XP semanal en 14 semanas y misiones).
  - Módulo de **Metacognición** (`/api/diagnostico-revision` y `/api/historial-revisiones`).
- [`predict.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/routes/predict.py): Endpoint de inferencia directa para pruebas y simulaciones What-If con las 7 variables del modelo.
- [`auth.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/routes/auth.py): Endpoint de login institucional (`/api/auth/login`) que valida credenciales con MoodleCloud y genera tokens de sesión.
- [`tutor.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/routes/tutor.py): Controlador del **Chatbot Tutor IA** (`/api/tutor/chat`), que gestiona el andamiaje cognitivo adaptativo y el historial de conversación.

---

### 2. Capa de Servicios y Negocio
Contiene la lógica de negocio, integración con APIs externas y ejecución de analítica predictiva:
- [`moodle_service.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/services/moodle_service.py): Cliente REST asíncrono que consulta la API de MoodleCloud (`moodle_mobile_app`). Extrae las 7 métricas de telemetría (inactividad, notas, tareas vencidas, asistencia, tendencia) y orquesta la predicción con el motor de ML.
- [`ml_service.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/services/ml_service.py): Servicio de Machine Learning que carga el pipeline entrenado (`model.joblib` y `scaler.joblib`), ejecuta la inferencia predictiva en `< 50ms` mediante `LogisticRegression`, clasifica en bandas de riesgo (Bajo, Moderado, Crítico con heurística H6) y genera explicabilidad con coeficientes ponderados XAI.
- [`data_service.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/services/data_service.py): Repositorio y adaptador que desacopla la fuente de datos, ofreciendo fallbacks seguros y mapeo de perfiles.

---

### 3. Capa de Persistencia y Modelos
Gestiona el almacenamiento local de alta concurrencia y los modelos de datos tipados:
- [`database.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/database.py): Motor SQLite optimizado con **modo WAL** (Write-Ahead Logging) y claves foráneas habilitadas, garantizando lecturas no bloqueantes:
  - `estudiantes`: Perfiles y tokens institucionales.
  - `cursos`: Catálogo de asignaturas matriculadas por estudiante.
  - `metricas`: Telemetría académica extraída de Moodle.
  - `predicciones`: Probabilidades de riesgo, bandas H6 y factores explicativos XAI en JSON.
  - `historial_accesos`: Días activos para rachas de gamificación.
  - `revisiones_diagnostico`: Autodiagnósticos semanales de autorregulación metacognitiva.
- [`models.py`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/app/models.py): Esquemas Pydantic v2 que validan los contratos de entrada/salida (DTOs).
- [`ml_models/`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Backend/ml_models): Artefactos serializados del modelo Scikit-Learn (`model.joblib`, `scaler.joblib`, `features.joblib`).

---

### 4. Sistemas Externos
- **Google Gemini API (LLM Cloud)**: Modelo `gemini-1.5-flash` / `gemini-pro` invocado desde `tutor.py` con prompt pedagógico socrático, inyectando el contexto de notas y riesgo del estudiante.
- **MoodleCloud LMS**: Plataforma institucional universitaria desde donde se extrae la telemetría académica de calificaciones, quizzes, foros y entregas.
