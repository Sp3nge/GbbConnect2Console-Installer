# GbbConnect2.Console Linux Installer Script (`script.sh`)

This Bash script (`script.sh`) automates the installation, configuration, and updating of the `GbbConnect2.Console` application on Debian-based Linux systems (like Debian, Ubuntu). It handles prerequisites, compilation, configuration, and sets up the application to run as a persistent `systemd` service.

**Made by @Sp3nge**

## Table of Contents

*   [English Guide](#english-guide)
    *   [Features](#features)
    *   [Prerequisites (for the system running the script)](#prerequisites-for-the-system-running-the-script)
    *   [How to Use (Installation & Updates)](#how-to-use-installation--updates)
    *   [Script Steps Overview (Interactive Install)](#script-steps-overview-interactive-install)
    *   [Default Configuration Values](#default-configuration-values)
    *   [Managing the Service (after installation)](#managing-the-service-after-installation)
    *   [Log File Location (Application Logs)](#log-file-location-application-logs)
    *   [Important Notes](#important-notes)
    *   [Contributing / Issues](#contributing--issues)
*   [Polski Przewodnik](#polski-przewodnik)
    *   [Funkcjonalności](#funkcjonalnoci)
    *   [Wymagania Wstępne (dla systemu uruchamiającego skrypt)](#wymagania-wstpne-dla-systemu-uruchamiajcego-skrypt)
    *   [Jak Używać (Instalacja i Aktualizacje)](#jak-uywa-instalacja-i-aktualizacje)
    *   [Przegląd Kroków Skryptu (Instalacja Interaktywna)](#przegld-krokw-skryptu-instalacja-interaktywna)
    *   [Domyślne Wartości Konfiguracyjne](#domylne-wartoci-konfiguracyjne)
    *   [Zarządzanie Usługą (po instalacji)](#zarzdzanie-usug-po-instalacji)
    *   [Lokalizacja Plików Logów (Logi Aplikacji)](#lokalizacja-plikw-logw-logi-aplikacji)
    *   [Ważne Uwagi](#wane-uwagi)
    *   [Wkład / Problemy](#wkad--problemy)

---

## English Guide

### Features

*   **Bilingual Interface:** Prompts and messages available in English and Polish for interactive installation.
*   **Prerequisite Installation:** During interactive setup, automatically installs necessary tools: Git, `lsb-release`, `rsync`, .NET SDK (targets version 9.0 by default).
*   **Repository Handling:**
    *   Clones/updates the official `gbbsoft/GbbConnect2` repository.
*   **Compilation:**
    *   Compiles `GbbConnect2.Console` as a self-contained, single-file executable.
    *   Includes a fix for a known C# syntax issue.
*   **Interactive Configuration (`Parameters.xml`):**
    *   Guides the user through providing necessary values for `Parameters.xml` during initial setup.
    *   If `Parameters.xml` already exists, prompts whether to reconfigure or keep the existing file during interactive setup. Preserves existing `Parameters.xml` by default during updates.
*   **Application Backup:**
    *   If an existing installation is detected, it backs up old application binaries before deploying a new version.
*   **Systemd Service Setup:**
    *   Creates a dedicated system user.
    *   Deploys the application (default: `/opt/gbbconnect2console`).
    *   Generates and enables a `systemd` service for persistence and auto-start.
*   **OS Detection & .NET SDK Installation:**
    *   Robustly detects Debian/Ubuntu versions.
    *   Uses recommended methods for .NET SDK installation (PPA for Ubuntu 22.04/24.04).
    *   Warns about .NET 9 incompatibility on unsupported OS versions (Ubuntu 20.04, Debian 10).
*   **Update Modes:**
    *   `--update`: For user-triggered updates. Can be somewhat verbose.
    *   `--update-silent`: For fully non-interactive updates, suitable for automation by advanced users (e.g., with their own cron setup).

### Prerequisites (for the system running the script)

*   A Debian-based Linux system (e.g., Debian 11+, Ubuntu 22.04+ recommended).
*   `sudo` (administrator) privileges.
*   Internet connection.
*   Basic command-line familiarity.

### How to Use (Installation & Updates)

1.  **Download the Script:**
    Save the script content to a file, for example, `script.sh`.
    ```bash
    wget -O script.sh https://raw.githubusercontent.com/Sp3nge/GbbConnect2Console-Installer/refs/heads/main/script.sh
    ```

2.  **Make it Executable:**
    ```bash
    chmod +x script.sh
    ```

3.  **Initial Interactive Installation:**
    Run the script without any arguments. You will need `sudo` privileges, so either run as root or use `sudo`.
    ```bash
    sudo ./script.sh
    ```
    Follow the prompts for language, prerequisite installation, and `Parameters.xml` configuration.

4.  **User-Triggered Update:**
    To update an existing installation to the latest version from GitHub:
    ```bash
    sudo ./script.sh --update
    ```
    This mode will:
    *   Use existing configuration (clone path, service name, user).
    *   Pull latest code, recompile.
    *   Backup old binaries.
    *   Preserve your existing `Parameters.xml`.
    *   Stop, deploy, and restart the service.

5.  **Silent Update (for automation):**
    ```bash
    sudo ./script.sh --update-silent
    ```
    This mode is designed for non-interactive execution (e.g., by other scripts or a manually configured cron job). It performs the same update steps as `--update` but with minimal to no standard output (errors will still go to stderr or logs).

### Script Steps Overview (Interactive Install)

1.  **Language Selection.**
2.  **Prerequisite Check & Installation.**
3.  **Repository Cloning/Verification.**
4.  **Application Compilation.**
5.  **Configuration (`Parameters.xml`), Backup, Deployment, and Service Setup.**
6.  **Verification and Service Management Info.**

### Default Configuration Values

(During interactive install, you can mostly accept defaults or provide custom values)
*   **.NET SDK Version:** 9.0
*   **Clone Directory:** `$HOME/GbbConnect2_build`
*   **Deployment Base Directory:** `/opt`
*   **Application/Service Name:** `gbbconnect2console`
*   **Service User:** `gbbconsoleuser`

### Managing the Service (after installation)

*   **Status:** `sudo systemctl status gbbconnect2console.service`
*   **Logs:** `sudo journalctl -u gbbconnect2console.service -n 50 --no-pager`
*   **Follow Logs:** `sudo journalctl -f -u gbbconnect2console.service`
*   **Stop:** `sudo systemctl stop gbbconnect2console.service`
*   **Start:** `sudo systemctl start gbbconnect2console.service`
*   **Restart:** `sudo systemctl restart gbbconnect2console.service`

### Log File Location (Application Logs)

Application-specific logs (not systemd logs) are typically found in:
**`/opt/gbbconnect2console/GbbConnect2/Log/YYYY-MM-DD.txt`**
(The path might vary if you changed the `APP_NAME` during setup).

### Important Notes

*   **Unsupported OS Versions (Ubuntu 20.04, Debian 10):**
    *   **Ubuntu 20.04** (EOL April 2025) and **Debian 10 (Buster)** (EOL June 2024) are **not supported** for .NET 9.
    *   The script will warn if these OS versions are detected. Proceeding with a .NET 9 installation on them is **strongly discouraged** and likely to fail or be unstable. Please upgrade your OS to a supported version like Ubuntu 22.04 LTS / 24.04 LTS or Debian 11 / 12.
*   **`Parameters.xml` Sensitivity:** The `Parameters.xml` file will contain sensitive information like your Plant Token and MQTT details. The script sets permissions on this file to `640` (readable by the service user and its group, no access for others), but ensure your system's overall security is maintained.
*   **.NET 9 Requirement:** This script and the GbbConnect2.Console project it builds target .NET 9. Ensure your OS can support this or that the .NET 9 SDK installs correctly on a supported OS version.
*   **Updates to GbbConnect2 Repository:** If the `gbbsoft/GbbConnect2` repository structure or build process changes significantly, this script (`script.sh`) might need updates.
*   **Automated Updates:** This script provides `--update` and `--update-silent` flags. For fully automated periodic updates, users would need to configure their own cron job to call `./script.sh --update-silent` at desired intervals.

### Contributing / Issues

If you find issues with this installer script (`script.sh`) or have suggestions for improvement, please feel free to raise an issue on its GitHub repository.

---

## Polski Przewodnik

### Funkcjonalności

*   **Dwujęzyczny Interfejs:** Komunikaty i monity dostępne w języku angielskim i polskim dla instalacji interaktywnej.
*   **Instalacja Wymagań Wstępnych:** Podczas interaktywnej konfiguracji automatycznie instaluje niezbędne narzędzia: Git, `lsb-release`, `rsync`, .NET SDK (domyślnie celuje w wersję 9.0).
*   **Obsługa Repozytorium:**
    *   Klonuje/aktualizuje oficjalne repozytorium `gbbsoft/GbbConnect2`.
*   **Kompilacja:**
    *   Kompiluje `GbbConnect2.Console` jako samodzielny, pojedynczy plik wykonywalny.
    *   Zawiera poprawkę znanego błędu składni C#.
*   **Interaktywna Konfiguracja (`Parameters.xml`):**
    *   Prowadzi użytkownika przez proces podawania niezbędnych wartości do pliku `Parameters.xml` podczas początkowej konfiguracji.
    *   Jeśli plik `Parameters.xml` już istnieje, podczas interaktywnej konfiguracji pyta, czy go ponownie skonfigurować, czy zachować. Domyślnie zachowuje istniejący `Parameters.xml` podczas aktualizacji.
*   **Kopia Zapasowa Aplikacji:**
    *   Jeśli wykryto istniejącą instalację, tworzy kopię zapasową starych plików binarnych aplikacji przed wdrożeniem nowej wersji.
*   **Konfiguracja Usługi Systemd:**
    *   Tworzy dedykowanego użytkownika systemowego.
    *   Wdraża aplikację (domyślnie: `/opt/gbbconnect2console`).
    *   Generuje i włącza plik usługi `systemd` zapewniający trwałość i automatyczny start.
*   **Wykrywanie Systemu Operacyjnego i Instalacja .NET SDK:**
    *   Solidnie wykrywa wersje Debian/Ubuntu.
    *   Używa zalecanych metod instalacji .NET SDK (PPA dla Ubuntu 22.04/24.04).
    *   Ostrzega o niekompatybilności .NET 9 na niewspieranych wersjach systemu (Ubuntu 20.04, Debian 10).
*   **Tryby Aktualizacji:**
    *   `--update`: Dla aktualizacji wyzwalanych przez użytkownika. Może być nieco bardziej szczegółowy w komunikatach.
    *   `--update-silent`: Dla w pełni nieinteraktywnych aktualizacji, odpowiedni do automatyzacji przez zaawansowanych użytkowników (np. z własną konfiguracją cron).

### Wymagania Wstępne (dla systemu uruchamiającego skrypt)

*   System Linux oparty na Debianie (np. zalecany Debian 11+, Ubuntu 22.04+).
*   Uprawnienia `sudo` (administratora).
*   Połączenie internetowe.
*   Podstawowa znajomość wiersza poleceń.

### Jak Używać (Instalacja i Aktualizacje)

1.  **Pobierz Skrypt:**
    Zapisz zawartość skryptu do pliku, np. `script.sh`.
    ```bash
    wget -O script.sh https://raw.githubusercontent.com/Sp3nge/GbbConnect2Console-Installer/refs/heads/main/script.sh
    ```

2.  **Nadaj Prawa do Wykonania:**
    ```bash
    chmod +x script.sh
    ```

3.  **Pierwsza Instalacja Interaktywna:**
    Uruchom skrypt bez żadnych argumentów. Będziesz potrzebować uprawnień `sudo`.
    ```bash
    sudo ./script.sh
    ```
    Postępuj zgodnie z monitami dotyczącymi wyboru języka, instalacji wymagań wstępnych i konfiguracji `Parameters.xml`.

4.  **Aktualizacja Wyzwalana przez Użytkownika:**
    Aby zaktualizować istniejącą instalację do najnowszej wersji z GitHub:
    ```bash
    sudo ./script.sh --update
    ```
    Ten tryb:
    *   Użyje istniejącej konfiguracji (ścieżka klonowania, nazwa usługi, użytkownik).
    *   Pobierze najnowszy kod, przekompiluje.
    *   Utworzy kopię zapasową starych plików binarnych.
    *   Zachowa istniejący plik `Parameters.xml`.
    *   Zatrzyma, wdroży i zrestartuje usługę.

5.  **Cicha Aktualizacja (do automatyzacji):**
    ```bash
    sudo ./script.sh --update-silent
    ```
    Ten tryb jest przeznaczony do wykonania nieinteraktywnego (np. przez inne skrypty lub ręcznie skonfigurowane zadanie cron). Wykonuje te same kroki aktualizacji co `--update`, ale z minimalną ilością lub bez danych wyjściowych na standardowe wyjście (błędy nadal trafią na stderr lub do logów).

### Przegląd Kroków Skryptu (Instalacja Interaktywna)

1.  **Wybór Języka.**
2.  **Sprawdzanie i Instalacja Wymagań Wstępnych.**
3.  **Klonowanie/Weryfikacja Repozytorium.**
4.  **Kompilacja Aplikacji.**
5.  **Konfiguracja (`Parameters.xml`), Kopia Zapasowa, Wdrożenie i Ustawienie Usługi.**
6.  **Weryfikacja i Informacje o Zarządzaniu Usługą.**

### Domyślne Wartości Konfiguracyjne

(Podczas instalacji interaktywnej możesz głównie akceptować wartości domyślne lub podać własne)
*   **Wersja .NET SDK:** 9.0
*   **Katalog Klonowania:** `$HOME/GbbConnect2_build`
*   **Bazowy Katalog Wdrożenia:** `/opt`
*   **Nazwa Aplikacji/Usługi:** `gbbconnect2console`
*   **Użytkownik Usługi:** `gbbconsoleuser`

### Zarządzanie Usługą (po instalacji)

*   **Status:** `sudo systemctl status gbbconnect2console.service`
*   **Logi:** `sudo journalctl -u gbbconnect2console.service -n 50 --no-pager`
*   **Śledzenie Logów:** `sudo journalctl -f -u gbbconnect2console.service`
*   **Zatrzymywanie:** `sudo systemctl stop gbbconnect2console.service`
*   **Uruchamianie:** `sudo systemctl start gbbconnect2console.service`
*   **Restart:** `sudo systemctl restart gbbconnect2console.service`

### Lokalizacja Plików Logów (Logi Aplikacji)

Logi specyficzne dla aplikacji (a nie logi systemd) zazwyczaj znajdują się w:
**`/opt/gbbconnect2console/GbbConnect2/Log/RRRR-MM-DD.txt`**
(Ścieżka może się różnić, jeśli zmieniłeś `APP_NAME` podczas konfiguracji).

### Ważne Uwagi

*   **Niewspierane Wersje Systemu (Ubuntu 20.04, Debian 10):**
    *   Standardowe wsparcie dla **Ubuntu 20.04** (EOL kwiecień 2025) oraz **Debiana 10 (Buster)** (EOL czerwiec 2024) zakończyło się lub wkrótce się zakończy, a Microsoft **nie zapewnia** dla nich wsparcia .NET 9.
    *   Ten skrypt ostrzeże Cię, jeśli wykryje te wersje systemu. Kontynuowanie instalacji .NET 9 na nich jest **zdecydowanie odradzane** i prawdopodobnie zakończy się niepowodzeniem lub niestabilnością. Proszę zaktualizować system operacyjny do wspieranej wersji, takiej jak Ubuntu 22.04 LTS / 24.04 LTS lub Debian 11 / 12.
*   **Wrażliwość Pliku `Parameters.xml`:** Ten plik zawiera wrażliwe dane. Skrypt ustawia uprawnienia na `640`. Zapewnij bezpieczeństwo systemu.
*   **Wymaganie .NET 9:** Aplikacja celuje w .NET 9.
*   **Aktualizacje Repozytorium GbbConnect2:** Znaczące zmiany w strukturze repozytorium źródłowego mogą wymagać aktualizacji skryptu (`script.sh`).
*   **Automatyczne Aktualizacje:** Ten skrypt dostarcza flagi `--update` i `--update-silent`. Aby w pełni zautomatyzować okresowe sprawdzanie aktualizacji, użytkownicy musieliby samodzielnie skonfigurować zadanie cron wywołujące `./script.sh --update-silent` w wybranych interwałach.

### Wkład / Problemy

Jeśli znajdziesz problemy z tym skryptem instalacyjnym (`script.sh`) lub masz sugestie dotyczące ulepszeń, prosimy o zgłoszenie problemu (issue) w jego repozytorium GitHub.
