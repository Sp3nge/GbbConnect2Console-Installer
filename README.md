# GbbConnect2.Console Linux Installer Script

This Bash script automates the installation, configuration, and updating of the `GbbConnect2.Console` application on Debian-based Linux systems (like Debian, Ubuntu). It handles prerequisites, compilation, configuration, and sets up the application to run as a persistent `systemd` service.

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
    *   [Setting Up Automated Updates (Manual Cron Setup)](#setting-up-automated-updates-manual-cron-setup)
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
    *   [Konfiguracja Automatycznych Aktualizacji (Ręczna Konfiguracja Cron)](#konfiguracja-automatycznych-aktualizacji-rczna-konfiguracja-cron)
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
    *   `--update-silent`: For fully non-interactive updates, suitable for automation (e.g., cron).

### Prerequisites (for the system running the script)

*   A Debian-based Linux system (e.g., Debian 11+, Ubuntu 22.04+ recommended).
*   `sudo` (administrator) privileges.
*   Internet connection.
*   Basic command-line familiarity.

### How to Use (Installation & Updates)

1.  **Download the Script:**
    Save the script content to a file, e.g., `install_gbbconsole.sh`.
    ```bash
    wget -O install_gbbconsole.sh <RAW_URL_TO_YOUR_SCRIPT_ON_GITHUB>
    ```

2.  **Make it Executable:**
    ```bash
    chmod +x install_gbbconsole.sh
    ```

3.  **Initial Interactive Installation:**
    Run the script without any arguments. You will need `sudo` privileges, so either run as root or use `sudo`.
    ```bash
    sudo ./install_gbbconsole.sh
    ```
    Follow the prompts for language, prerequisite installation, and `Parameters.xml` configuration.

4.  **User-Triggered Update:**
    To update an existing installation to the latest version from GitHub:
    ```bash
    sudo ./install_gbbconsole.sh --update
    ```
    This mode will:
    *   Use existing configuration (clone path, service name, user).
    *   Pull latest code, recompile.
    *   Backup old binaries.
    *   Preserve your existing `Parameters.xml`.
    *   Stop, deploy, and restart the service.

5.  **Silent Update (for automation, e.g., cron):**
    ```bash
    sudo ./install_gbbconsole.sh --update-silent
    ```
    This mode is designed for non-interactive execution. It performs the same update steps as `--update` but with minimal to no standard output (errors will still go to stderr or logs). See the "Setting Up Automated Updates" section for how to use this with cron.

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
*   **Updates to GbbConnect2 Repository:** If the `gbbsoft/GbbConnect2` repository structure or build process changes significantly, this script might need updates.
*   **Automated Updates:** This script provides `--update` and `--update-silent` flags for updating the application. However, it does **not** automatically configure cron jobs for periodic update checks. If you wish to automate updates, see the section below on "Setting Up Automated Updates (Manual Cron Setup)".

### Setting Up Automated Updates (Manual Cron Setup)

While this main installer script does not automatically set up cron jobs, you can easily configure automated updates using its `--update-silent` flag along with a separate small checker script.

1.  **Create an Update Checker Script:**
    You will need to create a small shell script (e.g., `gbbconnect2_update_checker.sh`) and place it in a location like `/usr/local/bin/`. This script will check GitHub for new commits and then call your main installer script with the `--update-silent` flag.

    **Example `gbbconnect2_update_checker.sh`:**
    ```bash
    #!/bin/bash
    
    # --- CONFIGURATION ---
    # !!! IMPORTANT: Adjust these paths to match YOUR setup !!!
    CLONE_DIR="/root/GbbConnect2_build" # Path where GbbConnect2 is cloned
    MAIN_INSTALLER_SCRIPT_PATH="/path/to/your/install_gbbconsole.sh" # Absolute path to THIS installer script
    APP_NAME="gbbconnect2console" # The name used for the service and in /opt
    BRANCH_TO_TRACK="master" # Or 'main' if that's the primary branch
    # --- END CONFIGURATION ---

    LOG_FILE="/var/log/${APP_NAME}_update_checker.log"

    # Ensure log file directory exists and script can write to it (as root)
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE" 

    exec >> "$LOG_FILE" 2>&1 # Redirect stdout/stderr of this script to the log file

    echo "---=== [$(date)] Starting Update Check (User: $(whoami)) ===---"

    if [ ! -d "$CLONE_DIR" ] || [ ! -d "$CLONE_DIR/.git" ]; then
        echo "[ERROR] Clone directory '$CLONE_DIR' not found or is not a git repository. Cannot check for updates."
        echo "The main application might not have been installed correctly or the clone directory was moved/deleted."
        exit 1
    fi

    cd "$CLONE_DIR" || { echo "[ERROR] Failed to cd into '$CLONE_DIR'."; exit 1; }
    
    # Temporarily set git config if not present to avoid errors during fetch/pull by root cron
    NEEDS_GIT_CONFIG_RESET=false
    if ! git config user.name > /dev/null 2>&1 || ! git config user.email > /dev/null 2>&1; then
        echo "[INFO] Git user.name or user.email not set in $CLONE_DIR. Setting temporarily for fetch/pull."
        git config user.name "Auto Updater"
        git config user.email "updater@localhost"
        NEEDS_GIT_CONFIG_RESET=true
    fi

    LOCAL_HASH_BEFORE_FETCH=$(git rev-parse HEAD 2>/dev/null || echo "unknown_local")
    echo "[INFO] Current local commit in $CLONE_DIR: $LOCAL_HASH_BEFORE_FETCH"

    echo "[INFO] Fetching remote updates for branch '$BRANCH_TO_TRACK' (from origin)..."
    if ! git fetch origin "$BRANCH_TO_TRACK"; then
        echo "[ERROR] Failed to fetch from remote repository. Exiting."
        if [ "$NEEDS_GIT_CONFIG_RESET" = true ]; then git config --unset user.name; git config --unset user.email; fi
        exit 1
    fi
    echo "[INFO] Fetch complete."

    REMOTE_HASH=$(git rev-parse "origin/${BRANCH_TO_TRACK}" 2>/dev/null || echo "unknown_remote")
    echo "[INFO] Latest remote commit on 'origin/${BRANCH_TO_TRACK}': $REMOTE_HASH"

    if [ "$NEEDS_GIT_CONFIG_RESET" = true ]; then
        echo "[INFO] Resetting temporary git user.name and user.email (if they were set)."
        git config --unset user.name &>/dev/null # Suppress error if not set
        git config --unset user.email &>/dev/null # Suppress error if not set
    fi

    if [ "$LOCAL_HASH_BEFORE_FETCH" == "$REMOTE_HASH" ] || [ "$REMOTE_HASH" == "unknown_remote" ]; then
        echo "[INFO] No new commits found. Application is up-to-date."
        echo "---=== [$(date)] Update Check Finished ===---"
        exit 0
    fi

    echo "[INFO] New version detected! Local: $LOCAL_HASH_BEFORE_FETCH, Remote: $REMOTE_HASH."
    echo "[INFO] Triggering main installer in update mode: $MAIN_INSTALLER_SCRIPT_PATH --update-silent"

    # The main installer script will run as root because this checker is run by root's cron.
    if "$MAIN_INSTALLER_SCRIPT_PATH" --update-silent; then
        echo "[SUCCESS] Main installer script completed successfully in update mode."
    else
        RETURN_CODE=$?
        echo "[ERROR] Main installer script failed in update mode with exit code $RETURN_CODE."
    fi

    echo "---=== [$(date)] Update Check Finished (Update Triggered) ===---"
    exit 0
    ```
    *   **Save this example checker script** (e.g., as `/usr/local/bin/gbbconnect2_update_checker.sh`).
    *   **Crucially, edit the `CLONE_DIR`, `MAIN_INSTALLER_SCRIPT_PATH`, and `APP_NAME` variables at the top of this checker script to match your setup.** The `MAIN_INSTALLER_SCRIPT_PATH` should be the absolute path to where you saved the main `install_gbbconsole.sh` script.
    *   Make it executable: `sudo chmod +x /usr/local/bin/gbbconnect2_update_checker.sh`.

2.  **Add Cron Jobs (as root):**
    Open root's crontab for editing:
    ```bash
    sudo crontab -e
    ```
    Add lines to run your checker script at desired intervals, for example, twice daily (at midnight and noon):
    ```cron
    0 0 * * * /usr/local/bin/gbbconnect2_update_checker.sh
    0 12 * * * /usr/local/bin/gbbconnect2_update_checker.sh
    ```
    Save and exit the crontab editor.

This setup allows for automated updates by leveraging the `--update-silent` mode of your main installer script.

### Contributing / Issues

If you find issues with this installer script or have suggestions for improvement, please feel free to raise an issue on its GitHub repository.

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
    *   `--update-silent`: Dla w pełni nieinteraktywnych aktualizacji, odpowiedni do automatyzacji (np. cron).

### Wymagania Wstępne (dla systemu uruchamiającego skrypt)

*   System Linux oparty na Debianie (np. zalecany Debian 11+, Ubuntu 22.04+).
*   Uprawnienia `sudo` (administratora).
*   Połączenie internetowe.
*   Podstawowa znajomość wiersza poleceń.

### Jak Używać (Instalacja i Aktualizacje)

1.  **Pobierz Skrypt:**
    Zapisz zawartość skryptu do pliku, np. `install_gbbconsole.sh`.
    ```bash
    wget -O install_gbbconsole.sh <RAW_URL_TWOJEGO_SKRYPTU_NA_GITHUB>
    ```

2.  **Nadaj Prawa do Wykonania:**
    ```bash
    chmod +x install_gbbconsole.sh
    ```

3.  **Pierwsza Instalacja Interaktywna:**
    Uruchom skrypt bez żadnych argumentów. Będziesz potrzebować uprawnień `sudo`.
    ```bash
    sudo ./install_gbbconsole.sh
    ```
    Postępuj zgodnie z monitami dotyczącymi wyboru języka, instalacji wymagań wstępnych i konfiguracji `Parameters.xml`.

4.  **Aktualizacja Wyzwalana przez Użytkownika:**
    Aby zaktualizować istniejącą instalację do najnowszej wersji z GitHub:
    ```bash
    sudo ./install_gbbconsole.sh --update
    ```
    Ten tryb:
    *   Użyje istniejącej konfiguracji (ścieżka klonowania, nazwa usługi, użytkownik).
    *   Pobierze najnowszy kod, przekompiluje.
    *   Utworzy kopię zapasową starych plików binarnych.
    *   Zachowa istniejący plik `Parameters.xml`.
    *   Zatrzyma, wdroży i zrestartuje usługę.

5.  **Cicha Aktualizacja (do automatyzacji, np. cron):**
    ```bash
    sudo ./install_gbbconsole.sh --update-silent
    ```
    Ten tryb jest przeznaczony do wykonania nieinteraktywnego. Wykonuje te same kroki aktualizacji co `--update`, ale z minimalną ilością lub bez danych wyjściowych na standardowe wyjście (błędy nadal trafią na stderr lub do logów). Zobacz sekcję "Konfiguracja Automatycznych Aktualizacji" jak używać tego z cronem.

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
*   **Aktualizacje Repozytorium GbbConnect2:** Znaczące zmiany w strukturze repozytorium źródłowego mogą wymagać aktualizacji skryptu.
*   **Automatyczne Aktualizacje:** Ten skrypt dostarcza flagi `--update` i `--update-silent` do aktualizacji aplikacji. Jednakże **nie konfiguruje** automatycznie zadań cron do okresowego sprawdzania aktualizacji. Jeśli chcesz zautomatyzować aktualizacje, zapoznaj się z poniższą sekcją "Konfiguracja Automatycznych Aktualizacji (Ręczna Konfiguracja Cron)".

### Konfiguracja Automatycznych Aktualizacji (Ręczna Konfiguracja Cron)

Chociaż ten główny skrypt instalacyjny nie konfiguruje automatycznie zadań cron, możesz łatwo skonfigurować automatyczne aktualizacje, używając jego flagi `--update-silent` wraz z osobnym, małym skryptem sprawdzającym.

1.  **Utwórz Skrypt Sprawdzający Aktualizacje (`gbbconnect2_update_checker.sh`):**
    Będziesz musiał utworzyć mały skrypt powłoki (np. `gbbconnect2_update_checker.sh`) i umieścić go w lokalizacji takiej jak `/usr/local/bin/`. Ten skrypt będzie sprawdzał GitHub w poszukiwaniu nowych commitów, a następnie wywoływał Twój główny skrypt instalacyjny z flagą `--update-silent`.

    **Przykład `gbbconnect2_update_checker.sh`:**
    ```bash
    #!/bin/bash
    
    # --- KONFIGURACJA ---
    # !!! WAŻNE: Dostosuj te ścieżki do SWOJEJ konfiguracji !!!
    CLONE_DIR="/root/GbbConnect2_build" # Ścieżka, gdzie GbbConnect2 jest sklonowane
    MAIN_INSTALLER_SCRIPT_PATH="/sciezka/do/twojego/install_gbbconsole.sh" # Bezwzględna ścieżka do TEGO skryptu instalacyjnego
    APP_NAME="gbbconnect2console" # Nazwa używana dla usługi i w /opt
    BRANCH_TO_TRACK="master" # Lub 'main', jeśli to główna gałąź
    # --- KONIEC KONFIGURACJI ---

    LOG_FILE="/var/log/${APP_NAME}_update_checker.log"

    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE" 

    exec >> "$LOG_FILE" 2>&1 

    echo "---=== [$(date)] Rozpoczęcie sprawdzania aktualizacji (Użytkownik: $(whoami)) ===---"

    if [ ! -d "$CLONE_DIR" ] || [ ! -d "$CLONE_DIR/.git" ]; then
        echo "[BŁĄD] Katalog klonowania '$CLONE_DIR' nie znaleziony lub nie jest repozytorium git. Nie można sprawdzić aktualizacji."
        echo "Główna aplikacja mogła nie zostać poprawnie zainstalowana lub katalog klonowania został przeniesiony/usunięty."
        exit 1
    fi

    cd "$CLONE_DIR" || { echo "[BŁĄD] Nie udało się przejść do '$CLONE_DIR'."; exit 1; }
    
    NEEDS_GIT_CONFIG_RESET=false
    if ! git config user.name > /dev/null 2>&1 || ! git config user.email > /dev/null 2>&1; then
        echo "[INFO] Git user.name lub user.email nie ustawione w $CLONE_DIR. Ustawianie tymczasowe dla fetch/pull."
        git config user.name "Auto Updater"
        git config user.email "updater@localhost"
        NEEDS_GIT_CONFIG_RESET=true
    fi

    LOCAL_HASH_BEFORE_FETCH=$(git rev-parse HEAD 2>/dev/null || echo "unknown_local")
    echo "[INFO] Bieżący lokalny commit w $CLONE_DIR: $LOCAL_HASH_BEFORE_FETCH"

    echo "[INFO] Pobieranie zdalnych aktualizacji dla gałęzi '$BRANCH_TO_TRACK' (z origin)..."
    if ! git fetch origin "$BRANCH_TO_TRACK"; then
        echo "[BŁĄD] Nie udało się pobrać z repozytorium zdalnego. Zamykanie."
        if [ "$NEEDS_GIT_CONFIG_RESET" = true ]; then git config --unset user.name; git config --unset user.email; fi
        exit 1
    fi
    echo "[INFO] Pobieranie zakończone."

    REMOTE_HASH=$(git rev-parse "origin/${BRANCH_TO_TRACK}" 2>/dev/null || echo "unknown_remote")
    echo "[INFO] Najnowszy zdalny commit na 'origin/${BRANCH_TO_TRACK}': $REMOTE_HASH"

    if [ "$NEEDS_GIT_CONFIG_RESET" = true ]; then
        echo "[INFO] Resetowanie tymczasowych git user.name i user.email (jeśli były ustawione)."
        git config --unset user.name &>/dev/null 
        git config --unset user.email &>/dev/null
    fi

    if [ "$LOCAL_HASH_BEFORE_FETCH" == "$REMOTE_HASH" ] || [ "$REMOTE_HASH" == "unknown_remote" ]; then
        echo "[INFO] Nie znaleziono nowych commitów. Aplikacja jest aktualna."
        echo "---=== [$(date)] Zakończono sprawdzanie aktualizacji ===---"
        exit 0
    fi

    echo "[INFO] Wykryto nową wersję! Lokalny: $LOCAL_HASH_BEFORE_FETCH, Zdalny: $REMOTE_HASH."
    echo "[INFO] Uruchamianie głównego instalatora w trybie aktualizacji: $MAIN_INSTALLER_SCRIPT_PATH --update-silent"

    if sudo "$MAIN_INSTALLER_SCRIPT_PATH" --update-silent; then
        echo "[SUKCES] Główny skrypt instalacyjny zakończony pomyślnie w trybie aktualizacji."
    else
        RETURN_CODE=$?
        echo "[BŁĄD] Główny skrypt instalacyjny zakończył się błędem w trybie aktualizacji, kod wyjścia $RETURN_CODE."
    fi

    echo "---=== [$(date)] Zakończono sprawdzanie aktualizacji (Aktualizacja uruchomiona) ===---"
    exit 0
    ```
    *   **Zapisz ten przykładowy skrypt sprawdzający** (np. jako `/usr/local/bin/gbbconnect2_update_checker.sh`).
    *   **Kluczowe: Edytuj zmienne `CLONE_DIR`, `MAIN_INSTALLER_SCRIPT_PATH` i `APP_NAME`** na początku tego skryptu sprawdzającego, aby pasowały do Twojej konfiguracji. `MAIN_INSTALLER_SCRIPT_PATH` powinna być bezwzględną ścieżką do miejsca, gdzie zapisałeś główny skrypt `install_gbbconsole.sh`.
    *   Nadaj mu prawa do wykonania: `sudo chmod +x /usr/local/bin/gbbconnect2_update_checker.sh`.

2.  **Dodaj Zadania Cron (jako root):**
    Otwórz crontab użytkownika root do edycji:
    ```bash
    sudo crontab -e
    ```
    Dodaj linie, aby uruchamiać Twój skrypt sprawdzający w wybranych interwałach, na przykład dwa razy dziennie (o północy i w południe):
    ```cron
    0 0 * * * /usr/local/bin/gbbconnect2_update_checker.sh
    0 12 * * * /usr/local/bin/gbbconnect2_update_checker.sh
    ```
    Zapisz i zamknij edytor crontab.

Ta konfiguracja pozwala na zautomatyzowane aktualizacje poprzez wykorzystanie trybu `--update-silent` Twojego głównego skryptu instalacyjnego.

### Wkład / Problemy

Jeśli znajdziesz problemy z tym skryptem instalacyjnym lub masz sugestie dotyczące ulepszeń, prosimy o zgłoszenie problemu (issue) w jego repozytorium GitHub.
