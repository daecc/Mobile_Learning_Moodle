Add-Type -AssemblyName System.Drawing

$w = 1750
$h = 980
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Fondo blanco puro
$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$g.FillRectangle($bgBrush, 0, 0, $w, $h)

# Fuentes
$fontSubTitle = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
$fontNode = New-Object System.Drawing.Font("Segoe UI", 11.5, [System.Drawing.FontStyle]::Regular)
$fontBadge = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

# Brochas y Lapiceros
$pSubgraph = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(203, 213, 225), 1.5) # Slate 300
$bSubgraph = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 250, 252)) # Slate 50
$tSubgraph = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(71, 85, 105)) # Slate 600

$pNode = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30, 41, 59), 1.8) # Slate 800
$bNode = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$tNode = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))

$pLine = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(51, 65, 85), 1.8)
$bArrow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(51, 65, 85))

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

function Draw-Box {
    param($x, $y, $width, $height, $text)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $r = 5
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $width - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $width - $d, $y + $height - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $height - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    
    $g.FillPath($bNode, $path)
    $g.DrawPath($pNode, $path)
    
    $rect = New-Object System.Drawing.RectangleF($x, $y, $width, $height)
    $g.DrawString($text, $fontNode, $tNode, $rect, $sfCenter)
}

function Draw-Subg {
    param($x, $y, $width, $height, $title)
    $g.FillRectangle($bSubgraph, $x, $y, $width, $height)
    $g.DrawRectangle($pSubgraph, $x, $y, $width, $height)
    $g.DrawString($title, $fontSubTitle, $tSubgraph, $x + 15, $y + 10)
}

function Draw-Arr {
    param([float]$x1, [float]$y1, [float]$x2, [float]$y2)
    $g.DrawLine($pLine, $x1, $y1, $x2, $y2)
    
    $angle = [Math]::Atan2($y2 - $y1, $x2 - $x1)
    $len = 10
    $ang = [Math]::PI / 6
    
    $px1 = $x2 - $len * [Math]::Cos($angle - $ang)
    $py1 = $y2 - $len * [Math]::Sin($angle - $ang)
    $px2 = $x2 - $len * [Math]::Cos($angle + $ang)
    $py2 = $y2 - $len * [Math]::Sin($angle + $ang)
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddPolygon([System.Drawing.PointF[]]@(
        (New-Object System.Drawing.PointF($x2, $y2)),
        (New-Object System.Drawing.PointF($px1, $py1)),
        (New-Object System.Drawing.PointF($px2, $py2))
    ))
    $g.FillPath($bArrow, $path)
}

# --- 1. SUBGRAPH: CLIENTE MOVIL ---
Draw-Subg 640 25 470 95 "Cliente Movil"
Draw-Box 685 52 380 48 "App Movil Flutter (MVVM)"

# --- 2. SUBGRAPH: CAPA DE RED Y CONTROLADORES REST FASTAPI ---
Draw-Subg 100 205 1550 200 "Capa de Red y Controladores REST FastAPI"
Draw-Box 675 230 400 48 "main.py (CORS + Middleware)"

Draw-Box 130 335 320 48 "cursos.py (/api/estudiantes)"
Draw-Box 500 335 270 48 "predict.py (/api/predict)"
Draw-Box 820 335 240 48 "auth.py (/api/auth)"
Draw-Box 1110 335 230 48 "tutor.py (/api/tutor)"

# --- 3. SUBGRAPH: CAPA DE SERVICIOS Y NEGOCIO ---
Draw-Subg 100 465 1550 215 "Capa de Servicios y Negocio"
Draw-Box 180 500 450 48 "data_service.py (Adaptador y Repositorio Demo)"
Draw-Box 720 500 440 48 "moodle_service.py (Orquestador y Moodle REST)"
Draw-Box 180 595 450 48 "ml_service.py (Pipeline de Inferencia Scikit-Learn)"

# --- 4. SUBGRAPH: CAPA DE PERSISTENCIA Y MODELOS ---
Draw-Subg 100 735 970 180 "Capa de Persistencia y Modelos"
Draw-Box 125 785 300 48 "ml_models/ (model.joblib, scaler.joblib)"
Draw-Box 445 785 275 48 "models.py (Esquemas Pydantic)"
Draw-Box 740 785 300 48 "database.py (SQLite con modo WAL)"

# --- 5. SUBGRAPH: SERVICIOS EXTERNOS ---
Draw-Subg 1100 735 550 180 "Servicios Externos"
Draw-Box 1125 785 285 48 "MoodleCloud LMS (Web Services API)"
Draw-Box 1430 785 200 48 "Google Gemini API (LLM)"

# ==============================================================================
# CONEXIONES Y FLECHAS
# ==============================================================================

# Flutter -> main.py (con etiqueta HTTP / JSON)
$g.DrawLine($pLine, 875, 100, 875, 140)
# Badge HTTP / JSON
$g.FillRectangle($bNode, 815, 135, 120, 28)
$g.DrawRectangle($pSubgraph, 815, 135, 120, 28)
$rectBadge = New-Object System.Drawing.RectangleF(815, 135, 120, 28)
$g.DrawString("HTTP / JSON", $fontBadge, $tNode, $rectBadge, $sfCenter)
Draw-Arr 875 163 875 230

# main.py -> cursos, predict, auth, tutor
$g.DrawLine($pLine, 875, 278, 875, 305)
$g.DrawLine($pLine, 290, 305, 1225, 305)
Draw-Arr 290 305 290 335
Draw-Arr 635 305 635 335
Draw-Arr 940 305 940 335
Draw-Arr 1225 305 1225 335

# auth.py -> moodle_service.py
Draw-Arr 940 383 940 500

# predict.py -> ml_service.py
$g.DrawLine($pLine, 635, 383, 635, 435)
$g.DrawLine($pLine, 635, 435, 60, 435)
$g.DrawLine($pLine, 60, 435, 60, 620)
Draw-Arr 60 620 180 620

# cursos.py -> database.py
$g.DrawLine($pLine, 290, 383, 290, 420)
$g.DrawLine($pLine, 290, 420, 35, 420)
$g.DrawLine($pLine, 35, 420, 35, 715)
$g.DrawLine($pLine, 35, 715, 870, 715)
Draw-Arr 870 715 870 785

# tutor.py -> Google Gemini API
$g.DrawLine($pLine, 1225, 383, 1225, 445)
$g.DrawLine($pLine, 1225, 445, 1530, 445)
Draw-Arr 1530 445 1530 785

# tutor.py -> database.py
$g.DrawLine($pLine, 1225, 383, 1225, 430)
$g.DrawLine($pLine, 1225, 430, 910, 430)
$g.DrawLine($pLine, 910, 430, 910, 715)
Draw-Arr 910 715 910 785

# moodle_service.py -> MoodleCloud LMS
$g.DrawLine($pLine, 940, 548, 940, 700)
$g.DrawLine($pLine, 940, 700, 1265, 700)
Draw-Arr 1265 700 1265 785

# moodle_service.py -> database.py
Draw-Arr 890 548 890 785

# moodle_service.py -> ml_service.py
$g.DrawLine($pLine, 720, 524, 660, 524)
$g.DrawLine($pLine, 660, 524, 660, 620)
Draw-Arr 660 620 630 620

# ml_service.py -> ml_models/
Draw-Arr 275 643 275 785

$outPath = "c:\Users\CESAR\Desktop\PROYECTO TALLER MOVIL\Mobile_Learning_Moodle\Docs\diagramas\diagrama_arquitectura_tono_claro.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Diagrama actualizado en: $outPath"
