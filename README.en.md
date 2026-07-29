# ⚙️ AIO Runtime Installer

<div align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE.svg" alt="PowerShell 5.1+">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6.svg" alt="Windows 10/11">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
</div>

<p align="center">
  <b>🇺🇸 English</b> | <a href="README.md">🇧🇷 Português</a>
</p>



---

<br>

> **Robust and professional PowerShell script** for automated installation of all essential Windows runtimes and components using WinGet and DISM. Ideal for clean Windows 10/11 installations, ensuring that no game or application will present errors due to missing dependencies (like Visual C++ DLLs, DirectX, .NET, Java, etc.).

---

## 🚀 Features

| Feature | Details |
|---|---|
| **Smart Scan** | Analyzes your system before starting and automatically unchecks/skips anything already installed, saving time |
| **Clean Interactive Menu** | Terminal-based UI designed with colors and keyboard navigation (arrow keys, spacebar) |
| **Zero Post-Setup Interaction** | Once you select what to install, it handles everything in completely silent mode (`--silent` on winget and `/norestart` on dism) |
| **Comprehensive Report** | Generates a colorful summary on the console and saves a detailed log file to your Desktop |
| **Pure ASCII / UTF-8 BOM** | 100% free of emojis and breaking characters, guaranteeing perfect execution on the standard Windows PowerShell 5.1 |
| **Auto-elevation (UAC)** | The script automatically requests Administrator privileges if not already elevated |

---

## 📦 Runtime Catalog

The script supports automated and silent installation of the following components:

- **Visual C++ Redistributables** (x86 and x64, from 2005 up to 2015-2026)
- **.NET Desktop Runtimes** (Versions 6, 7, 8, 9, 10)
- **.NET ASP.NET Core Runtimes** (Versions 8, 9, 10)
- **.NET Framework Legacy** (3.5 via native DISM activation)
- **DirectX End-User Runtime**
- **WebView2 Runtime**
- **Java Runtime Environment (JRE)**
- **OpenAL** (3D Audio for games)
- **XNA Framework** (Legacy indie games)
- **Vulkan Runtime**
- **Video Codecs** (HEVC and AV1 from Microsoft Store)
- **Media Feature Pack** (Activation for Windows N/KN editions)

---

## 🛠️ Requirements

- **Windows 10 or Windows 11**
- **PowerShell 5.1** or higher
- **WinGet** installed (Included by default on Windows 11 and recent Windows 10 versions. The script will warn you if it's missing)

---

## 🏃 How to Use

### Interactive Mode (Recommended)
Simply right-click the `instalar-runtimes.ps1` file and select **"Run with PowerShell"**.
Or, via terminal:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1
```

### Silent Mode (For Automation)
Ideal for post-formatting scripts or corporate deployment:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1 -Silent
```

### Advanced Optional Arguments
```powershell
# Installs everything without showing the menu
-Silent

# Skips specific categories (comma separated)
-SkipCategories "Java Runtime","Vulkan Runtime"

# Sets a custom path for the log file
-LogPath "C:\Paths\my_custom_log.log"
```

---

## 📄 License

This project is licensed under the MIT License. Feel free to use, modify, and distribute.
