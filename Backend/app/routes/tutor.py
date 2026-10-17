from fastapi import APIRouter, HTTPException, status
import os
import json
import requests
from typing import List, Optional

from app.models import TutorChatRequest, TutorChatResponse, ChatMessageModel
from app.database import get_db_connection

router = APIRouter(prefix="/api/tutor", tags=["Tutor Inteligente IA"])

# Prompt base pedagógico para Rumbo Tutor (Andamiaje cognitivo)
SYSTEM_PROMPT = """Eres "Rumbo Tutor", un asistente pedagógico inteligente en la app móvil Rumbo (UNMSM FISI).

REGLAS ESTRICTAS DE CONVERSACIÓN:
1. BREVEDAD PARA MÓVIL: Responde en MÁXIMO 2 o 3 párrafos cortos y directos (menos de 70 palabras en total). Los estudiantes leen en pantallas pequeñas y no toleran textos largos ni sermones.
2. NO REPITAS EL SALUDO NI EL DIAGNÓSTICO EN CADA MENSAJE: Si la conversación ya empezó, ve directo al grano. NO vuelvas a decir "Hola Joseph, qué gusto saludarte, veo que estás en riesgo bajo y llevas 3 días...". Eso fastidia al usuario. Usa el contexto solo como trasfondo silencioso para responder lo que te preguntan.
3. RESPONDE EXACTAMENTE A LA PREGUNTA: Si te dicen "No me concentro bien", da 2 tips prácticos inmediatos (ej: Pomodoro de 20 min, quitar notificaciones). Si te preguntan "¿Qué tareas tengo?", enumera la tarea y la fecha en 1 línea.
4. TONO: Cercano, empático, ágil y universitario.
"""

def _generar_respuesta_local(mensaje: str, nombre: str, curso_nombre: Optional[str], nivel_riesgo: str, dias_inact: int, tareas_pen: int) -> tuple[str, List[str]]:
    """Motor de andamiaje cognitivo adaptativo local (funciona sin internet / fallback offline)."""
    msg = mensaje.lower().strip()
    
    # Contexto del curso
    ref_curso = f" en **{curso_nombre}**" if curso_nombre else ""
    
    if any(k in msg for k in ["hola", "buenas", "saludos", "iniciar"]):
        txt = (
            f"¡Hola, {nombre}! Soy **Rumbo Tutor**, tu asistente académico inteligente.\n\n"
            f"Actualmente veo que tu estado general{ref_curso} está clasificado en nivel **{nivel_riesgo}**.\n\n"
            f"¿En qué te puedo apoyar hoy? Puedo ayudarte a repasar temas clave, organizar tu semana de entregas o armar un plan para asegurar el ciclo."
        )
        sugs = [
            "¿Cómo puedo mejorar mi rendimiento?",
            "Ayúdame a organizar un plan de estudio",
            "¿Qué tareas tengo pendientes?"
        ]
        return txt, sugs

    elif any(k in msg for k in ["riesgo", "bajar", "mejorar", "desaprobar", "rezago", "seguro"]):
        if nivel_riesgo == "CRITICO":
            txt = (
                f"Entiendo tu preocupación, {nombre}. Estar en **Riesgo Crítico** significa que debemos actuar de inmediato:\n\n"
                f"1. **Entra hoy a Moodle:** Tienes {tareas_pen} tarea(s) pendiente(s) y {dias_inact} día(s) de inactividad.\n"
                f"2. **Pide prórroga o feedback:** Escríbele al docente asignado explicando tu situación.\n"
                f"3. **Técnica Pomodoro:** Dedica 2 bloques de 25 minutos hoy mismo a avanzar el módulo pendiente.\n\n"
                f"Recuerda que cada entrega suma puntos directos al promedio final."
            )
        elif nivel_riesgo == "MODERADO":
            txt = (
                f"Tu nivel es **Moderado**{ref_curso}, lo que significa que estás a tiempo de nivelarte sin presión extrema:\n\n"
                f"• Si entregas las **{tareas_pen} tarea(s) pendiente(s)** esta semana, tu probabilidad de riesgo descenderá a zona Segura.\n"
                f"• Te recomiendo ingresar al aula virtual al menos 3 veces por semana para que el algoritmo registre actividad constante."
            )
        else:
            txt = (
                f"¡Vas por buen camino, {nombre}! Tu nivel es **{nivel_riesgo}** (Zona Segura){ref_curso}.\n\n"
                f"• Tu ritmo de ingresos y calificaciones es estable.\n"
                f"• Para mantenerte así, revisa las lecturas complementarias y participa en los foros de debate del curso."
            )
        sugs = [
            "Arma un horario de 48 horas",
            "¿Cuáles son los temas más difíciles?",
            "Recomiéndame una técnica de estudio"
        ]
        return txt, sugs

    elif any(k in msg for k in ["plan", "organizar", "tiempo", "horario", "estudio", "pomodoro"]):
        txt = (
            f"Aquí tienes un **Plan de Acción Adaptativo** para{ref_curso}:\n\n"
            f"📅 **Bloque 1 (Hoy - 45 min):**\n"
            f"- Descarga las diapositivas y rúbrica de la tarea pendiente.\n"
            f"- Define el esquema o borrador inicial.\n\n"
            f"📅 **Bloque 2 (Mañana - 60 min):**\n"
            f"- Desarrolla la parte práctica o ejercicios.\n"
            f"- Consulta tus dudas puntuales por los foros del curso.\n\n"
            f"📅 **Bloque 3 (Día de entrega - 30 min):**\n"
            f"- Revisa contra la rúbrica y sube tu archivo a MoodleCloud con anticipación."
        )
        sugs = [
            "Explícame la técnica Pomodoro",
            "¿Cómo aplico esto a desarrollo de software?",
            "¿Qué hago si no entiendo el tema?"
        ]
        return txt, sugs

    elif any(k in msg for k in ["tarea", "entregas", "deber"]):
        txt = (
            f"Sobre tus entregas académicas{ref_curso}:\n\n"
            f"• Registras **{tareas_pen} tarea(s) pendiente(s)** en la plataforma.\n"
            f"• Registrar entregas a tiempo reduce drásticamente la tasa de fricción cognitiva en el modelo predictivo.\n\n"
            f"¿Deseas que revisemos los conceptos teóricos de esa actividad?"
        )
        sugs = [
            "¿Qué pasa si entrego con retraso?",
            "Dame tips para avanzar más rápido",
            "Ir a Moodle para subirla"
        ]
        return txt, sugs

    # Respuesta pedagógica general adaptada
    txt = (
        f"Excelente consulta, {nombre}. Desde la perspectiva de aprendizaje en FISI{ref_curso}:\n\n"
        f"Para dominar este aspecto, el mejor método es descomponer el problema en componentes pequeños y validar cada paso con pruebas prácticas.\n\n"
        f"¿Te gustaría que profundicemos en los conceptos técnicos o prefieres una estrategia para aplicarlo a tus tareas de Moodle?"
    )
    sugs = [
        "Profundicemos en los conceptos",
        "¿Cómo lo aplico en mi curso?",
        "Ver mi estado de riesgo actual"
    ]
    return txt, sugs

@router.post("/chat", response_model=TutorChatResponse)
def chat_with_tutor(req: TutorChatRequest):
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        
        # 1. Obtener datos del estudiante
        cur.execute("SELECT * FROM estudiantes WHERE id_estudiante = ? LIMIT 1;", (req.id_estudiante,))
        est = cur.fetchone()
        nombre = est["nombre"] if est else "Estudiante"

        # 2. Obtener datos del curso y predicción si se especificó
        curso_nombre = None
        nivel_riesgo = "BAJO"
        dias_inact = 2
        tareas_pen = 1

        if req.id_curso:
            cur.execute("SELECT * FROM cursos WHERE id_curso = ? LIMIT 1;", (req.id_curso,))
            c_row = cur.fetchone()
            if c_row:
                curso_nombre = c_row["nombre"]

            cur.execute("""
            SELECT * FROM predicciones 
            WHERE id_curso = ? AND id_estudiante = ? 
            ORDER BY id DESC LIMIT 1;
            """, (req.id_curso, req.id_estudiante))
            p_row = cur.fetchone()
            if p_row:
                nivel_riesgo = p_row["nivel_riesgo"] or "BAJO"

            cur.execute("""
            SELECT * FROM metricas 
            WHERE id_curso = ? AND id_estudiante = ? 
            ORDER BY id DESC LIMIT 1;
            """, (req.id_curso, req.id_estudiante))
            m_row = cur.fetchone()
            if m_row:
                dias_inact = m_row["dias_inactividad"] or 2
                tareas_pen = m_row["tareas_pendientes"] or 1
        else:
            # Si no hay curso seleccionado, tomar el de mayor riesgo
            cur.execute("""
            SELECT c.nombre, p.nivel_riesgo, m.dias_inactividad, m.tareas_pendientes
            FROM predicciones p
            JOIN cursos c ON p.id_curso = c.id_curso
            LEFT JOIN metricas m ON p.id_curso = m.id_curso AND p.id_estudiante = m.id_estudiante
            WHERE p.id_estudiante = ?
            ORDER BY p.porcentaje DESC LIMIT 1;
            """, (req.id_estudiante,))
            top_row = cur.fetchone()
            if top_row:
                curso_nombre = top_row["nombre"]
                nivel_riesgo = top_row["nivel_riesgo"] or "BAJO"
                dias_inact = top_row["dias_inactividad"] or 2
                tareas_pen = top_row["tareas_pendientes"] or 1
    finally:
        conn.close()

    # Cargar GEMINI_API_KEY desde .env si no está en os.environ
    gemini_key = os.getenv("GEMINI_API_KEY")
    if not gemini_key:
        from pathlib import Path
        env_p = Path(__file__).resolve().parent.parent.parent / ".env"
        if env_p.exists():
            for line in env_p.read_text(encoding="utf-8").splitlines():
                if line.startswith("GEMINI_API_KEY="):
                    gemini_key = line.split("=", 1)[1].strip()
                    os.environ["GEMINI_API_KEY"] = gemini_key
                    break

    if gemini_key:
        try:
            # Modelo rápido y disponible con la API Key actual
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key={gemini_key}"
            # Formatear el historial de chat para Gemini
            contents_payload = []
            
            # Contexto inicial silencioso como mensaje de sistema
            system_instruction = (
                f"{SYSTEM_PROMPT}\n\n"
                f"[DATOS SILENCIOSOS DEL ALUMNO - NO REPETIR EN CADA MENSAJE]:\n"
                f"Nombre: {nombre} | Curso: {curso_nombre or 'General'} | Nivel de Riesgo: {nivel_riesgo} | "
                f"Inactividad: {dias_inact} días | Tareas pendientes: {tareas_pen}.\n"
                f"REGLA DE ORO: Responde directo y al grano a lo que pregunta el alumno en MÁXIMO 40 a 60 palabras. "
                f"NUNCA comiences diciendo 'Hola Joseph, qué gusto saludarte, veo que tu nivel es bajo...'. Sé natural y breve."
            )

            # Si hay historial previo, agregarlo para mantener el hilo
            if req.historial and len(req.historial) > 1:
                for h in req.historial[-5:-1]:
                    role = "user" if h.rol == "user" else "model"
                    contents_payload.append({
                        "role": role,
                        "parts": [{"text": h.contenido}]
                    })

            # Mensaje actual del alumno con recordatorio de brevedad
            alumno_prompt = (
                f"{req.mensaje}\n\n"
                f"(Instrucción obligatoria: Responde en 2 o 3 líneas concisas, sin saludos largos ni repetir mi diagnóstico)."
            )
            contents_payload.append({
                "role": "user",
                "parts": [{"text": alumno_prompt}]
            })

            payload = {
                "systemInstruction": {
                    "parts": [{"text": system_instruction}]
                },
                "contents": contents_payload,
                "generationConfig": {
                    "maxOutputTokens": 180,
                    "temperature": 0.6
                }
            }
            resp = requests.post(url, json=payload, timeout=14)
            if resp.status_code == 200:
                data = resp.json()
                text_gemini = data["candidates"][0]["content"]["parts"][0]["text"]
                return TutorChatResponse(
                    respuesta=text_gemini,
                    sugerencias=[
                        "¿Cómo organizo mis horarios para este curso?",
                        "Explícame los conceptos clave",
                        "Dame un plan de estudio personalizado"
                    ],
                    curso_contexto=curso_nombre,
                    nivel_riesgo=nivel_riesgo
                )
        except Exception as e:
            pass  # Fallback automático

    # Motor de andamiaje pedagógico adaptativo local
    respuesta_txt, sugerencias = _generar_respuesta_local(
        req.mensaje, nombre, curso_nombre, nivel_riesgo, dias_inact, tareas_pen
    )

    return TutorChatResponse(
        respuesta=respuesta_txt,
        sugerencias=sugerencias,
        curso_contexto=curso_nombre,
        nivel_riesgo=nivel_riesgo
    )
