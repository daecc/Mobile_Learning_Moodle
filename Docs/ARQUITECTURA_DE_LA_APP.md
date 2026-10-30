# Arquitectura del Sistema · RUMBO
> **Mobile Learning & Analítica Predictiva con Inteligencia Artificial**  
> *Facultad de Ingeniería de Sistemas e Informática (FISI) — UNMSM*  
> *Curso: Taller de Construcción de Software Móvil — Docente: Dr. Iván Carlo Petrlik Azabache*

---

## 📌 Imagen del Diagrama de Arquitectura
El diagrama visual en alta definición se encuentra disponible en:
- [`Docs/diagrama_arquitectura_app.png`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagrama_arquitectura_app.png)
- [`Docs/diagramas/diagrama_arquitectura_app.png`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagramas/diagrama_arquitectura_app.png)

![Diagrama de Arquitectura de la App](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/diagrama_arquitectura_app.png)

---

## 🏗️ Representación del Diagrama de Arquitectura (3 Bloques Principales)

```mermaid
flowchart LR
    subgraph Col1["1. FRONTEND MÓVIL (Flutter MVVM)"]
        direction TB
        subgraph TopCol1["Vistas y Componentes UI"]
            Phones["📱 Mockups de App<br/>• Asignaturas & Semáforo<br/>• Perfil & Tacómetro"]
            Gauge["🎯 Risk Gauge<br/>Tacómetro Heurística H6"]
            UI["🎨 Componentes de UI Flutter<br/>• 🎯 Análisis de Riesgos & SHAP<br/>• 🤖 Chatbot Tutor IA (Gemini)<br/>• 🎮 Gamificación (6 Rangos & XP)<br/>• 🧠 Metacognición & Diagnóstico"]
        end
        Provider["⚡ Gestión de Estado con Provider<br/>ChangeNotifier · Inyección de Dependencias"]
        subgraph MVVM["🏛️ Arquitectura MVVM"]
            View["Vista (View)<br/>Screens & Widgets"] <-->|Vista| VM["Modelo de Vista<br/>(ViewModel)"] <-->|Modelo| Model["Modelo<br/>(Model)"]
            SubModel["Modelos Locales | APIs REST | Caché Offline"]
        end
        TopCol1 --> Provider
        Provider -->|Gestión vista| MVVM
    end

    subgraph Col2["2. BACKEND Y MOTOR ML (FastAPI y Python)"]
        direction TB
        FastAPI["⚡ Servidor FastAPI<br/>FastAPI & Uvicorn ASGI Server"]
        Endpoints["🛣️ Enrutadores REST API (Endpoints)<br/>• 🔐 Auth: /api/auth/login<br/>• 📊 Cursos/Riesgo: /api/estudiantes/...<br/>• 🤖 Chatbot: /api/tutor/chat<br/>• 🎮 Gamif/Meta: /diagnostico"]
        subgraph ML["🤖 Pipeline de Machine Learning (Scikit-Learn)"]
            P1["Preprocesamiento de Datos<br/>StandardScaler (scaler.joblib)"] --> P2["Extracción de 7 Métricas<br/>Telemetría MoodleCloud LMS"] --> P3["Inferencia del Modelo<br/>LogisticRegression (model.joblib)"]
            P2 & P3 --> P4["Servicio de Predicción de Riesgo<br/>Probabilidad + Factores XAI (Coeficientes)<br/>Bandas H6 (Bajo, Moderado, Crítico)"]
            Strip["🎮 6 Rangos & XP (14 Semanas) | 🧠 Revisiones Metacognitivas"]
        end
        Auth["🔑 Autenticación & Orquestador LLM<br/>Token Moodle WS + Agente Gemini Tutor IA"]
        FastAPI -->|HTTPS / REST| Endpoints
        Endpoints -->|Invocación| ML
        ML --> Auth
    end

    subgraph Col3["3. SERVICIOS EXTERNOS Y ALMACENAMIENTO"]
        direction TB
        subgraph Moodle["☁️ Integración MoodleCloud LMS & Gemini"]
            MoodleSrv[(Servidor Moodle LMS)] <-->|Calificaciones y Telemetría| MoodleWS["Moodle Web Services"]
            Gemini["✨ Google Gemini AI (LLM Cloud)<br/>Motor Tutor Pedagógico y Estrategias"]
        end
        subgraph SQLite["🗄️ Base de Datos SQLite Local (rumbo.db)"]
            T1["Perfiles (estudiantes)"]
            T2["Telemetría (metricas)"]
            T3["Predicciones (predicciones)"]
            T4["Gamificación & Metacognición<br/>(accesos & revisiones)"]
        end
    end

    Col1 <-->|HTTPS / REST| Col2
    Col2 <-->|HTTPS / REST| Moodle
    Col2 -->|SQLite Driver WAL| SQLite
```

---

## 🔍 Explicación de los 3 Bloques para la Exposición

### Bloque 1: Frontend Móvil (Flutter MVVM)
1. **Mockups y Pantallas**:
   - `CoursesScreen`: Lista de asignaturas con semáforo de riesgo en tiempo real (Bajo, Moderado, Crítico).
   - `RiskScreen`: Detalle de riesgo con el tacómetro visual **Risk Gauge**, aplicando la **Heurística H6 de Nielsen** (margen de incertidumbre, ej: 78–91%).
   - `FactorsScreen`: Desglose explicativo de factores de impacto basado en SHAP.
   - `GamificationScreen`: Sistema de 6 rangos adaptado a 14 semanas con avatar y misiones renovables.
2. **Componentes de UI Flutter**:
   - Widgets modulares y desacoplados: [`LiquidGlassNavBar`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Frontend/lib/views/widgets/liquid_glass_nav_bar.dart), [`AppDrawer`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Frontend/lib/views/widgets/app_drawer.dart), [`TierAvatar`](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Frontend/lib/views/widgets/tier_avatar.dart).
3. **Gestión de Estado con Provider**:
   - Uso de `ChangeNotifier` para notificar reactivamente a la UI sin recrear el árbol de widgets innecesariamente.
   - Integración con `SharedPreferences` para persistir la preferencia de Modo Claro / Modo Oscuro localmente (**Laboratorio 06**).
4. **Arquitectura MVVM**:
   - **Vista (View)**: Únicamente renderizado declarativo y captura de eventos de usuario.
   - **Modelo de Vista (ViewModel)**: Lógica de presentación observable (`AuthViewModel`, `RiesgoViewModel`, `CoursesViewModel`, `ThemeViewModel`).
   - **Modelo (Model)**: DTOs inmutables fuertemente tipados con constructores `fromJson`.

---

### Bloque 2: Backend y Motor ML (FastAPI y Python)
1. **Servidor FastAPI**:
   - Framework ASGI de alto rendimiento sobre Uvicorn.
   - Documentación OpenAPI/Swagger autogenerada y disponible en `/docs`.
2. **Enrutadores REST API (Endpoints)**:
   - `/api/auth/login`: Autenticación real contra MoodleCloud LMS y emisión de token.
   - `/api/estudiantes/{id}/cursos`: Consulta y sincronización de asignaturas matriculadas.
   - `/api/estudiantes/{id}/cursos/{c}/riesgo`: Detalle completo de riesgo, tacómetro H6 y factores explicativos.
   - `/api/predict`: Endpoint de inferencia directa para escenarios analíticos.
   - `/api/tutor/chat`: Asistente conversacional pedagógico para la autorregulación del estudio.
3. **Pipeline de Machine Learning (Scikit-Learn)**:
   - **Preprocesamiento**: Normalización de las variables numéricas con `StandardScaler` (`scaler.joblib`).
   - **Extracción de Métricas**: Obtención de las 7 variables conductuales (días de inactividad, margen de entrega, promedio, slope de notas, tasa de pendientes y asistencias).
   - **Inferencia del Modelo**: Clasificador supervisado `LogisticRegression` (`model.joblib`), seleccionado por su alta interpretabilidad y calibración probabilística.
   - **Servicio de Predicción de Riesgo & XAI**: Cálculo de la probabilidad de rezago mediante la función sigmoide y atribución directa de factores protectores y de riesgo a partir de los coeficientes del modelo (Inteligencia Artificial Explicable).
4. **Autenticación**:
   - Validación rigurosa de entradas y salidas mediante modelos **Pydantic v2**, manejo de cabeceras seguras y soporte de sesión offline (`DEMO`).

---

### Bloque 3: Servicios Externos y Almacenamiento
1. **Integración MoodleCloud LMS**:
   - Conexión vía protocolo HTTPS/REST hacia la API oficial `moodle_mobile_app`.
   - Consulta de calificaciones con `gradereport_user_get_grade_items`.
   - Extracción de tareas y plazos con `mod_assign_get_assignments`.
   - Sincronización de cursos y último acceso con `core_enrol_get_users_courses`.
2. **Base de Datos SQLite Local (`rumbo.db`)**:
   - Base de datos relacional local configurada con **Write-Ahead Logging (`PRAGMA journal_mode = WAL;`)** para concurrencia lectura/escritura y claves foráneas activas (`PRAGMA foreign_keys = ON;`).
   - Almacena las tablas:
     - `estudiantes`: Perfil universitario, token y ID de Moodle.
     - `metricas`: Telemetría académica extraída del aula virtual.
     - `predicciones`: Resultados de la IA, bandas H6 y factores SHAP serializados.
     - `cursos`, `historial_accesos` y `revisiones_diagnostico`: Soporte a la navegación y gamificación semanal.

---

> 🔗 **Ver también**:
> - [Diagrama Entidad-Relación de Base de Datos](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/Docs/DIAGRAMA_BASE_DE_DATOS.md)
> - [Manual de Exposición y Flujo de Datos](file:///c:/Users/camil/Desktop/ProyectoMobileLV1.0/README.md)
