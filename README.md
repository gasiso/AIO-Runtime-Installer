[🇺🇸 English](#english) | [🇧🇷 Português](#português)

---

<a id="english"></a>
# AIO Runtime Installer 🇺🇸

A robust and professional PowerShell script for automated installation of all essential Windows runtimes and components using WinGet and DISM.

This script is ideal for clean Windows 10/11 installations, ensuring that no game or application will present errors due to missing dependencies (like Visual C++ DLLs, DirectX, .NET, Java, etc.).

## 🚀 Key Features

- **Smart Scan (New):** Analyzes your system before starting and automatically unchecks/skips everything that is already installed, saving time.
- **Clean Interactive Menu:** Terminal-based UI designed with colors and keyboard navigation (arrow keys, spacebar).
- **Zero Post-Setup Interaction:** Once you select what to install, the script handles everything in completely silent mode (`--silent` on winget and `/norestart` on dism).
- **Complete Catalog:** Visual C++ (2005 to 2026), .NET (Desktop, ASP.NET, Framework 3.5), DirectX, WebView2, Java, OpenAL, Vulkan, Video Codecs (HEVC/AV1), and Media Feature Pack.
- **Comprehensive Report:** Generates a colorful execution report on the console and saves a detailed log file to your Desktop.
- **Pure ASCII / UTF-8 BOM:** Source code 100% free of encoding issues and emojis, guaranteeing perfect execution on the standard Windows PowerShell 5.1.

## 📥 How to Use

### Interactive Mode
Simply right-click the `instalar-runtimes.ps1` file and select **"Run with PowerShell"**.
Or, via terminal:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1
```

The script will automatically request Administrator privileges (UAC) if it is not already elevated.

### Silent Mode (For Automation)
Ideal for post-formatting scripts or corporate deployment:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1 -Silent
```

### Optional Arguments
- `-Silent`: Installs everything without showing the menu.
- `-SkipCategories "Category 1","Category 2"`: Skips specific categories.
- `-LogPath "C:\Path\my_log.log"`: Sets a custom path for the log file.

## 📦 What is installed?

1. **Visual C++ Redistributables** (x86 and x64 from 2005 up to 2015-2026)
2. **.NET Desktop Runtimes** (Versions 6, 7, 8, 9, 10)
3. **.NET ASP.NET Core Runtimes** (Versions 8, 9, 10)
4. **.NET Framework Legacy** (3.5, via DISM)
5. **DirectX End-User Runtime**
6. **WebView2 Runtime**
7. **Java Runtime Environment (JRE)**
8. **OpenAL** (3D Audio for games)
9. **XNA Framework** (Legacy indie games)
10. **Vulkan Runtime**
11. **Video Codecs** (HEVC and AV1)
12. **Media Feature Pack** (Only for Windows N/KN editions)

## 🛠️ Requirements

- Windows 10 or Windows 11
- PowerShell 5.1 or higher
- **WinGet** installed (comes natively on recent Windows versions; the script will warn you if it's missing).

## 📝 License
Distributed under the MIT License. See the `LICENSE` file for more details.

---

<a id="português"></a>
# AIO Runtime Installer 🇧🇷

Um script PowerShell robusto e profissional para instalação automatizada de todos os runtimes e componentes essenciais do Windows, utilizando o WinGet e DISM. 

Este script é ideal para formatações limpas do Windows 10/11, garantindo que nenhum jogo ou aplicativo apresente erros por falta de dependências (como DLLs do Visual C++, DirectX, .NET, Java, etc.).

## 🚀 Recursos Principais

- **Varredura Inteligente (Novo):** Analisa seu sistema antes de iniciar e desmarca/pula automaticamente tudo o que já estiver instalado, poupando tempo.
- **Menu Interativo Limpo:** Interface via terminal desenhada com cores e navegação por teclado (setas, barra de espaço).
- **Zero Interação Pós-Setup:** Uma vez selecionado o que instalar, o script cuida de tudo no modo totalmente silencioso (`--silent` no winget e `/norestart` no dism).
- **Catálogo Completo:** Visual C++ (2005 a 2026), .NET (Desktop, ASP.NET, Framework 3.5), DirectX, WebView2, Java, OpenAL, Vulkan, Codecs (HEVC/AV1) e Media Feature Pack.
- **Relatório Completo:** Gera um relatório de execução colorido no console e salva um arquivo de log detalhado na Área de Trabalho.
- **Pure ASCII / UTF-8 BOM:** Código fonte 100% livre de problemas de codificação e emojis, garantindo execução perfeita no PowerShell 5.1 padrão do Windows.

## 📥 Como Usar

### Modo Interativo
Basta clicar com o botão direito no arquivo `instalar-runtimes.ps1` e selecionar **"Executar com o PowerShell"**.
Ou, via terminal:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1
```

O script solicitará permissões de Administrador automaticamente (UAC) se não estiver elevado.

### Modo Silencioso (Para Automação)
Ideal para scripts de pós-formatação ou uso corporativo:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1 -Silent
```

### Argumentos Opcionais
- `-Silent`: Instala tudo sem exibir o menu.
- `-SkipCategories "Categoria 1","Categoria 2"`: Pula categorias específicas.
- `-LogPath "C:\Caminho\meu_log.log"`: Define um caminho customizado para o log.

## 📦 O que é instalado?

1. **Visual C++ Redistributables** (x86 e x64 de 2005 até 2015-2026)
2. **.NET Desktop Runtimes** (Versões 6, 7, 8, 9, 10)
3. **.NET ASP.NET Core Runtimes** (Versões 8, 9, 10)
4. **.NET Framework Legacy** (3.5, via DISM)
5. **DirectX End-User Runtime**
6. **WebView2 Runtime**
7. **Java Runtime Environment (JRE)**
8. **OpenAL** (Áudio 3D para jogos)
9. **XNA Framework** (Jogos indie antigos)
10. **Vulkan Runtime**
11. **Codecs de Vídeo** (HEVC e AV1)
12. **Media Feature Pack** (Apenas para Windows edições N/KN)

## 🛠️ Requisitos

- Windows 10 ou Windows 11
- PowerShell 5.1 ou superior
- **WinGet** instalado (já vem nativo nas versões recentes do Windows; o script avisará se não estiver presente).

## 📝 Licença
Distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
