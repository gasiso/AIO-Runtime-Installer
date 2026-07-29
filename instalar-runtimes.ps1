<#
.SYNOPSIS
    AIO Runtime Installer — Instala TODOS os runtimes essenciais do Windows via WinGet.

.DESCRIPTION
    Script profissional para instalacao automatizada de runtimes essenciais do Windows.
    Inclui: Visual C++ (2005-2026), .NET Framework/Desktop Runtime, DirectX, WebView2,
    Java, OpenAL, XNA, Vulkan Runtime e mais.

    Recursos:
      - Auto-elevacao para Administrador (UAC)
      - Menu interativo com categorias selecionaveis
      - Deteccao de winget e pre-requisitos
      - Log detalhado de todas as operacoes
      - Contagem de progresso em tempo real
      - Resumo final com status de cada pacote
      - Suporte a parametro -Silent para automacao total

.PARAMETER Silent
    Executa em modo silencioso, instalando TODOS os runtimes sem menu interativo.

.PARAMETER LogPath
    Caminho customizado para o arquivo de log. Padrao: ~\Desktop\RuntimeInstaller_<data>.log

.PARAMETER SkipCategories
    Lista de categorias a pular (ex: -SkipCategories "Java","Vulkan")

.EXAMPLE
    .\instalar-runtimes.ps1
    Abre o menu interativo para selecionar categorias.

.EXAMPLE
    .\instalar-runtimes.ps1 -Silent
    Instala tudo automaticamente sem interacao.

.EXAMPLE
    .\instalar-runtimes.ps1 -Silent -SkipCategories "Java","Vulkan"
    Instala tudo exceto Java e Vulkan.

.NOTES
    Autor      : AIO Runtime Installer
    Versao     : 3.0.0
    Atualizado : 21/07/2026
    Requisitos : Windows 10/11, WinGet 1.7+, PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [switch]$Silent,
    [string]$LogPath,
    [string[]]$SkipCategories
)

# ============================================================================
#                          CONFIGURACAO & CONSTANTES
# ============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
$script:ScriptVersion = '3.0.0'
$script:ScriptDate    = '21/07/2026'

$script:Colors = @{
    Title    = 'Cyan'
    Success  = 'Green'
    Warning  = 'Yellow'
    Error    = 'Red'
    Info     = 'White'
    Muted    = 'DarkGray'
    Category = 'Magenta'
    Progress = 'DarkCyan'
}

# ============================================================================
#                         CATALOGO DE RUNTIMES
# ============================================================================

$script:RuntimeCatalog = [ordered]@{

    'Visual C++ Redistributables' = @{
        Icon        = '[VC]'
        Description = 'Microsoft Visual C++ 2005-2026 (x86 + x64). Essencial para jogos e apps nativos.'
        Packages    = @(
            @{ Id = 'Microsoft.VCRedist.2005.x86';  Name = 'VC++ 2005 x86' }
            @{ Id = 'Microsoft.VCRedist.2005.x64';  Name = 'VC++ 2005 x64' }
            @{ Id = 'Microsoft.VCRedist.2008.x86';  Name = 'VC++ 2008 x86' }
            @{ Id = 'Microsoft.VCRedist.2008.x64';  Name = 'VC++ 2008 x64' }
            @{ Id = 'Microsoft.VCRedist.2010.x86';  Name = 'VC++ 2010 x86' }
            @{ Id = 'Microsoft.VCRedist.2010.x64';  Name = 'VC++ 2010 x64' }
            @{ Id = 'Microsoft.VCRedist.2012.x86';  Name = 'VC++ 2012 x86' }
            @{ Id = 'Microsoft.VCRedist.2012.x64';  Name = 'VC++ 2012 x64' }
            @{ Id = 'Microsoft.VCRedist.2013.x86';  Name = 'VC++ 2013 x86' }
            @{ Id = 'Microsoft.VCRedist.2013.x64';  Name = 'VC++ 2013 x64' }
            @{ Id = 'Microsoft.VCRedist.2015+.x86'; Name = 'VC++ 2015-2026 x86' }
            @{ Id = 'Microsoft.VCRedist.2015+.x64'; Name = 'VC++ 2015-2026 x64' }
        )
    }

    '.NET Desktop Runtimes' = @{
        Icon        = '[.NET]'
        Description = '.NET Desktop Runtime 6/7/8/9/10. Necessario para apps WPF, WinForms e MAUI.'
        Packages    = @(
            @{ Id = 'Microsoft.DotNet.DesktopRuntime.6';  Name = '.NET Desktop Runtime 6 (LTS)' }
            @{ Id = 'Microsoft.DotNet.DesktopRuntime.7';  Name = '.NET Desktop Runtime 7' }
            @{ Id = 'Microsoft.DotNet.DesktopRuntime.8';  Name = '.NET Desktop Runtime 8 (LTS)' }
            @{ Id = 'Microsoft.DotNet.DesktopRuntime.9';  Name = '.NET Desktop Runtime 9 (STS)' }
            @{ Id = 'Microsoft.DotNet.DesktopRuntime.10'; Name = '.NET Desktop Runtime 10 (LTS)' }
        )
    }

    '.NET ASP.NET Core Runtimes' = @{
        Icon        = '[ASP]'
        Description = 'ASP.NET Core Runtime. Necessario para apps web hospedados localmente.'
        Packages    = @(
            @{ Id = 'Microsoft.DotNet.AspNetCore.8';  Name = 'ASP.NET Core Runtime 8 (LTS)' }
            @{ Id = 'Microsoft.DotNet.AspNetCore.9';  Name = 'ASP.NET Core Runtime 9 (STS)' }
            @{ Id = 'Microsoft.DotNet.AspNetCore.10'; Name = 'ASP.NET Core Runtime 10 (LTS)' }
        )
    }

    '.NET Framework Legacy' = @{
        Icon        = '[FW]'
        Description = '.NET Framework 3.5 (via DISM). Necessario para aplicacoes legadas.'
        Packages    = @(
            @{ Id = '__DISM_NetFx3__'; Name = '.NET Framework 3.5 (inclui 2.0/3.0)'; IsDism = $true }
        )
    }

    'DirectX' = @{
        Icon        = '[DX]'
        Description = 'DirectX End-User Runtime (d3dx9, d3dx10, d3dx11, XAudio, XInput legado).'
        Packages    = @(
            @{ Id = 'Microsoft.DirectX'; Name = 'DirectX End-User Runtime' }
        )
    }

    'WebView2' = @{
        Icon        = '[WV]'
        Description = 'Microsoft Edge WebView2 Runtime. Usado por muitos apps modernos (Teams, etc).'
        Packages    = @(
            @{ Id = 'Microsoft.EdgeWebView2Runtime'; Name = 'Edge WebView2 Runtime' }
        )
    }

    'Java Runtime' = @{
        Icon        = '[JRE]'
        Description = 'Oracle Java Runtime Environment. Necessario para apps Java e Minecraft.'
        Packages    = @(
            @{ Id = 'Oracle.JavaRuntimeEnvironment'; Name = 'Java Runtime (JRE)' }
        )
    }

    'OpenAL' = @{
        Icon        = '[AL]'
        Description = 'OpenAL (Creative). Biblioteca de audio 3D usada por muitos jogos.'
        Packages    = @(
            @{ Id = 'CreativeTechnology.OpenAL'; Name = 'OpenAL' }
        )
    }

    'XNA Framework' = @{
        Icon        = '[XNA]'
        Description = 'Microsoft XNA Framework. Necessario para jogos indie (Terraria, Stardew Valley, etc).'
        Packages    = @(
            @{ Id = 'Microsoft.XNARedist'; Name = 'XNA Framework Redistributable' }
        )
    }

    'Vulkan Runtime' = @{
        Icon        = '[VK]'
        Description = 'Vulkan Runtime Libraries. API grafica de alto desempenho (normalmente incluida nos drivers GPU).'
        Packages    = @(
            @{ Id = 'KhronosGroup.VulkanRT'; Name = 'Vulkan Runtime Libraries' }
        )
    }

    'Codecs de Video (HEVC/AV1)' = @{
        Icon        = '[AV]'
        Description = 'Codecs HEVC (H.265) e AV1. Necessarios para videos 4K/HDR e captura de tela moderna.'
        Packages    = @(
            @{ Id = '9N4WGH0Z6VHQ';  Name = 'HEVC Video Extensions (gratis)'; IsStore = $true }
            @{ Id = '9MVZQVXJBQ9V';  Name = 'AV1 Video Extension'; IsStore = $true }
        )
    }

    'Media Feature Pack (Edicoes N)' = @{
        Icon        = '[MF]'
        Description = 'Recursos de midia para edicoes N/KN do Windows (WMP, codecs, gravacao de voz).'
        Packages    = @(
            @{ Id = '__DISM_MediaFeaturePack__'; Name = 'Media Feature Pack'; IsDism = $true; FeatureName = 'MediaPlayback' }
        )
    }
}

# ============================================================================
#                          FUNCOES AUXILIARES
# ============================================================================

function Write-Banner {
    $banner = @"

    +===============================================================+
    |                                                               |
    |       >>> AIO RUNTIMES - All-In-One Runtime Installer <<<     |
    |                                                               |
    |         ** All-In-One Runtime Installer para Windows **       |
    |                                                               |
    |    Versao: $($script:ScriptVersion.PadRight(10)) Atualizado: $($script:ScriptDate.PadRight(16))       |
    |    Runtimes: VC++  .NET  DirectX  WebView2  Java  +mais      |
    |                                                               |
    +===============================================================+
"@
    Write-Host $banner -ForegroundColor $script:Colors.Title
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS','SKIP')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry  = "[$timestamp] [$Level] $Message"

    if ($script:LogFile) {
        Add-Content -Path $script:LogFile -Value $logEntry -ErrorAction SilentlyContinue
    }

    $color = switch ($Level) {
        'INFO'    { $script:Colors.Info }
        'WARN'    { $script:Colors.Warning }
        'ERROR'   { $script:Colors.Error }
        'SUCCESS' { $script:Colors.Success }
        'SKIP'    { $script:Colors.Muted }
    }
    Write-Host "  $logEntry" -ForegroundColor $color
}

function Write-SectionHeader {
    param(
        [string]$Icon,
        [string]$Title,
        [string]$Description
    )
    Write-Host ""
    Write-Host "  +-------------------------------------------------------------" -ForegroundColor $script:Colors.Muted
    Write-Host "  | $Icon  $Title" -ForegroundColor $script:Colors.Category
    Write-Host "  | $Description" -ForegroundColor $script:Colors.Muted
    Write-Host "  +-------------------------------------------------------------" -ForegroundColor $script:Colors.Muted
}

function Write-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Label
    )
    $percent = [math]::Round(($Current / $Total) * 100)
    $filled  = [math]::Round($percent / 2)
    $empty   = 50 - $filled
    $bar     = ('#' * $filled) + ('-' * $empty)

    Write-Host "`r  [$bar] $percent% ($Current/$Total) $Label    " -ForegroundColor $script:Colors.Progress -NoNewline
    if ($Current -eq $Total) { Write-Host "" }
}

function Test-AdminPrivileges {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminElevation {
    if (-not (Test-AdminPrivileges)) {
        Write-Host ""
        Write-Host "  [!!] Este script requer privilegios de Administrador." -ForegroundColor $script:Colors.Warning
        Write-Host "  [>>] Reexecutando com elevacao UAC..." -ForegroundColor $script:Colors.Info
        Write-Host ""

        $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        if ($Silent)         { $argList += " -Silent" }
        if ($LogPath)        { $argList += " -LogPath `"$LogPath`"" }
        if ($SkipCategories) { $argList += " -SkipCategories " + ($SkipCategories -join ',') }

        try {
            Start-Process powershell.exe -ArgumentList $argList -Verb RunAs -Wait
        }
        catch {
            Write-Host "  [ERRO] Elevacao cancelada pelo usuario ou erro: $_" -ForegroundColor $script:Colors.Error
        }
        exit
    }
}

function Test-WinGetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        $versionOutput = winget --version 2>$null
        Write-Log "WinGet detectado: $versionOutput" 'SUCCESS'
        return $true
    }
    catch {
        Write-Log "WinGet NAO encontrado! Instale via Microsoft Store (App Installer) ou winget.run" 'ERROR'
        Write-Host ""
        Write-Host "  [DICA] Para instalar o WinGet:" -ForegroundColor $script:Colors.Warning
        Write-Host "     1. Abra a Microsoft Store" -ForegroundColor $script:Colors.Info
        Write-Host "     2. Pesquise 'App Installer'" -ForegroundColor $script:Colors.Info
        Write-Host "     3. Instale/atualize o 'Instalador de Aplicativo'" -ForegroundColor $script:Colors.Info
        Write-Host ""
        return $false
    }
}

function Install-WinGetPackage {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    $result = [PSCustomObject]@{
        PackageId   = $PackageId
        DisplayName = $DisplayName
        Status      = 'Desconhecido'
        ExitCode    = -1
        Duration    = [timespan]::Zero
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        Write-Log "Instalando: $DisplayName ($PackageId)..." 'INFO'

        $output = winget install --id $PackageId -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Out-String

        $sw.Stop()
        $result.Duration = $sw.Elapsed
        $result.ExitCode = $LASTEXITCODE

        if ($LASTEXITCODE -eq 0) {
            $result.Status = 'Instalado'
            Write-Log "[OK] $DisplayName -- instalado com sucesso ($([math]::Round($sw.Elapsed.TotalSeconds, 1))s)" 'SUCCESS'
        }
        elseif ($output -match 'already installed|No applicable update|No available upgrade') {
            $result.Status = 'Ja instalado'
            $result.ExitCode = 0
            Write-Log "[>>] $DisplayName -- ja estava instalado" 'SKIP'
        }
        elseif ($output -match 'No package found') {
            $result.Status = 'Nao encontrado'
            Write-Log "[!!] $DisplayName -- pacote nao encontrado no repositorio" 'WARN'
        }
        else {
            $result.Status = 'Erro'
            Write-Log "[XX] $DisplayName -- falhou (exit code: $LASTEXITCODE)" 'ERROR'
        }
    }
    catch {
        $sw.Stop()
        $result.Duration = $sw.Elapsed
        $result.Status   = 'Excecao'
        Write-Log "[XX] $DisplayName -- excecao: $_" 'ERROR'
    }

    return $result
}

function Install-DismFeature {
    param(
        [string]$DisplayName,
        [string]$FeatureName = 'NetFx3'
    )

    $result = [PSCustomObject]@{
        PackageId   = "DISM:$FeatureName"
        DisplayName = $DisplayName
        Status      = 'Desconhecido'
        ExitCode    = -1
        Duration    = [timespan]::Zero
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        Write-Log "Ativando feature Windows: $DisplayName (via DISM, feature: $FeatureName)..." 'INFO'

        $featureState = dism /online /get-featureinfo /featurename:$FeatureName 2>$null | Select-String 'State'
        if ($featureState -match 'Enabled|Habilitado') {
            $sw.Stop()
            $result.Duration = $sw.Elapsed
            $result.Status   = 'Ja instalado'
            $result.ExitCode = 0
            Write-Log "[>>] $DisplayName -- ja estava ativado" 'SKIP'
            return $result
        }

        $output = dism /online /enable-feature /featurename:$FeatureName /all /norestart 2>&1 | Out-String
        $sw.Stop()
        $result.Duration = $sw.Elapsed
        $result.ExitCode = $LASTEXITCODE

        if ($LASTEXITCODE -eq 0) {
            $result.Status = 'Instalado'
            Write-Log "[OK] $DisplayName -- ativado com sucesso" 'SUCCESS'
        }
        elseif ($output -match 'not applicable|Feature name .* is not known') {
            $result.Status = 'Nao aplicavel'
            Write-Log "[>>] $DisplayName -- feature nao disponivel nesta edicao do Windows" 'SKIP'
        }
        else {
            $result.Status = 'Erro'
            Write-Log "[XX] $DisplayName -- falhou (exit code: $LASTEXITCODE)" 'ERROR'
        }
    }
    catch {
        $sw.Stop()
        $result.Duration = $sw.Elapsed
        $result.Status   = 'Excecao'
        Write-Log "[XX] $DisplayName -- excecao: $_" 'ERROR'
    }

    return $result
}

function Install-StorePackage {
    param(
        [string]$StoreId,
        [string]$DisplayName
    )

    $result = [PSCustomObject]@{
        PackageId   = "Store:$StoreId"
        DisplayName = $DisplayName
        Status      = 'Desconhecido'
        ExitCode    = -1
        Duration    = [timespan]::Zero
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        Write-Log "Instalando da Microsoft Store: $DisplayName ($StoreId)..." 'INFO'

        $output = winget install --id $StoreId --source msstore --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Out-String

        $sw.Stop()
        $result.Duration = $sw.Elapsed
        $result.ExitCode = $LASTEXITCODE

        if ($LASTEXITCODE -eq 0) {
            $result.Status = 'Instalado'
            Write-Log "[OK] $DisplayName -- instalado com sucesso" 'SUCCESS'
        }
        elseif ($output -match 'already installed|No applicable update') {
            $result.Status = 'Ja instalado'
            $result.ExitCode = 0
            Write-Log "[>>] $DisplayName -- ja estava instalado" 'SKIP'
        }
        elseif ($output -match 'No package found|not found|purchase') {
            $result.Status = 'Nao disponivel'
            Write-Log "[!!] $DisplayName -- nao encontrado na Store (pode requerer compra ou regiao)" 'WARN'
        }
        else {
            $result.Status = 'Erro'
            Write-Log "[XX] $DisplayName -- falhou (exit code: $LASTEXITCODE)" 'ERROR'
        }
    }
    catch {
        $sw.Stop()
        $result.Duration = $sw.Elapsed
        $result.Status   = 'Excecao'
        Write-Log "[XX] $DisplayName -- excecao: $_" 'ERROR'
    }

    return $result
}

function Scan-System {
    Write-Host ""
    Write-Log "Iniciando varredura do sistema para descobrir pacotes ja instalados..." 'INFO'
    
    $total = 0
    foreach ($cat in $script:RuntimeCatalog.Keys) {
        $total += $script:RuntimeCatalog[$cat].Packages.Count
    }
    
    $current = 0
    $dismFeatures = dism /online /get-features /format:table 2>&1 | Out-String
    
    foreach ($cat in $script:RuntimeCatalog.Keys) {
        foreach ($pkg in $script:RuntimeCatalog[$cat].Packages) {
            $current++
            Write-ProgressBar -Current $current -Total $total -Label "Verificando $($pkg.Name)"
            
            $isInstalled = $false
            if ($pkg.ContainsKey('IsDism') -and $pkg.IsDism) {
                $featureName = if ($pkg.ContainsKey('FeatureName') -and $pkg.FeatureName) { $pkg.FeatureName } else { 'NetFx3' }
                if ($dismFeatures -match "(?i)$featureName.*\b(Enabled|Habilitado)\b") {
                    $isInstalled = $true
                }
            }
            elseif ($pkg.ContainsKey('IsStore') -and $pkg.IsStore) {
                $check = winget list --id $pkg.Id --source msstore --accept-source-agreements 2>&1 | Out-String
                if (-not ($check -match 'No package found|not found|Nenhum pacote')) { $isInstalled = $true }
            }
            else {
                $check = winget list --id $pkg.Id --exact --accept-source-agreements 2>&1 | Out-String
                if (-not ($check -match 'No package found|not found|Nenhum pacote')) { $isInstalled = $true }
            }
            
            $pkg.IsInstalled = $isInstalled
        }
    }
    
    Write-Host ""
}

function Show-InteractiveMenu {
    $categories = @($script:RuntimeCatalog.Keys)
    $selected   = @{}

    for ($i = 0; $i -lt $categories.Count; $i++) {
        $cat = $categories[$i]
        $pkgs = $script:RuntimeCatalog[$cat].Packages
        $installedCount = @($pkgs | Where-Object { $_.ContainsKey('IsInstalled') -and $_.IsInstalled }).Count
        
        if ($installedCount -eq $pkgs.Count) {
            $selected[$i] = $false
        }
        else {
            $selected[$i] = $true
        }
    }

    $currentIndex = 0
    $confirmed    = $false

    Write-Host ""
    Write-Host "  +==============================================================+" -ForegroundColor $script:Colors.Title
    Write-Host "  |  MENU DE SELECAO -- Use as teclas para navegar               |" -ForegroundColor $script:Colors.Title
    Write-Host "  |                                                              |" -ForegroundColor $script:Colors.Title
    Write-Host "  |  [Seta Cima/Baixo] Navegar   [Espaco] Marcar/Desmarcar      |" -ForegroundColor $script:Colors.Info
    Write-Host "  |  [A] Selecionar Tudo   [N] Desmarcar Tudo                   |" -ForegroundColor $script:Colors.Info
    Write-Host "  |  [Enter] Confirmar     [Esc] Cancelar                       |" -ForegroundColor $script:Colors.Info
    Write-Host "  +==============================================================+" -ForegroundColor $script:Colors.Title
    Write-Host ""

    $menuTop = [Console]::CursorTop

    while (-not $confirmed) {
        [Console]::SetCursorPosition(0, $menuTop)

        for ($i = 0; $i -lt $categories.Count; $i++) {
            $cat  = $categories[$i]
            $info = $script:RuntimeCatalog[$cat]
            $icon = $info.Icon
            $pkgs = $info.Packages
            $pkgCount = $pkgs.Count
            $installedCount = @($pkgs | Where-Object { $_.ContainsKey('IsInstalled') -and $_.IsInstalled }).Count

            if ($selected[$i]) { $check = '[X]' } else { $check = '[ ]' }
            if ($i -eq $currentIndex) { $pointer = '>>' } else { $pointer = '  ' }
            if ($i -eq $currentIndex) { $color = $script:Colors.Title } else { $color = $script:Colors.Info }

            $statusText = if ($installedCount -eq $pkgCount) { "(COMPLETO)" } else { "($installedCount/$pkgCount inst.)" }
            $line = "  $pointer $check $icon $cat $statusText"
            Write-Host $line.PadRight(72) -ForegroundColor $color
        }

        Write-Host ""
        $totalPkgs = 0
        foreach ($key in $selected.Keys) {
            if ($selected[$key]) {
                $totalPkgs += $script:RuntimeCatalog[$categories[$key]].Packages.Count
            }
        }
        Write-Host "  [i] Total selecionado: $totalPkgs pacotes                         " -ForegroundColor $script:Colors.Warning

        $key = [Console]::ReadKey($true)

        switch ($key.Key) {
            'UpArrow' {
                if ($currentIndex -gt 0) { $currentIndex-- } else { $currentIndex = $categories.Count - 1 }
            }
            'DownArrow' {
                if ($currentIndex -lt ($categories.Count - 1)) { $currentIndex++ } else { $currentIndex = 0 }
            }
            'Spacebar' {
                $selected[$currentIndex] = -not $selected[$currentIndex]
            }
            'A' {
                for ($i = 0; $i -lt $categories.Count; $i++) { $selected[$i] = $true }
            }
            'N' {
                for ($i = 0; $i -lt $categories.Count; $i++) { $selected[$i] = $false }
            }
            'Enter' {
                $confirmed = $true
            }
            'Escape' {
                Write-Host ""
                Write-Host "  [XX] Operacao cancelada pelo usuario." -ForegroundColor $script:Colors.Error
                exit 0
            }
        }
    }

    $result = @()
    foreach ($key in $selected.Keys) {
        if ($selected[$key]) {
            $result += $categories[$key]
        }
    }
    return $result
}

function Show-FinalReport {
    param(
        [array]$Results,
        [timespan]$TotalDuration
    )

    $installed    = @($Results | Where-Object { $_.Status -eq 'Instalado' })
    $skipped      = @($Results | Where-Object { $_.Status -eq 'Ja instalado' })
    $failed       = @($Results | Where-Object { $_.Status -in @('Erro','Excecao','Nao encontrado') })

    Write-Host ""
    Write-Host "  +==============================================================+" -ForegroundColor $script:Colors.Title
    Write-Host "  |                   RELATORIO FINAL                            |" -ForegroundColor $script:Colors.Title
    Write-Host "  +==============================================================+" -ForegroundColor $script:Colors.Title
    Write-Host ""

    Write-Host "  +--------------------------------------+--------------+----------+" -ForegroundColor $script:Colors.Muted
    Write-Host "  | Pacote                               | Status       | Tempo    |" -ForegroundColor $script:Colors.Muted
    Write-Host "  +--------------------------------------+--------------+----------+" -ForegroundColor $script:Colors.Muted

    foreach ($r in $Results) {
        $name   = $r.DisplayName.PadRight(36).Substring(0, 36)
        $status = $r.Status.PadRight(12).Substring(0, 12)
        $time   = "$([math]::Round($r.Duration.TotalSeconds, 1))s".PadRight(8)

        $statusColor = switch ($r.Status) {
            'Instalado'      { $script:Colors.Success }
            'Ja instalado'   { $script:Colors.Muted }
            'Erro'           { $script:Colors.Error }
            'Excecao'        { $script:Colors.Error }
            'Nao encontrado' { $script:Colors.Warning }
            'Nao disponivel' { $script:Colors.Warning }
            'Nao aplicavel'  { $script:Colors.Muted }
            default          { $script:Colors.Info }
        }

        Write-Host "  | " -ForegroundColor $script:Colors.Muted -NoNewline
        Write-Host "$name" -ForegroundColor $script:Colors.Info -NoNewline
        Write-Host " | " -ForegroundColor $script:Colors.Muted -NoNewline
        Write-Host "$status" -ForegroundColor $statusColor -NoNewline
        Write-Host " | " -ForegroundColor $script:Colors.Muted -NoNewline
        Write-Host "$time" -ForegroundColor $script:Colors.Muted -NoNewline
        Write-Host "|" -ForegroundColor $script:Colors.Muted
    }

    Write-Host "  +--------------------------------------+--------------+----------+" -ForegroundColor $script:Colors.Muted
    Write-Host ""

    Write-Host "  +-------------------------------------------------------------" -ForegroundColor $script:Colors.Muted
    Write-Host "  |  [OK] Instalados:       $($installed.Count)" -ForegroundColor $script:Colors.Success
    Write-Host "  |  [>>] Ja existentes:    $($skipped.Count)" -ForegroundColor $script:Colors.Muted
    if ($failed.Count -gt 0) {
    Write-Host "  |  [XX] Com falha:        $($failed.Count)" -ForegroundColor $script:Colors.Error
    }
    Write-Host "  |  [--] Total processado: $($Results.Count)" -ForegroundColor $script:Colors.Info
    Write-Host "  |  [TT] Tempo total:      $([math]::Round($TotalDuration.TotalMinutes, 1)) minutos" -ForegroundColor $script:Colors.Info
    Write-Host "  |  [LG] Log salvo em:     $script:LogFile" -ForegroundColor $script:Colors.Info
    Write-Host "  +-------------------------------------------------------------" -ForegroundColor $script:Colors.Muted

    if ($failed.Count -gt 0) {
        Write-Host ""
        Write-Host "  [!!] Pacotes com falha:" -ForegroundColor $script:Colors.Warning
        foreach ($f in $failed) {
            Write-Host "     * $($f.DisplayName) -- $($f.Status)" -ForegroundColor $script:Colors.Error
        }
        Write-Host "     [DICA] Tente executar novamente ou instale manualmente." -ForegroundColor $script:Colors.Warning
    }

    Write-Host ""
    Write-Host "  +==============================================================+" -ForegroundColor $script:Colors.Success
    Write-Host "  |          *** Processo finalizado com sucesso! ***             |" -ForegroundColor $script:Colors.Success
    Write-Host "  +==============================================================+" -ForegroundColor $script:Colors.Success
    Write-Host ""
}

# ============================================================================
#                             EXECUCAO PRINCIPAL
# ============================================================================

$Host.UI.RawUI.WindowTitle = "AIO Runtime Installer v$script:ScriptVersion"

# --- Auto-Elevar para Admin ---
Request-AdminElevation

# --- Inicializar Log ---
if (-not $LogPath) {
    $logDir = Join-Path $env:USERPROFILE 'Desktop'
    if (-not (Test-Path $logDir)) { $logDir = $env:TEMP }
    $script:LogFile = Join-Path $logDir "RuntimeInstaller_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
}
else {
    $script:LogFile = $LogPath
}

$logParent = Split-Path $script:LogFile -Parent
if ($logParent -and -not (Test-Path $logParent)) {
    New-Item -ItemType Directory -Path $logParent -Force | Out-Null
}

# --- Banner ---
Clear-Host
Write-Banner

# --- Info do sistema ---
Write-Host "  [i] Sistema: $([Environment]::OSVersion.VersionString)" -ForegroundColor $script:Colors.Muted
Write-Host "  [i] Hostname: $env:COMPUTERNAME | User: $env:USERNAME" -ForegroundColor $script:Colors.Muted
Write-Host "  [i] Log: $script:LogFile" -ForegroundColor $script:Colors.Muted
Write-Host ""

Write-Log "=== AIO Runtime Installer v$script:ScriptVersion iniciado ===" 'INFO'
Write-Log "Sistema: $([Environment]::OSVersion.VersionString)" 'INFO'
Write-Log "Usuario: $env:USERNAME@$env:COMPUTERNAME" 'INFO'

# --- Verificar WinGet ---
if (-not (Test-WinGetAvailable)) {
    Write-Host ""
    Write-Host "  Pressione qualquer tecla para sair..." -ForegroundColor $script:Colors.Muted
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

# --- Escanear Sistema ---
Scan-System

# --- Determinar categorias a instalar ---
$categoriesToInstall = @()

if ($Silent) {
    Write-Log "Modo silencioso: instalando TODAS as categorias." 'INFO'
    $categoriesToInstall = @($script:RuntimeCatalog.Keys)
}
else {
    $categoriesToInstall = Show-InteractiveMenu
}

# --- Aplicar filtro de SkipCategories ---
if ($SkipCategories) {
    $before = $categoriesToInstall.Count
    $categoriesToInstall = $categoriesToInstall | Where-Object { $_ -notin $SkipCategories }
    $skippedCats = $before - @($categoriesToInstall).Count
    if ($skippedCats -gt 0) {
        Write-Log "Pulando $skippedCats categorias conforme -SkipCategories" 'WARN'
    }
}

if (@($categoriesToInstall).Count -eq 0) {
    Write-Host ""
    Write-Host "  [!!] Nenhuma categoria selecionada. Nada a fazer." -ForegroundColor $script:Colors.Warning
    exit 0
}

# --- Contar total de pacotes ---
$totalPackages = 0
foreach ($cat in $categoriesToInstall) {
    $totalPackages += $script:RuntimeCatalog[$cat].Packages.Count
}

Write-Host ""
Write-Log "Iniciando instalacao de $totalPackages pacotes em $(@($categoriesToInstall).Count) categorias..." 'INFO'
Write-Host ""

# --- Instalar ---
$allResults    = @()
$currentPkg    = 0
$totalStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($categoryName in $categoriesToInstall) {
    $category = $script:RuntimeCatalog[$categoryName]

    Write-SectionHeader -Icon $category.Icon -Title $categoryName -Description $category.Description

    foreach ($pkg in $category.Packages) {
        $currentPkg++
        Write-ProgressBar -Current $currentPkg -Total $totalPackages -Label $pkg.Name

        if ($pkg.ContainsKey('IsInstalled') -and $pkg.IsInstalled) {
            $result = [PSCustomObject]@{
                PackageId   = $pkg.Id
                DisplayName = $pkg.Name
                Status      = 'Ja instalado (Scan)'
                ExitCode    = 0
                Duration    = [timespan]::Zero
            }
            Write-Log "[>>] $($pkg.Name) -- ignorado (ja instalado)" 'SKIP'
        }
        elseif ($pkg.ContainsKey('IsDism') -and $pkg.IsDism) {
            $featureName = if ($pkg.ContainsKey('FeatureName') -and $pkg.FeatureName) { $pkg.FeatureName } else { 'NetFx3' }
            $result = Install-DismFeature -DisplayName $pkg.Name -FeatureName $featureName
        }
        elseif ($pkg.ContainsKey('IsStore') -and $pkg.IsStore) {
            $result = Install-StorePackage -StoreId $pkg.Id -DisplayName $pkg.Name
        }
        else {
            $result = Install-WinGetPackage -PackageId $pkg.Id -DisplayName $pkg.Name
        }

        $allResults += $result
    }
}

$totalStopwatch.Stop()

# --- Relatorio Final ---
Show-FinalReport -Results $allResults -TotalDuration $totalStopwatch.Elapsed

Write-Log "=== AIO Runtime Installer finalizado ===" 'INFO'

# --- Manter janela aberta se executado diretamente ---
if (-not $Silent) {
    Write-Host "  Pressione qualquer tecla para sair..." -ForegroundColor $script:Colors.Muted
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}
