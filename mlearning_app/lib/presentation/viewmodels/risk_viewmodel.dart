import 'package:flutter/foundation.dart';
import 'package:mlearning_early_warning/data/models/risk_model.dart';
import 'package:mlearning_early_warning/data/services/risk_api_service.dart';

/// Estados posibles de la carga de la predicción
enum RiskViewState {
  /// Estado inicial, antes de cualquier carga
  initial,

  /// Cargando datos del servidor (llamada REST en progreso)
  loading,

  /// Datos cargados exitosamente
  success,

  /// Error en la carga (red, servidor, parsing, etc.)
  error,
}

/// ViewModel para la pantalla de detalle de riesgo académico.
///
/// Responsabilidades:
/// - Gestionar el estado de la UI (loading, success, error)
/// - Orquestar la llamada al servicio de API
/// - Exponer datos transformados/listos para la Vista
/// - **NO contiene lógica de UI** (navegación, diálogos, animaciones)
/// - **NO conoce detalles de implementación del servicio** (usa abstracción)
class RiskViewModel extends ChangeNotifier {
  final RiskApiService _apiService;

  /// IDs del estudiante y curso a consultar (provistos por el caller).
  final String _estudianteId;
  final String _cursoId;

  // Estado interno
  RiskViewState _state = RiskViewState.initial;
  PrediccionRiesgo? _prediccion;
  String? _errorMessage;

  // Getters públicos (solo lectura para la Vista)
  RiskViewState get state => _state;
  PrediccionRiesgo? get prediccion => _prediccion;
  String? get errorMessage => _errorMessage;

  /// True si hay una carga en progreso
  bool get isLoading => _state == RiskViewState.loading;

  /// True si hay datos para mostrar
  bool get hasData => _state == RiskViewState.success && _prediccion != null;

  /// True si hay error
  bool get hasError => _state == RiskViewState.error;

  /// Porcentaje de riesgo formateado para UI (ej. "82.9%")
  String get riesgoPorcentaje {
    if (_prediccion == null) return '--%';
    return '${(_prediccion!.probabilidadRiesgo * 100).toStringAsFixed(1)}%';
  }

  /// Nivel de riesgo actual
  NivelRiesgo? get nivelRiesgo => _prediccion?.nivelRiesgo;

  /// Color hex del nivel de riesgo
  String? get colorRiesgoHex => _prediccion?.colorHex;

  /// Label legible del nivel de riesgo
  String get nivelRiesgoLabel => _prediccion?.nivelRiesgo.label ?? 'Desconocido';

  /// Descripción del nivel de riesgo
  String get nivelRiesgoDescripcion => _prediccion?.nivelRiesgo.descripcion ?? '';

  /// Promedio formateado (ej. "7.3 / 20")
  String get calificacionFormateada {
    if (_prediccion == null) return '--';
    return '${_prediccion!.calificacionHistoricaPromedio.toStringAsFixed(1)} / 20';
  }

  /// Días de inactividad formateados
  String get inactividadFormateada {
    if (_prediccion == null) return '--';
    return '${_prediccion!.diasInactividadConsecutivos} días';
  }

  /// Fecha de corte formateada legible
  String get fechaCorteFormateada {
    if (_prediccion == null) return '--';
    try {
      final date = DateTime.parse(_prediccion!.fechaCorte);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return _prediccion!.fechaCorte;
    }
  }

  RiskViewModel({
    required RiskApiService apiService,
    String estudianteId = 'EST-0001',
    String cursoId = 'CUR-007',
  })  : _apiService = apiService,
        _estudianteId = estudianteId,
        _cursoId = cursoId;

  /// Carga la predicción de riesgo para el estudiante y curso configurados.
  Future<void> cargarPrediccion() async {
    await _cargarPrediccionPara(_estudianteId, _cursoId);
  }

  /// Carga la predicción para un estudiante y curso específicos
  Future<void> _cargarPrediccionPara(String idEstudiante, String idCurso) async {
    // Evitar llamadas concurrentes
    if (_state == RiskViewState.loading) return;

    _setState(RiskViewState.loading);

    try {
      final prediccion = await _apiService.fetchPrediccionRiesgo(
        idEstudiante: idEstudiante,
        idCurso: idCurso,
      );

      _prediccion = prediccion;
      _errorMessage = null;
      _setState(RiskViewState.success);
    } catch (e) {
      _errorMessage = _mapErrorToMessage(e);
      _prediccion = null;
      _setState(RiskViewState.error);
    }
  }

  /// Reintenta la carga tras un error
  Future<void> reintentar() async {
    await cargarPrediccion();
  }

  /// Actualiza el estado y notifica listeners
  void _setState(RiskViewState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Mapea excepciones técnicas a mensajes amigables para el usuario
  String _mapErrorToMessage(Object error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('timeout') || errorStr.contains('connection')) {
      return 'Error de conexión. Verifica tu internet e inténtalo de nuevo.';
    }
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'No se encontró información para este curso.';
    }
    if (errorStr.contains('500') || errorStr.contains('server')) {
      return 'Error del servidor. Intenta más tarde.';
    }
    if (errorStr.contains('format') || errorStr.contains('parse')) {
      return 'Error procesando los datos. Contacta a soporte.';
    }

    return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
  }

  @override
  void dispose() {
    // Limpieza si fuera necesario (streams, timers, etc.)
    super.dispose();
  }
}