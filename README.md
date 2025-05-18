# GbbConnect2.Console Linux Installer Script

This Bash script automates the installation and configuration of the `GbbConnect2.Console` application on Debian-based Linux systems (like Debian, Ubuntu). It handles prerequisites, compilation, configuration, and sets up the application to run as a persistent `systemd` service.

**Made by @Sp3nge**

## Table of Contents

*   [English Guide](#english-guide)
    *   [Features](#features)
    *   [Prerequisites (for the system running the script)](#prerequisites-for-the-system-running-the-script)
    *   [How to Use](#how-to-use)
    *   [Script Steps Overview](#script-steps-overview)
    *   [Default Configuration Values](#default-configuration-values)
    *   [Managing the Service (after installation)](#managing-the-service-after-installation)
    *   [Log File Location (Application Logs)](#log-file-location-application-logs)
    *   [Important Notes](#important-notes)
    *   [Contributing / Issues](#contributing--issues)
*   [Polski Przewodnik](#polski-przewodnik)
    *   [Funkcjonalności](#funkcjonalnoci)
    *   [Wymagania Wstępne (dla systemu uruchamiającego skrypt)](#wymagania-wstpne-dla-systemu-uruchamiajcego-skrypt)
    *   [Jak Używać](#jak-uywa)
    *   [Przegląd Kroków Skryptu](#przegld-krokw-skryptu)
    *   [Domyślne Wartości Konfiguracyjne](#domylne-wartoci-konfiguracyjne)
    *   [Zarządzanie Usługą (po instalacji)](#zarzdzanie-usug-po-instalacji)
    *   [Lokalizacja Plików Logów (Logi Aplikacji)](#lokalizacja-plikw-logw-logi-aplikacji)
    *   [Ważne Uwagi](#wane-uwagi)
    *   [Wkład / Problemy](#wkad--problemy)

---

## English Guide

### Features

*   **Bilingual Interface:** Prompts and messages available in English and Polish.
*   **Prerequisite Installation:** Automatically installs necessary tools:
    *   Git (for cloning the repository)
    *   `lsb-release` (for OS version detection)
    *   `rsync` (for file copying)
    *   .NET SDK (currently targets version 9.0 by default)
*   **Repository Handling:**
    *   Clones the official `gbbsoft/GbbConnect2` repository.
    *   If the repository already exists, it verifies the remote URL and can optionally pull the latest changes.
*   **Compilation:**
    *   Compiles `GbbConnect2.Console` as a self-contained, single-file executable for Linux.
    *   Includes a fix for a known C# syntax issue in a specific version of `Program.cs`.
*   **Interactive Configuration (`Parameters.xml`):**
    *   Guides the user through providing necessary values for `Parameters.xml` (MQTT details, Plant ID, Token, Deye Dongle info, etc.).
    *   If `Parameters.xml` already exists, it prompts the user whether to reconfigure or keep the existing file.
*   **Application Backup:**
    *   If an existing installation is detected, it backs up the old application binaries (excluding `Parameters.xml`) to a timestamped directory before deploying the new version.
*   **Systemd Service Setup:**
    *   Creates a dedicated system user for running the service.
    *   Deploys the application to `/opt/` by default.
    *   Generates and enables a `systemd` service file to:
        *   Run `GbbConnect2.Console` in the background.
        *   Automatically start the application on system boot.
        *   Restart the application if it crashes.
        *   Log application output to the systemd journal.
*   **OS Detection & .NET SDK Installation:**
    *   Robustly detects Debian/Ubuntu versions.
    *   Uses the recommended `ppa:dotnet/backports` for .NET SDK installation on Ubuntu 22.04 and 24.04.
    *   Warns users of Ubuntu 20.04 and Debian 10 about .NET 9 incompatibility and their End-of-Life status, strongly advising against proceeding with a .NET 9 installation on these systems.
    *   Uses the Microsoft package repository for supported Debian versions (11+) and other Ubuntu versions.

### Prerequisites (for the system running the script)

*   A Debian-based Linux system (e.g., Debian 11+, Ubuntu 22.04+ recommended).
*   `sudo` (administrator) privileges to install packages and manage services.
*   Internet connection to download packages and clone the repository.
*   Basic familiarity with the command line.

### How to Use

1.  **Download the Script:**
    Save the script content to a file, for example, `install_gbbconsole.sh`.

2.  **Make the Script Executable:**
    ```bash
    chmod +x install_gbbconsole.sh
    ```

3.  **Run the Script:**
    ```bash
    ./install_gbbconsole.sh
    ```

4.  **Follow the Prompts:**
    *   The script will first ask for your preferred language (English or Polish).
    *   It will then guide you through each step, asking for confirmation and necessary input values. Default values are often provided in `[brackets]`.
    *   You will be prompted for `sudo` password when required for system operations.

### Script Steps Overview

1.  **Language Selection:** Choose English or Polish.
2.  **Prerequisite Check & Installation:** Confirms if you want to install/update Git, `lsb-release`, `rsync`, and the .NET SDK.
3.  **Repository Cloning/Verification:** Manages the local copy of the `gbbsoft/GbbConnect2` repository.
4.  **Application Compilation:** Builds the `GbbConnect2.Console` application.
5.  **Configuration & Service Setup:**
    *   Prompts for values to generate `Parameters.xml`.
    *   Handles existing `Parameters.xml` files.
    *   Backs up previous installations.
    *   Deploys the application.
    *   Creates and starts the `systemd` service.
6.  **Verification:** Provides commands to check the service status and logs.

### Default Configuration Values

The script uses some default values which you'll be prompted to confirm or change:

*   **.NET SDK Version:** 9.0
*   **Clone Directory:** `$HOME/GbbConnect2_build`
*   **Deployment Base Directory:** `/opt`
*   **Application/Service Name:** `gbbconnect2console`
*   **Service User:** `gbbconsoleuser`

### Managing the Service (after installation)

Once installed, you can manage the `gbbconnect2console` (or your chosen app name) service using `systemctl`:

*   **Check Status:**
    ```bash
    sudo systemctl status gbbconnect2console.service
    ```
*   **View Logs:**
    ```bash
    sudo journalctl -u gbbconnect2console.service -n 50 --no-pager # View last 50 lines
    sudo journalctl -f -u gbbconnect2console.service # Follow logs
    ```
*   **Stop Service:**
    ```bash
    sudo systemctl stop gbbconnect2console.service
    ```
*   **Start Service:**
    ```bash
    sudo systemctl start gbbconnect2console.service
    ```
*   **Restart Service:** (Useful after updating `Parameters.xml` or application files)
    ```bash
    sudo systemctl restart gbbconnect2console.service
    ```
*   **Enable on Boot:** (Done by the script)
    ```bash
    sudo systemctl enable gbbconnect2console.service
    ```
*   **Disable on Boot:**
    ```bash
    sudo systemctl disable gbbconnect2console.service
    ```

### Log File Location (Application Logs)

The `GbbConnect2.Console` application itself (not the systemd service logs) typically creates its logs in a subdirectory relative to its execution. Given the systemd service configuration:

*   **Working Directory:** `/opt/gbbconnect2console` (or `/opt/your-app-name`)
*   The application usually creates a `GbbConnect2/Log/` subdirectory based on its internal logic.

So, the application logs are likely found in:
**`/opt/gbbconnect2console/GbbConnect2/Log/YYYY-MM-DD.txt`**

### Important Notes

*   **Unsupported OS Versions (Ubuntu 20.04, Debian 10):**
    *   **Ubuntu 20.04** has reached its standard End of Life (EOL) for free security updates (April 2025) and Microsoft is not providing .NET 9 support for it.
    *   **Debian 10 (Buster)** has also reached its End of Life (June 2024 for LTS) and is not supported for .NET 9.
    *   This script will warn you if it detects these OS versions. Proceeding with a .NET 9 installation on them is **not recommended** and likely to fail or be unstable. **Please upgrade your OS to a supported version like Ubuntu 22.04 LTS / 24.04 LTS or Debian 11 / 12.**
*   **`Parameters.xml` Sensitivity:** The `Parameters.xml` file will contain sensitive information like your Plant Token and MQTT details. The script sets permissions on this file to `640` (readable by the service user and its group, no access for others), but ensure your system's overall security is maintained.
*   **.NET 9 Requirement:** This script and the GbbConnect2.Console project it builds target .NET 9. Ensure your OS can support this or that the .NET 9 SDK installs correctly on a supported OS version.
*   **Updates to GbbConnect2:** If the `gbbsoft/GbbConnect2` repository structure or build process changes significantly, this script might need updates.

### Contributing / Issues

If you find issues with this installer script or have suggestions for improvement, please feel free to raise an issue or contribute to its development (if it's hosted in a repository).

---

## Polski Przewodnik

### Funkcjonalności

*   **Dwujęzyczny Interfejs:** Komunikaty i monity dostępne w języku angielskim i polskim.
*   **Instalacja Wymagań Wstępnych:** Automatycznie instaluje niezbędne narzędzia:
    *   Git (do klonowania repozytorium)
    *   `lsb-release` (do wykrywania wersji systemu operacyjnego)
    *   `rsync` (do kopiowania plików)
    *   .NET SDK (domyślnie celuje w wersję 9.0)
*   **Obsługa Repozytorium:**
    *   Klonuje oficjalne repozytorium `gbbsoft/GbbConnect2`.
    *   Jeśli repozytorium już istnieje, weryfikuje zdalny URL i opcjonalnie może pobrać najnowsze zmiany.
*   **Kompilacja:**
    *   Kompiluje `GbbConnect2.Console` jako samodzielny, pojedynczy plik wykonywalny dla Linuksa.
    *   Zawiera poprawkę znanego błędu składni C# w określonej wersji pliku `Program.cs`.
*   **Interaktywna Konfiguracja (`Parameters.xml`):**
    *   Prowadzi użytkownika przez proces podawania niezbędnych wartości do pliku `Parameters.xml` (dane MQTT, ID Instalacji, Token, informacje o kluczu Deye itp.).
    *   Jeśli plik `Parameters.xml` już istnieje, pyta użytkownika, czy chce go ponownie skonfigurować, czy zachować istniejący.
*   **Kopia Zapasowa Aplikacji:**
    *   Jeśli wykryto istniejącą instalację, tworzy kopię zapasową starych plików binarnych aplikacji (z wyjątkiem `Parameters.xml`) do katalogu z sygnaturą czasową przed wdrożeniem nowej wersji.
*   **Konfiguracja Usługi Systemd:**
    *   Tworzy dedykowanego użytkownika systemowego do uruchamiania usługi.
    *   Domyślnie wdraża aplikację w katalogu `/opt/`.
    *   Generuje i włącza plik usługi `systemd`, aby:
        *   Uruchamiać `GbbConnect2.Console` w tle.
        *   Automatycznie uruchamiać aplikację podczas startu systemu.
        *   Restartować aplikację w przypadku awarii.
        *   Logować dane wyjściowe aplikacji do dziennika systemd.
*   **Wykrywanie Systemu Operacyjnego i Instalacja .NET SDK:**
    *   Solidnie wykrywa wersje Debian/Ubuntu.
    *   Używa zalecanego PPA `ppa:dotnet/backports` do instalacji .NET SDK na Ubuntu 22.04 i 24.04.
    *   Ostrzega użytkowników Ubuntu 20.04 i Debiana 10 o niekompatybilności z .NET 9 i statusie końca wsparcia, zdecydowanie odradzając kontynuowanie instalacji .NET 9 na tych systemach.
    *   Używa repozytorium pakietów Microsoft dla wspieranych wersji Debiana (11+) i innych wersji Ubuntu.

### Wymagania Wstępne (dla systemu uruchamiającego skrypt)

*   System Linux oparty na Debianie (np. zalecany Debian 11+, Ubuntu 22.04+).
*   Uprawnienia `sudo` (administratora) do instalowania pakietów i zarządzania usługami.
*   Połączenie internetowe do pobierania pakietów i klonowania repozytorium.
*   Podstawowa znajomość wiersza poleceń.

### Jak Używać

1.  **Pobierz Skrypt:**
    Zapisz zawartość skryptu do pliku, na przykład `install_gbbconsole.sh`.

2.  **Nadaj Skryptowi Prawa do Wykonania:**
    ```bash
    chmod +x install_gbbconsole.sh
    ```

3.  **Uruchom Skrypt:**
    ```bash
    ./install_gbbconsole.sh
    ```

4.  **Postępuj Zgodnie z Monitami:**
    *   Skrypt najpierw zapyta o preferowany język (angielski lub polski).
    *   Następnie przeprowadzi Cię przez każdy krok, prosząc o potwierdzenie i niezbędne dane wejściowe. Domyślne wartości są często podawane w `[nawiasach]`.
    *   Zostaniesz poproszony o hasło `sudo`, gdy będzie to wymagane do operacji systemowych.

### Przegląd Kroków Skryptu

1.  **Wybór Języka:** Wybierz angielski lub polski.
2.  **Sprawdzanie i Instalacja Wymagań Wstępnych:** Potwierdza, czy chcesz zainstalować/zaktualizować Git, `lsb-release`, `rsync` i .NET SDK.
3.  **Klonowanie/Weryfikacja Repozytorium:** Zarządza lokalną kopią repozytorium `gbbsoft/GbbConnect2`.
4.  **Kompilacja Aplikacji:** Buduje aplikację `GbbConnect2.Console`.
5.  **Konfiguracja i Ustawienie Usługi:**
    *   Pyta o wartości do wygenerowania `Parameters.xml`.
    *   Obsługuje istniejące pliki `Parameters.xml`.
    *   Tworzy kopię zapasową poprzednich instalacji.
    *   Wdraża aplikację.
    *   Tworzy i uruchamia usługę `systemd`.
6.  **Weryfikacja:** Dostarcza poleceń do sprawdzania statusu usługi i logów.

### Domyślne Wartości Konfiguracyjne

Skrypt używa pewnych wartości domyślnych, o których potwierdzenie lub zmianę zostaniesz poproszony:

*   **Wersja .NET SDK:** 9.0
*   **Katalog Klonowania:** `$HOME/GbbConnect2_build`
*   **Bazowy Katalog Wdrożenia:** `/opt`
*   **Nazwa Aplikacji/Usługi:** `gbbconnect2console`
*   **Użytkownik Usługi:** `gbbconsoleuser`

### Zarządzanie Usługą (po instalacji)

Po zainstalowaniu możesz zarządzać usługą `gbbconnect2console` (lub wybraną przez Ciebie nazwą aplikacji) za pomocą `systemctl`:

*   **Sprawdź Status:**
    ```bash
    sudo systemctl status gbbconnect2console.service
    ```
*   **Wyświetl Logi:**
    ```bash
    sudo journalctl -u gbbconnect2console.service -n 50 --no-pager # Wyświetl ostatnie 50 linii
    sudo journalctl -f -u gbbconnect2console.service # Śledź logi
    ```
*   **Zatrzymaj Usługę:**
    ```bash
    sudo systemctl stop gbbconnect2console.service
    ```
*   **Uruchom Usługę:**
    ```bash
    sudo systemctl start gbbconnect2console.service
    ```
*   **Zrestartuj Usługę:** (Przydatne po aktualizacji `Parameters.xml` lub plików aplikacji)
    ```bash
    sudo systemctl restart gbbconnect2console.service
    ```
*   **Włącz przy Starcie Systemu:** (Robione przez skrypt)
    ```bash
    sudo systemctl enable gbbconnect2console.service
    ```
*   **Wyłącz przy Starcie Systemu:**
    ```bash
    sudo systemctl disable gbbconnect2console.service
    ```

### Lokalizacja Plików Logów (Logi Aplikacji)

Aplikacja `GbbConnect2.Console` (a nie logi usługi systemd) zazwyczaj tworzy swoje logi w podkatalogu względem miejsca jej wykonania. Biorąc pod uwagę konfigurację usługi systemd:

*   **Katalog Roboczy:** `/opt/gbbconnect2console` (lub `/opt/twoja-nazwa-aplikacji`)
*   Aplikacja zwykle tworzy podkatalog `GbbConnect2/Log/` na podstawie swojej wewnętrznej logiki.

Dlatego logi aplikacji najprawdopodobniej znajdują się w:
**`/opt/gbbconnect2console/GbbConnect2/Log/RRRR-MM-DD.txt`**

### Ważne Uwagi

*   **Niewspierane Wersje Systemu (Ubuntu 20.04, Debian 10):**
    *   **Ubuntu 20.04** osiągnęło standardowy koniec wsparcia (EOL) dla darmowych aktualizacji bezpieczeństwa (kwiecień 2025), a Microsoft nie zapewnia dla niego wsparcia .NET 9.
    *   **Debian 10 (Buster)** również osiągnął koniec wsparcia (czerwiec 2024 dla LTS) i nie jest wspierany dla .NET 9.
    *   Ten skrypt ostrzeże Cię, jeśli wykryje te wersje systemu. Kontynuowanie instalacji .NET 9 na nich **nie jest zalecane** i prawdopodobnie zakończy się niepowodzeniem lub niestabilnością. **Proszę zaktualizować system operacyjny do wspieranej wersji, takiej jak Ubuntu 22.04 LTS / 24.04 LTS lub Debian 11 / 12.**
*   **Wrażliwość Pliku `Parameters.xml`:** Plik `Parameters.xml` będzie zawierał wrażliwe informacje, takie jak Token Instalacji i dane MQTT. Skrypt ustawia uprawnienia do tego pliku na `640` (czytelny dla użytkownika usługi i jego grupy, brak dostępu dla innych), ale upewnij się, że ogólne bezpieczeństwo systemu jest zachowane.
*   **Wymaganie .NET 9:** Ten skrypt i projekt GbbConnect2.Console, który buduje, celują w .NET 9. Upewnij się, że Twój system operacyjny może to obsłużyć lub że .NET 9 SDK zainstaluje się poprawnie na wspieranej wersji systemu.
*   **Aktualizacje GbbConnect2:** Jeśli struktura repozytorium `gbbsoft/GbbConnect2` lub proces budowy ulegną znaczącym zmianom, ten skrypt może wymagać aktualizacji.

### Wkład / Problemy

Jeśli znajdziesz problemy z tym skryptem instalacyjnym lub masz sugestie dotyczące ulepszeń, prosimy o zgłoszenie problemu (issue) lub wniesienie wkładu w jego rozwój (jeśli jest hostowany w repozytorium).
