#Requires -Version 5.1
<#
.SYNOPSIS
    Generates PWA + favicon PNG/ICO assets for Spark Racquetball using System.Drawing.
.OUTPUTS
    icon-512.png, icon-192.png, apple-touch-icon.png, favicon.ico
    (all written to the same directory as this script)
#>

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ── Brand colours ─────────────────────────────────────────────────────────────
$cGreen   = [System.Drawing.Color]::FromArgb(255,  26,  71,  42)  # #1a472a
$cGold    = [System.Drawing.Color]::FromArgb(255, 232, 184,  75)  # #e8b84b
$cGoldTr  = [System.Drawing.Color]::FromArgb(108, 232, 184,  75)  # strings (semi-transparent)
$cWhite   = [System.Drawing.Color]::FromArgb(248, 255, 255, 255)
$cShadow  = [System.Drawing.Color]::FromArgb(140,   0,   0,   0)

# ── Helper: build a rounded-rectangle GraphicsPath ────────────────────────────
function New-RoundedRectPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($x,            $y,            $r*2, $r*2, 180, 90)
    $path.AddArc($x+$w-$r*2,   $y,            $r*2, $r*2, 270, 90)
    $path.AddArc($x+$w-$r*2,   $y+$h-$r*2,   $r*2, $r*2,   0, 90)
    $path.AddArc($x,            $y+$h-$r*2,   $r*2, $r*2,  90, 90)
    $path.CloseFigure()
    return $path
}

# ── Core drawing function ──────────────────────────────────────────────────────
function New-IconBitmap([int]$targetSize) {
    # Draw 3× larger, then downsample for smooth antialiasing
    $ss = 3
    $w  = $targetSize * $ss
    $h  = $w

    $bmp = New-Object System.Drawing.Bitmap($w, $h,
               [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint  = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    # ── Racquet geometry (proportional to canvas) ──────────────────────────────
    [float]$cx     = $w * 0.500
    [float]$headCy = $h * 0.375
    [float]$headRx = $w * 0.213
    [float]$headRy = $h * 0.252

    # ── Background: full green square (maskable-safe for PWA) ─────────────────
    $brGreen = New-Object System.Drawing.SolidBrush($cGreen)
    $g.FillRectangle($brGreen, 0, 0, $w, $h)

    # ── Strings clipped to head ellipse ───────────────────────────────────────
    $clipPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $clipPath.AddEllipse([float]($cx-$headRx), [float]($headCy-$headRy),
                         [float]($headRx*2),   [float]($headRy*2))
    $g.SetClip($clipPath)

    $penStr = New-Object System.Drawing.Pen($cGoldTr, [float]($w * 0.011))

    # 6 horizontal strings
    [float]$yA = $headCy - $headRy * 0.88
    [float]$yB = $headCy + $headRy * 0.88
    for ($i = 0; $i -le 5; $i++) {
        [float]$y = $yA + $i * ($yB - $yA) / 5
        $g.DrawLine($penStr, [float]($cx-$headRx*1.2), $y, [float]($cx+$headRx*1.2), $y)
    }
    # 4 vertical strings
    [float]$xA = $cx - $headRx * 0.73
    [float]$xB = $cx + $headRx * 0.73
    for ($i = 0; $i -le 3; $i++) {
        [float]$x = $xA + $i * ($xB - $xA) / 3
        $g.DrawLine($penStr, $x, [float]($headCy-$headRy*1.2), $x, [float]($headCy+$headRy*1.2))
    }
    $g.ResetClip()

    # ── Head outline ──────────────────────────────────────────────────────────
    [float]$bw = $w * 0.030
    $penHead = New-Object System.Drawing.Pen($cGold, $bw)
    $g.DrawEllipse($penHead,
                   [float]($cx-$headRx), [float]($headCy-$headRy),
                   [float]($headRx*2),   [float]($headRy*2))

    # ── Handle (rounded rectangle) ────────────────────────────────────────────
    [float]$hw  = $w * 0.085
    [float]$hh  = $h * 0.260
    [float]$hx1 = $cx - $hw/2
    [float]$hy1 = $headCy + $headRy - $bw*0.5
    [float]$hr  = $hw * 0.30
    $handlePath = New-RoundedRectPath $hx1 $hy1 $hw $hh $hr
    $brGold = New-Object System.Drawing.SolidBrush($cGold)
    $g.FillPath($brGold, $handlePath)

    # ── Dollar sign ───────────────────────────────────────────────────────────
    [float]$fontSize = $w * 0.340
    $fontStyle = [System.Drawing.FontStyle]::Bold
    $fontUnit  = [System.Drawing.GraphicsUnit]::Pixel

    $font = $null
    foreach ($fname in @('Arial Black', 'Impact', 'Arial', 'Tahoma')) {
        try {
            $candidate = New-Object System.Drawing.Font($fname, $fontSize, $fontStyle, $fontUnit)
            # Check the font actually resolved to the requested family
            if ($candidate.FontFamily.Name -ieq $fname -or $fname -in @('Arial','Tahoma')) {
                $font = $candidate; break
            }
            $candidate.Dispose()
        } catch {}
    }
    if ($null -eq $font) {
        $font = New-Object System.Drawing.Font('Arial', $fontSize, $fontStyle, $fontUnit)
    }

    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment     = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

    # Rectangle centred on head for both shadow and main text
    [float]$off = $w * 0.006
    $textRect   = New-Object System.Drawing.RectangleF(
                    [float]($cx-$headRx), [float]($headCy-$headRy),
                    [float]($headRx*2),   [float]($headRy*2))
    $shadowRect = New-Object System.Drawing.RectangleF(
                    [float]($cx-$headRx+$off), [float]($headCy-$headRy+$off),
                    [float]($headRx*2),        [float]($headRy*2))

    $brShadow = New-Object System.Drawing.SolidBrush($cShadow)
    $brWhite  = New-Object System.Drawing.SolidBrush($cWhite)
    $g.DrawString('$', $font, $brShadow, $shadowRect, $sf)
    $g.DrawString('$', $font, $brWhite,  $textRect,   $sf)

    $g.Dispose()

    # ── Downsample with high-quality bicubic ──────────────────────────────────
    $result = New-Object System.Drawing.Bitmap($targetSize, $targetSize,
                  [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g2 = [System.Drawing.Graphics]::FromImage($result)
    $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g2.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g2.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g2.DrawImage($bmp, 0, 0, $targetSize, $targetSize)
    $g2.Dispose()
    $bmp.Dispose()

    return $result
}

# ── Generate each size ─────────────────────────────────────────────────────────
$pngFormat = [System.Drawing.Imaging.ImageFormat]::Png
$icoFormat = [System.Drawing.Imaging.ImageFormat]::Icon

$outputs = @(
    @{ size = 512; file = 'icon-512.png';        fmt = $pngFormat },
    @{ size = 192; file = 'icon-192.png';        fmt = $pngFormat },
    @{ size = 180; file = 'apple-touch-icon.png';fmt = $pngFormat },
    @{ size = 32;  file = 'favicon.ico';         fmt = $icoFormat }
)

foreach ($entry in $outputs) {
    Write-Host "Generating $($entry.file) ($($entry.size)x$($entry.size))..." -NoNewline
    $img  = New-IconBitmap $entry.size
    $path = Join-Path $scriptDir $entry.file
    $img.Save($path, $entry.fmt)
    $img.Dispose()
    Write-Host " done -> $path"
}

Write-Host "`nAll icon assets generated successfully."
