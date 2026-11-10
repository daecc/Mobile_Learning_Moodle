Add-Type -AssemblyName System.Drawing

function Draw-RoundedRectangle {
    param(
        [System.Drawing.Graphics]$g,
        [System.Drawing.Brush]$brush,
        [System.Drawing.Pen]$pen,
        [float]$x, [float]$y, [float]$width, [float]$height, [float]$radius
    )
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $width - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $width - $d, $y + $height - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $height - $d, $d, $d, 90, 90)
    $path.CloseFigure()

    if ($brush) { $g.FillPath($brush, $path) }
    if ($pen) { $g.DrawPath($pen, $path) }
}

function Draw-Arrow {
    param(
        [System.Drawing.Graphics]$g,
        [System.Drawing.Pen]$pen,
        [System.Drawing.Brush]$brush,
        [float]$x1, [float]$y1, [float]$x2, [float]$y2,
        [string]$label = "",
        [System.Drawing.Font]$font = $null,
        [System.Drawing.Brush]$labelBrush = $null,
        [float]$labelOffsetY = -18
    )
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    
    $angle = [Math]::Atan2($y2 - $y1, $x2 - $x1)
    $arrowLength = 13
    $arrowAngle = [Math]::PI / 6
    
    $px1 = $x2 - $arrowLength * [Math]::Cos($angle - $arrowAngle)
    $py1 = $y2 - $arrowLength * [Math]::Sin($angle - $arrowAngle)
    $px2 = $x2 - $arrowLength * [Math]::Cos($angle + $arrowAngle)
    $py2 = $y2 - $arrowLength * [Math]::Sin($angle + $arrowAngle)
    
    $arrowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $arrowPath.AddPolygon([System.Drawing.PointF[]]@(
        (New-Object System.Drawing.PointF($x2, $y2)),
        (New-Object System.Drawing.PointF($px1, $py1)),
        (New-Object System.Drawing.PointF($px2, $py2))
    ))
    $g.FillPath($brush, $arrowPath)
    
    if ($label -ne "" -and $font -ne $null -and $labelBrush -ne $null) {
        $midX = ($x1 + $x2) / 2
        $midY = ($y1 + $y2) / 2 + $labelOffsetY
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $g.DrawString($label, $font, $labelBrush, $midX, $midY, $sf)
    }
}

# ==============================================================================
# DIAGRAMA 1: ARQUITECTURA MULTICAPA DEL BACKEND
# ==============================================================================
$w = 2100
$h = 1350
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Fondo claro blanco puro
$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 250, 252))
$g.FillRectangle($bgBrush, 0, 0, $w, $h)

# Fuentes
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$fontSubtitle = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Regular)
$fontSection = New-Object System.Drawing.Font("Segoe UI", 13.5, [System.Drawing.FontStyle]::Bold)
$fontBoxHeader = New-Object System.Drawing.Font("Segoe UI", 11.5, [System.Drawing.FontStyle]::Bold)
$fontBoxText = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$fontLabel = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

# Brochas
$textDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))
$textMuted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 116, 139))
$penArrow = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(51, 65, 85), 2.2)
$brushArrow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(51, 65, 85))

# Cabecera
$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("ARQUITECTURA MULTICAPA DEL BACKEND - RUMBO", $fontTitle, $textDark, ($w / 2), 35, $sfCenter)
$g.DrawString("Microservicio REST FastAPI + Machine Learning Supervisado + Integracion MoodleCloud LMS", $fontSubtitle, $textMuted, ($w / 2), 85, $sfCenter)

# --- COLUMNA 1: CLIENTE MOVIL ---
$bFlutterBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(238, 242, 255))
$pFlutterBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(99, 102, 241), 2)
$tFlutter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(67, 56, 202))

Draw-RoundedRectangle $g $bFlutterBg $pFlutterBorder 50 150 260 1140 18
$g.DrawString("CAPA PRESENTACION", $fontSection, $tFlutter, 180, 175, $sfCenter)
$g.DrawString("Cliente Movil Flutter", $fontSubtitle, $textMuted, 180, 205, $sfCenter)

$bCardWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$pCardBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(226, 232, 240), 1.5)

$flutterComponents = @(
    @{ Title = "Arquitectura MVVM"; Text = "- Views & Screens`n- ViewModels (Provider)`n- ApiService (Core HTTP)`n- Modelos DTOs Tipados" },
    @{ Title = "Modulos de Usuario"; Text = "- Login institucional`n- Dashboard de Cursos`n- Tacometro de Riesgo H6`n- Paneles XAI Explicables`n- Tutor Virtual Chat" },
    @{ Title = "Resiliencia Offline"; Text = "- Mecanismo Fallback`n- Datasets de prueba`n- Cache reactiva Provider" }
)
$yOff = 260
foreach ($fc in $flutterComponents) {
    Draw-RoundedRectangle $g $bCardWhite $pCardBorder 70 $yOff 220 180 12
    $g.DrawString($fc.Title, $fontBoxHeader, $tFlutter, 180, ($yOff + 15), $sfCenter)
    $g.DrawString($fc.Text, $fontBoxText, $textDark, 85, ($yOff + 50))
    $yOff += 210
}

# --- COLUMNA 2: CONTROLADORES REST (FastAPI) ---
$bApiBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(236, 253, 245))
$pApiBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(16, 185, 129), 2)
$tApi = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(4, 120, 87))

Draw-RoundedRectangle $g $bApiBg $pApiBorder 380 150 350 1140 18
$g.DrawString("CONTROLADORES REST", $fontSection, $tApi, 555, 175, $sfCenter)
$g.DrawString("FastAPI (main.py y routes/)", $fontSubtitle, $textMuted, 555, 205, $sfCenter)

$routesComponents = @(
    @{ Title = "main.py"; Sub = "Nucleo y Middleware"; Text = "- CORSMiddleware (Permisivo)`n- Uvicorn ASGI Server`n- Documentacion /docs OpenAPI" },
    @{ Title = "auth.py"; Sub = "/api/auth/login"; Text = "- Autenticacion MoodleCloud`n- Generacion de tokens`n- Inicializacion de perfil" },
    @{ Title = "cursos.py"; Sub = "/api/estudiantes"; Text = "- GET /{id}/cursos`n- Ordenamiento prioritario H6`n- GET /{id}/cursos/{c}/riesgo`n- Metricas y Explicabilidad XAI" },
    @{ Title = "predict.py"; Sub = "/api/predict"; Text = "- Inferencia directa por vector`n- Simulacion estocastica 10 feats" },
    @{ Title = "tutor.py"; Sub = "/api/tutor/chat"; Text = "- Interfaz conversacional`n- Andamiaje pedagogico hibrido" }
)
$yOff = 260
foreach ($rc in $routesComponents) {
    Draw-RoundedRectangle $g $bCardWhite $pCardBorder 400 $yOff 310 145 12
    $g.DrawString($rc.Title, $fontBoxHeader, $tApi, 415, ($yOff + 12))
    $g.DrawString($rc.Sub, $fontBoxText, $textMuted, 415, ($yOff + 34))
    $g.DrawString($rc.Text, $fontBoxText, $textDark, 415, ($yOff + 58))
    $yOff += 170
}

# --- COLUMNA 3: SERVICIOS Y LOGICA ---
$bServBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 249, 255))
$pServBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(14, 165, 233), 2)
$tServ = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(3, 105, 161))

Draw-RoundedRectangle $g $bServBg $pServBorder 800 150 370 1140 18
$g.DrawString("LOGICA DE NEGOCIO", $fontSection, $tServ, 985, 175, $sfCenter)
$g.DrawString("Servicios (services/)", $fontSubtitle, $textMuted, 985, 205, $sfCenter)

$servComponents = @(
    @{ 
        Title = "moodle_service.py"; 
        Sub = "MoodleRestClient y Orquestador"; 
        Text = "- Consumo Web Services Moodle`n- core_webservice_get_site_info`n- core_enrol_get_users_courses`n- gradereport_user_get_grade_items`n- core_course_get_contents`n- Calculo de dias de inactividad`n- Sincronizacion transaccional SQLite`n- Fallback de contingencia" 
    },
    @{ 
        Title = "ml_service.py"; 
        Sub = "Motor de Inferencia Scikit-Learn"; 
        Text = "- Carga de artefactos model.joblib`n- Estandarizacion StandardScaler`n- Inferencia sigmoide probabilistica`n- Bandas de riesgo: Bajo/Mod/Critico`n- Generador tarjetas metacognitivas`n- Formulacion factores XAI (Nielsen)" 
    },
    @{ 
        Title = "data_service.py"; 
        Sub = "Repositorio y Modo Demo"; 
        Text = "- Consultas agregadas de cursos`n- Soporte a modo offline universitario" 
    }
)
$yOff = 260
foreach ($sc in $servComponents) {
    $hBox = if ($sc.Title -eq "moodle_service.py") { 260 } elseif ($sc.Title -eq "ml_service.py") { 230 } else { 135 }
    Draw-RoundedRectangle $g $bCardWhite $pCardBorder 820 $yOff 330 $hBox 12
    $g.DrawString($sc.Title, $fontBoxHeader, $tServ, 835, ($yOff + 12))
    $g.DrawString($sc.Sub, $fontBoxText, $textMuted, 835, ($yOff + 34))
    $g.DrawString($sc.Text, $fontBoxText, $textDark, 835, ($yOff + 58))
    $yOff += $hBox + 25
}

# --- COLUMNA 4: PERSISTENCIA Y MODELOS ---
$bDataBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 252, 232))
$pDataBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(234, 179, 8), 2)
$tData = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(161, 98, 7))

Draw-RoundedRectangle $g $bDataBg $pDataBorder 1240 150 330 1140 18
$g.DrawString("PERSISTENCIA Y DATOS", $fontSection, $tData, 1405, 175, $sfCenter)
$g.DrawString("SQLite WAL y Modelos Pydantic", $fontSubtitle, $textMuted, 1405, 205, $sfCenter)

$dataComponents = @(
    @{ 
        Title = "database.py y rumbo.db"; 
        Sub = "Base de Datos SQLite (Modo WAL)"; 
        Text = "- PRAGMA journal_mode=WAL`n- Concurrencia lecturas/escrituras`n- Tabla: estudiantes`n- Tabla: cursos (PK compuesta)`n- Tabla: metricas (telemetria)`n- Tabla: predicciones (XAI y Riesgo)" 
    },
    @{ 
        Title = "models.py"; 
        Sub = "Esquemas Pydantic v2"; 
        Text = "- LoginRequest / LoginResponse`n- StudentCoursesResponse`n- RiskDetailResponse`n- MetacognitiveStat`n- FactoresBundleModel (XAI)`n- TutorChatRequest / Response" 
    },
    @{ 
        Title = "ml_models/"; 
        Sub = "Artefactos Serializados Joblib"; 
        Text = "- model.joblib (Regresion Logistica)`n- scaler.joblib (StandardScaler)`n- features.joblib (10 variables)" 
    }
)
$yOff = 260
foreach ($dc in $dataComponents) {
    $hBox = if ($dc.Title -like "*database*") { 220 } elseif ($dc.Title -eq "models.py") { 210 } else { 160 }
    Draw-RoundedRectangle $g $bCardWhite $pCardBorder 1260 $yOff 290 $hBox 12
    $g.DrawString($dc.Title, $fontBoxHeader, $tData, 1275, ($yOff + 12))
    $g.DrawString($dc.Sub, $fontBoxText, $textMuted, 1275, ($yOff + 34))
    $g.DrawString($dc.Text, $fontBoxText, $textDark, 1275, ($yOff + 58))
    $yOff += $hBox + 25
}

# --- COLUMNA 5: SERVICIOS EXTERNOS ---
$bExtBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(250, 245, 255))
$pExtBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(168, 85, 247), 2)
$tExt = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(126, 34, 206))

Draw-RoundedRectangle $g $bExtBg $pExtBorder 1640 150 410 1140 18
$g.DrawString("SERVICIOS EXTERNOS", $fontSection, $tExt, 1845, 175, $sfCenter)
$g.DrawString("Institucional y Nube", $fontSubtitle, $textMuted, 1845, 205, $sfCenter)

$extComponents = @(
    @{ 
        Title = "MoodleCloud LMS"; 
        Sub = "Aula Virtual UNMSM"; 
        Text = "- Endpoint /login/token.php`n- Servidor REST WebService`n- Tokens y roles de alumnos`n- Libro de calificaciones`n- Registro de accesos (logs)" 
    },
    @{ 
        Title = "Google Gemini API"; 
        Sub = "Modelo Generativo Nube"; 
        Text = "- gemini-flash-latest`n- Prompt pedagogico movil`n- Andamiaje cognitivo adaptativo`n- Contexto silencioso del alumno`n- Respuestas breves (< 70 palabras)" 
    }
)
$yOff = 280
foreach ($ec in $extComponents) {
    Draw-RoundedRectangle $g $bCardWhite $pCardBorder 1665 $yOff 360 250 12
    $g.DrawString($ec.Title, $fontBoxHeader, $tExt, 1845, ($yOff + 15), $sfCenter)
    $g.DrawString($ec.Sub, $fontBoxText, $textMuted, 1845, ($yOff + 38), $sfCenter)
    $g.DrawString($ec.Text, $fontBoxText, $textDark, 1685, ($yOff + 70))
    $yOff += 320
}

# --- FLECHAS LIMPIAS (SIN CRUCES RAROS) ---
Draw-Arrow $g $penArrow $brushArrow 310 390 380 390 "POST /login" $fontLabel $textDark
Draw-Arrow $g $penArrow $brushArrow 310 610 380 610 "GET /cursos" $fontLabel $textDark
Draw-Arrow $g $penArrow $brushArrow 310 980 380 980 "POST /chat" $fontLabel $textDark

Draw-Arrow $g $penArrow $brushArrow 730 430 800 430 "sync_and_predict" $fontLabel $textDark
Draw-Arrow $g $penArrow $brushArrow 730 810 800 680 "predecir_vector" $fontLabel $textDark
Draw-Arrow $g $penArrow $brushArrow 730 1020 1665 680 "Prompt Gemini" $fontLabel $textDark -12

Draw-Arrow $g $penArrow $brushArrow 1170 380 1665 380 "Web Services REST" $fontLabel $textDark -14
Draw-Arrow $g $penArrow $brushArrow 1170 470 1240 400 "Transaccion WAL" $fontLabel $textDark -12
Draw-Arrow $g $penArrow $brushArrow 1170 650 1240 850 "joblib.load" $fontLabel $textDark -12

$outPath1 = "c:\Users\CESAR\Desktop\PROYECTO TALLER MOVIL\Mobile_Learning_Moodle\Docs\diagramas\diagrama_1_arquitectura_backend.png"
$bmp.Save($outPath1, [System.Drawing.Imaging.ImageFormat]::Png)

# ==============================================================================
# DIAGRAMA 2: DIAGRAMA DE SECUENCIA
# ==============================================================================
$w2 = 2100
$h2 = 1450
$bmp2 = New-Object System.Drawing.Bitmap($w2, $h2)
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

$g2.FillRectangle($bgBrush, 0, 0, $w2, $h2)

$g2.DrawString("DIAGRAMA DE SECUENCIA: FLUJO DE INGESTA, PREDICCION Y CONSULTA", $fontTitle, $textDark, ($w2 / 2), 35, $sfCenter)
$g2.DrawString("Interaccion sincronica entre Aplicacion Movil, FastAPI, MoodleCloud, Scikit-Learn y SQLite", $fontSubtitle, $textMuted, ($w2 / 2), 85, $sfCenter)

$actors = @(
    @{ Name = "Estudiante`n(Flutter App)"; X = 150; Color = [System.Drawing.Color]::FromArgb(99, 102, 241) },
    @{ Name = "auth.py`n(FastAPI Router)"; X = 430; Color = [System.Drawing.Color]::FromArgb(16, 185, 129) },
    @{ Name = "moodle_service.py`n(Orquestador)"; X = 730; Color = [System.Drawing.Color]::FromArgb(14, 165, 233) },
    @{ Name = "MoodleCloud LMS`n(Web Services API)"; X = 1050; Color = [System.Drawing.Color]::FromArgb(168, 85, 247) },
    @{ Name = "ml_service.py`n(Scikit-Learn ML)"; X = 1360; Color = [System.Drawing.Color]::FromArgb(234, 179, 8) },
    @{ Name = "rumbo.db`n(SQLite WAL)"; X = 1660; Color = [System.Drawing.Color]::FromArgb(249, 115, 22) },
    @{ Name = "cursos.py`n(FastAPI Router)"; X = 1930; Color = [System.Drawing.Color]::FromArgb(16, 185, 129) }
)

$penLifeline = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(203, 213, 225), 2)
$penLifeline.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash

foreach ($act in $actors) {
    $x = $act.X
    $bAct = New-Object System.Drawing.SolidBrush($act.Color)
    $bActBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $pAct = New-Object System.Drawing.Pen($act.Color, 2)
    
    Draw-RoundedRectangle $g2 $bActBg $pAct ($x - 85) 140 170 70 10
    $g2.DrawString($act.Name, $fontBoxHeader, $bAct, $x, 152, $sfCenter)
    $g2.DrawLine($penLifeline, $x, 220, $x, 1370)
}

$steps = @(
    @{ From = 150; To = 430; Y = 250; Num = "1"; Text = "POST /api/auth/login (codigo, contrasena institucional)"; Return = $false; Self = $false },
    @{ From = 430; To = 730; Y = 320; Num = "2"; Text = "sync_and_predict(username, password)"; Return = $false; Self = $false },
    @{ From = 730; To = 1050; Y = 390; Num = "3"; Text = "POST /login/token.php (servicio: moodle_mobile_app)"; Return = $false; Self = $false },
    @{ From = 1050; To = 730; Y = 460; Num = "4"; Text = "Retorna wstoken oficial de sesion Moodle"; Return = $true; Self = $false },
    @{ From = 730; To = 1050; Y = 530; Num = "5"; Text = "Web Services: get_site_info, get_courses, get_grades, get_contents"; Return = $false; Self = $false },
    @{ From = 1050; To = 730; Y = 610; Num = "6"; Text = "Retorna telemetria real: ultimo acceso, tareas pendientes y notas"; Return = $true; Self = $false },
    @{ From = 730; To = 730; Y = 680; Num = "7"; Text = "Computa dias inactividad, tasa rezago y vector de 10 variables"; Return = $false; Self = $true },
    @{ From = 730; To = 1360; Y = 750; Num = "8"; Text = "predecir_vector(vector_10_variables)"; Return = $false; Self = $false },
    @{ From = 1360; To = 1360; Y = 810; Num = "9"; Text = "StandardScaler.transform() + LogisticRegression.predict_proba()"; Return = $false; Self = $true },
    @{ From = 1360; To = 730; Y = 880; Num = "10"; Text = "Retorna probabilidad, nivel de riesgo (Bajo/Mod/Crit) y factores XAI"; Return = $true; Self = $false },
    @{ From = 730; To = 1660; Y = 960; Num = "11"; Text = "Transaccion atomica: actualiza tablas estudiantes, cursos, metricas y predicciones"; Return = $false; Self = $false },
    @{ From = 1660; To = 730; Y = 1020; Num = "12"; Text = "Confirmacion de persistencia WAL (commit)"; Return = $true; Self = $false },
    @{ From = 730; To = 430; Y = 1080; Num = "13"; Text = "Retorna perfil validado y token de sesion"; Return = $true; Self = $false },
    @{ From = 430; To = 150; Y = 1140; Num = "14"; Text = "LoginResponse 200 OK: token + StudentProfile"; Return = $true; Self = $false },
    @{ From = 150; To = 1930; Y = 1220; Num = "15"; Text = "GET /api/estudiantes/{id}/cursos (Dashboard de asignaturas)"; Return = $false; Self = $false },
    @{ From = 1930; To = 1660; Y = 1280; Num = "16"; Text = "SELECT cursos y predicciones (ORDER BY prioridad riesgo H6)"; Return = $false; Self = $false },
    @{ From = 1930; To = 150; Y = 1350; Num = "17"; Text = "StudentCoursesResponse: Lista clasificada y distribucion para el alumno"; Return = $true; Self = $false }
)

$fontStepNum = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$fontStepText = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$bStepNum = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$bCircle = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(37, 99, 235))

foreach ($st in $steps) {
    $y = $st.Y
    if ($st.Self) {
        $x = $st.From
        $pSelf = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(37, 99, 235), 2)
        $g2.DrawLine($pSelf, $x, $y, $x + 40, $y)
        $g2.DrawLine($pSelf, $x + 40, $y, $x + 40, $y + 30)
        $g2.DrawLine($pSelf, $x + 40, $y + 30, $x, $y + 30)
        
        $g2.FillEllipse($bCircle, $x + 48, $y + 5, 22, 22)
        $g2.DrawString($st.Num, $fontStepNum, $bStepNum, $x + 59, $y + 9, $sfCenter)
        $g2.DrawString($st.Text, $fontStepText, $textDark, $x + 78, $y + 9)
    }
    else {
        $pLine = if ($st.Return) {
            $pRet = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 116, 139), 2)
            $pRet.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
            $pRet
        } else {
            New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30, 41, 59), 2)
        }
        $bArr = if ($st.Return) { New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 116, 139)) } else { $textDark }
        
        Draw-Arrow $g2 $pLine $bArr $st.From $y $st.To $y
        
        $midX = ($st.From + $st.To) / 2
        $g2.FillEllipse($bCircle, $midX - 110, $y - 20, 22, 22)
        $g2.DrawString($st.Num, $fontStepNum, $bStepNum, $midX - 99, $y - 16, $sfCenter)
        $g2.DrawString($st.Text, $fontStepText, $textDark, $midX - 80, $y - 17)
    }
}

$outPath2 = "c:\Users\CESAR\Desktop\PROYECTO TALLER MOVIL\Mobile_Learning_Moodle\Docs\diagramas\diagrama_2_secuencia_flujo.png"
$bmp2.Save($outPath2, [System.Drawing.Imaging.ImageFormat]::Png)

Write-Host "Diagramas generados y actualizados con éxito."
