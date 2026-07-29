# ⚙️ AIO Runtime Installer

<div align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE.svg" alt="PowerShell 5.1+">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6.svg" alt="Windows 10/11">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
</div>

<p align="center">
  <a href="README.en.md">🇺🇸 English</a> | <b>🇧🇷 Português</b>
</p>



---

<br>

> **Script PowerShell robusto e profissional** para instalação automatizada de todos os runtimes e componentes essenciais do Windows, utilizando o WinGet e DISM. Ideal para formatações limpas do Windows 10/11, garantindo que nenhum jogo ou aplicativo apresente erros por falta de dependências (como DLLs do Visual C++, DirectX, .NET, Java, etc.).

---

## 🚀 Funcionalidades

| Funcionalidade | Detalhes |
|---|---|
| **Varredura Inteligente** | Analisa seu sistema antes de iniciar e desmarca/pula automaticamente o que já estiver instalado, poupando tempo |
| **Menu Interativo Limpo** | Interface via terminal desenhada com cores e navegação por teclado (setas, barra de espaço) |
| **Zero Interação Pós-Setup** | Após a seleção, instala tudo de forma 100% silenciosa (`--silent` no winget e `/norestart` no dism) |
| **Relatório Completo** | Gera um resumo colorido no console e salva um log detalhado na sua Área de Trabalho |
| **Pure ASCII / UTF-8 BOM** | Código 100% livre de emojis e caracteres que quebram o PowerShell 5.1, garantindo execução perfeita nativamente |
| **Auto-elevação (UAC)** | O script detecta e pede privilégios de administrador automaticamente se necessário |

---

## 📦 Catálogo de Runtimes

O script possui suporte à instalação automatizada e silenciosa dos seguintes componentes:

- **Visual C++ Redistributables** (x86 e x64, de 2005 até 2015-2026)
- **.NET Desktop Runtimes** (Versões 6, 7, 8, 9, 10)
- **.NET ASP.NET Core Runtimes** (Versões 8, 9, 10)
- **.NET Framework Legacy** (3.5 via ativação DISM nativa)
- **DirectX End-User Runtime**
- **WebView2 Runtime**
- **Java Runtime Environment (JRE)**
- **OpenAL** (Áudio 3D para jogos)
- **XNA Framework** (Para jogos indie antigos)
- **Vulkan Runtime**
- **Codecs de Vídeo** (HEVC e AV1 da Microsoft Store)
- **Media Feature Pack** (Ativação para Windows edições N/KN)

---

## 🛠️ Requisitos

- **Windows 10 ou Windows 11**
- **PowerShell 5.1** ou superior
- **WinGet** instalado (Já incluso por padrão no Windows 11 e versões recentes do 10. O script irá avisá-lo caso não encontre)

---

## 🏃 Como Usar

### Modo Interativo (Recomendado)
Basta clicar com o botão direito no arquivo `instalar-runtimes.ps1` e selecionar **"Executar com o PowerShell"**.
Ou, via terminal:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1
```

### Modo Silencioso (Para Automação)
Ideal para scripts de pós-formatação ou uso corporativo:
```powershell
powershell -ExecutionPolicy Bypass -File .\instalar-runtimes.ps1 -Silent
```

### Argumentos Opcionais Avançados
```powershell
# Instala tudo sem exibir o menu
-Silent

# Pula categorias específicas (separadas por vírgula)
-SkipCategories "Java Runtime","Vulkan Runtime"

# Define um caminho customizado para o log
-LogPath "C:\Caminho\meu_log_customizado.log"
```

---

## 📄 Licença

Este projeto está sob a licença MIT. Sinta-se à vontade para usar, modificar e distribuir.
