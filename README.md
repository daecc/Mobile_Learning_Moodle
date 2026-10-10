# Rumbo · Mobile Learning Moodle 🎓📱

Sistema inteligente de **Mobile Learning** integrado con el LMS Moodle y potenciado con **Machine Learning**, diseñado para la detección temprana y prevención del **Riesgo Académico** en estudiantes universitarios de ingeniería.

---

## 🏗️ Arquitectura del Sistema

El proyecto sigue una arquitectura desacoplada basada en microservicios y MVVM:

```
┌─────────────────────────────────┐
│     Frontend Móvil (Flutter)     │
│   Arquitectura MVVM + Provider  │
└────────────────┬────────────────┘
                 │ REST / JSON (HTTP)
┌────────────────▼────────────────┐
│      Backend API (FastAPI)      │
│  Controladores, DTOs y Servicios│
└────────┬───────────────┬────────┘
         │               │
┌────────▼────────┐ ┌────▼──────────────┐
│  Módulo de IA   │ │   LMS Moodle      │
│  (scikit-learn) │ │  Logs e Interacción│
└─────────────────┘ └───────────────────┘
```

1. **Frontend (Flutter):** Implementación fiel al sistema de diseño **Rumbo** (Light & Dark mode), con el medidor semicircular de riesgo (*Tacómetro / RiskGauge*), alertas tempranas accionables y tarjetas metacognitivas explicativas.
2. **Backend (FastAPI):** API REST de alto rendimiento que realiza inferencia en tiempo real usando el modelo entrenado con `StandardScaler` y `LogisticRegression` / `RandomForest`.
3. **Módulo de IA (`Entrenamiento/`):** Generador de dataset sintético y comparación de 5 modelos de aprendizaje supervisado con validación estratificada y ROC-AUC > 0.94.

---

## 📁 Estructura del Repositorio

```text
Mobile_Learning_Moodle/
├── Backend/
│   ├── app/
│   │   ├── routes/             # Endpoints (auth, cursos, predict)
│   │   ├── services/           # Inferencia ML y repositorio de datos
│   │   ├── models.py           # Esquemas Pydantic
│   │   └── main.py             # Aplicación FastAPI y CORS
│   ├── ml_models/              # Modelos exportados (.joblib)
│   ├── requirements.txt        # Dependencias Python
│   ├── run.py                  # Script de inicio rápido
│   └── test_api.py             # Suite de pruebas automatizadas
│
├── Frontend/
│   ├── lib/
│   │   ├── core/               # Temas (Light/Dark) y constantes de API
│   │   ├── data/               # Modelos y servicio HTTP con fallback offline
│   │   ├── viewmodels/         # Estado MVVM (Auth, Cursos, Riesgo)
│   │   ├── views/
│   │   │   ├── screens/        # Login, Mis Cursos, Panel de Riesgo
│   │   │   └── widgets/        # Tacómetro Gauge, Banners, Tarjetas
│   │   └── main.dart           # Entrada principal
│   └── pubspec.yaml            # Dependencias Flutter (http, provider)
│
├── Docs/                       # Documentación pedagógica, paper y capturas UI
└── Entrenamiento/              # Notebooks de Jupyter y datasets CSV
```

---

## 🚀 Guía de Ejecución

### 1. Iniciar el Backend (FastAPI)

En una terminal:

```bash
cd Backend
pip install -r requirements.txt
python run.py
```

* La API estará activa en: `http://127.0.0.1:8000`
* Documentación interactiva Swagger: `http://127.0.0.1:8000/docs`

Para correr la suite de pruebas del backend:
```bash
python test_api.py
```

---

### 2. Iniciar el Frontend (Flutter)

En otra terminal:

```bash
cd Frontend
flutter pub get
```

Puedes correrlo en la plataforma de tu elección:

* **En el Navegador Web (Chrome):**
  ```bash
  flutter run -d chrome
  ```
* **En Windows Desktop:**
  ```bash
  flutter run -d windows
  ```
* **En Emulador Android:**
  ```bash
  flutter run -d android
  ```

---

## 🔑 Credenciales de Prueba (Demo)

El sistema incluye accesos rápidos preconfigurados en la pantalla de inicio:
* **Estudiante Principal:** `EST-0001` (Valeria Rojas Palacios)
* **Contraseña:** `123456`
* Puedes ingresar con cualquier código en formato `EST-XXXX` (del `EST-0001` al `EST-0400`) para ver los cursos y predicciones asociadas al dataset.
