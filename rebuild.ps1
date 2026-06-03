# rebuild.ps1  —  run from the project root: .\rebuild.ps1
# Regenerates the Cosma cosmoscope and injects dark/light mode support.

Set-Location $PSScriptRoot

# ── 1. Generate cosmoscope ─────────────────────────────────────────────────
Write-Host "Building cosmoscope..." -ForegroundColor Cyan
cosma modelize
if ($LASTEXITCODE -ne 0) {
    Write-Host "cosma modelize failed. Aborting." -ForegroundColor Red
    exit 1
}

# ── 2. Post-process export/index.html ─────────────────────────────────────
$htmlPath = Join-Path $PSScriptRoot "export\index.html"
$utf8NoBom = New-Object System.Text.UTF8Encoding $False
$html = [System.IO.File]::ReadAllText($htmlPath, [System.Text.Encoding]::UTF8)

# Guard: skip if already injected
if ($html.Contains('id="cosma-dark-mode"')) {
    Write-Host "Dark mode already injected - done." -ForegroundColor Yellow
    exit 0
}

# ── CSS ───────────────────────────────────────────────────────────────────
$darkCSS = @"
<style id="cosma-dark-mode">
/* =============================================================
   Cosma — dark / light mode
   Controlled by [data-theme="dark"] on <html>
   ============================================================= */

/* Override Cosma's own CSS variables */
[data-theme="dark"] {
    --offblack:                   #dde1f0;
    --offwhite:                   #1c1c2e;
    --background-gray:            #16162a;
    --gray:                       #2e2e50;
    --shadow:                     0 1px 3px rgba(0,0,0,.6), 0 1px 2px rgba(0,0,0,.8);
    --border-color:               #2e2e50;
    --indicator-background-color: #2e2e50;
    --cosma-blue:                 #4a90d9;
}

/* Graph canvas (overrides the inline style Cosma sets) */
[data-theme="dark"] .graph-wrapper { background-color: #13131f !important; }

/* Panels */
[data-theme="dark"] body { background-color: #13131f; }

/* Buttons */
[data-theme="dark"] .btn {
    background-color: #24243e;
    border-color:     #3a3a58;
    color:            #dde1f0;
}
[data-theme="dark"] .close-button { color: #888; }

/* Inputs */
[data-theme="dark"] .search-bar,
[data-theme="dark"] input[type="text"],
[data-theme="dark"] input[type="search"],
[data-theme="dark"] select {
    background-color: #24243e;
    color:            #dde1f0;
    border-color:     #3a3a58;
}
[data-theme="dark"] input::placeholder { color: #6a6a90; }
[data-theme="dark"] .filter input[type="checkbox"] { accent-color: #4a90d9; }

/* Links */
[data-theme="dark"] a         { color: #7ec8f5; }
[data-theme="dark"] a:visited { color: #a890d8; }

/* Code */
[data-theme="dark"] code,
[data-theme="dark"] pre {
    background-color: #1e1e34;
    color:            #a0d8a0;
    border-color:     #3a3a58;
}

/* Separators */
[data-theme="dark"] hr { background: #2e2e50; }

/* Tooltips */
[data-theme="dark"] .record-links-context {
    background:   #1e1e34;
    color:        #dde1f0;
    border-color: #3a3a58;
}

/* Search highlight */
[data-theme="dark"] .highlight {
    background-color: rgba(90,75,0,.7);
    color:            #ffe080;
}

/* Badges */
[data-theme="dark"] .badge {
    background-color: #2e2e50;
    color:            #aab0d8;
}

/* details / summary */
[data-theme="dark"] details > summary { color: #dde1f0; }

/* ── Toggle button ── */
#theme-toggle {
    position:        fixed;
    bottom:          18px;
    left:            18px;
    z-index:         9999;
    width:           32px;
    height:          32px;
    border-radius:   50%;
    border:          1px solid #d0d0d0;
    background:      #f0f0f0;
    color:           #333;
    font-size:       15px;
    line-height:     1;
    cursor:          pointer;
    display:         flex;
    align-items:     center;
    justify-content: center;
    padding:         0;
    box-shadow:      0 1px 4px rgba(0,0,0,.18);
    transition:      background .2s, border-color .2s, color .2s;
}
[data-theme="dark"] #theme-toggle {
    background:   #24243e;
    border-color: #3a3a58;
    color:        #dde1f0;
}
#theme-toggle:hover { opacity: .8; }
</style>
"@

# ── JavaScript ────────────────────────────────────────────────────────────
$toggleJS = @"
<script id="cosma-dark-mode-js">
(function () {
    var DARK_BG  = '#13131f';
    var LIGHT_BG = '#ffffff';

    var saved = localStorage.getItem('cosma-theme') || 'light';
    document.documentElement.setAttribute('data-theme', saved);

    function syncGraphBg(theme) {
        var gw = document.querySelector('.graph-wrapper');
        if (gw) gw.style.backgroundColor = theme === 'dark' ? DARK_BG : LIGHT_BG;
    }

    var btn = document.createElement('button');
    btn.id = 'theme-toggle';
    btn.title = 'Toggle dark / light mode';
    btn.setAttribute('aria-label', 'Toggle dark / light mode');
    // Plain ASCII chars to avoid encoding issues
    btn.textContent = saved === 'dark' ? 'Light' : 'Dark';

    btn.addEventListener('click', function () {
        var next = document.documentElement.getAttribute('data-theme') === 'dark'
            ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', next);
        localStorage.setItem('cosma-theme', next);
        btn.textContent = next === 'dark' ? 'Light' : 'Dark';
        syncGraphBg(next);
    });

    function init() {
        document.body.appendChild(btn);
        syncGraphBg(saved);
        // Update button label now that DOM is ready
        btn.textContent = saved === 'dark' ? 'Light' : 'Dark';
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
</script>
"@

# ── Inject into HTML ───────────────────────────────────────────────────────
$html = $html.Replace('</head>', "$darkCSS`n</head>")
$html = $html.Replace('</body>', "$toggleJS`n</body>")

[System.IO.File]::WriteAllText($htmlPath, $html, $utf8NoBom)

Write-Host "Dark/light toggle injected into export/index.html" -ForegroundColor Green
Write-Host "Done. Open export/index.html in a browser." -ForegroundColor Green
