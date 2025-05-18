#!/bin/bash

# Script to compile GbbConnect2.Console, configure Parameters.xml,
# and set it up as a systemd service.
# Supports interactive install, user-triggered update (--update),
# and silent update (--update-silent).

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Mode Detection ---
UPDATE_MODE=false
SILENT_UPDATE_MODE=false
INTERACTIVE_MODE=true 

if [[ "$1" == "--update-silent" ]] || [[ "$1" == "--auto-update" ]]; then # Retain --auto-update for compatibility if checker script used it
    SILENT_UPDATE_MODE=true
    UPDATE_MODE=true 
    INTERACTIVE_MODE=false
    LANG_SELECTED="en" 
    echo "[INFO] Running in SILENT Automated Update Mode." 
elif [[ "$1" == "--update" ]]; then
    UPDATE_MODE=true
    INTERACTIVE_MODE=false 
    echo "[INFO] Running in User-Triggered Update Mode." 
fi

# --- Language Selection ---
if [ "$INTERACTIVE_MODE" = true ]; then
    LANG_SELECTED="en" 
    echo "Please select your language / Proszę wybrać język:"
    echo "1. English"
    echo "2. Polski"
    while true; do
        read -r -p "Enter your choice (1 or 2) / Wprowadź wybór (1 lub 2): " lang_choice
        case "$lang_choice" in
            1) LANG_SELECTED="en"; echo "Language set to English."; break ;;
            2) LANG_SELECTED="pl"; echo "Język ustawiony na Polski."; break ;;
            *) echo "Invalid choice. / Nieprawidłowy wybór." ;;
        esac
    done
    echo "---"
elif [ "$UPDATE_MODE" = true ] && [ "$SILENT_UPDATE_MODE" = false ] && [ -z "$LANG_SELECTED_BY_FLAG" ]; then
    LANG_SELECTED="en"
fi


# --- Localized Strings ---
declare -A S_BANNER_MADE_BY; S_BANNER_MADE_BY[en]="                                Made by @Sp3nge                               "; S_BANNER_MADE_BY[pl]="                             Stworzone przez @Sp3nge                            "
declare -A S_WELCOME_TITLE; S_WELCOME_TITLE[en]="GbbConnect2.Console Setup Script"; S_WELCOME_TITLE[pl]="Skrypt Instalacyjny GbbConnect2.Console"
declare -A S_SCRIPT_GUIDE; S_SCRIPT_GUIDE[en]="This script will guide you through:"; S_SCRIPT_GUIDE[pl]="Ten skrypt przeprowadzi Cię przez:"
declare -A S_GUIDE_ITEM1; S_GUIDE_ITEM1[en]="1. Installing prerequisites (Git, lsb-release, rsync, .NET SDK)."; S_GUIDE_ITEM1[pl]="1. Instalację wymagań wstępnych (Git, lsb-release, rsync, .NET SDK)."
declare -A S_GUIDE_ITEM2; S_GUIDE_ITEM2[en]="2. Cloning/Verifying the GbbConnect2 repository."; S_GUIDE_ITEM2[pl]="2. Klonowanie/Weryfikację repozytorium GbbConnect2."
declare -A S_GUIDE_ITEM3; S_GUIDE_ITEM3[en]="3. Compiling GbbConnect2.Console."; S_GUIDE_ITEM3[pl]="3. Kompilację GbbConnect2.Console."
declare -A S_GUIDE_ITEM4; S_GUIDE_ITEM4[en]="4. Configuring Parameters.xml, backing up old versions, and setting up systemd service."; S_GUIDE_ITEM4[pl]="4. Konfigurację Parameters.xml, tworzenie kopii zapasowej starych wersji i ustawianie usługi systemd."
declare -A S_GUIDE_ITEM5; S_GUIDE_ITEM5[en]="5. Verification and service management."; S_GUIDE_ITEM5[pl]="5. Weryfikację i zarządzanie usługą." # Removed auto-update part
declare -A S_INFO_PREFIX; S_INFO_PREFIX[en]="[INFO]"; S_INFO_PREFIX[pl]="[INFO]"
declare -A S_SUCCESS_PREFIX; S_SUCCESS_PREFIX[en]="[SUCCESS]"; S_SUCCESS_PREFIX[pl]="[SUKCES]"
declare -A S_WARNING_PREFIX; S_WARNING_PREFIX[en]="[WARNING]"; S_WARNING_PREFIX[pl]="[OSTRZEŻENIE]"
declare -A S_ERROR_PREFIX; S_ERROR_PREFIX[en]="[ERROR]"; S_ERROR_PREFIX[pl]="[BŁĄD]"
declare -A S_CONFIRM_PROMPT_SUFFIX; S_CONFIRM_PROMPT_SUFFIX[en]="[y/N]: "; S_CONFIRM_PROMPT_SUFFIX[pl]="[t/N]: "
declare -A S_INVALID_INPUT_CONFIRM; S_INVALID_INPUT_CONFIRM[en]="Invalid input. Please answer 'y' or 'n'."; S_INVALID_INPUT_CONFIRM[pl]="Nieprawidłowe dane. Proszę odpowiedzieć 't' lub 'n'."
declare -A S_FIELD_CANNOT_BE_EMPTY; S_FIELD_CANNOT_BE_EMPTY[en]="This field cannot be empty."; S_FIELD_CANNOT_BE_EMPTY[pl]="To pole nie może być puste."
declare -A S_STEP1_TITLE; S_STEP1_TITLE[en]="Step 1: Checking and Installing Prerequisites"; S_STEP1_TITLE[pl]="Krok 1: Sprawdzanie i Instalowanie Wymagań Wstępnych"
declare -A S_CONFIRM_PREREQUISITES; S_CONFIRM_PREREQUISITES[en]="Do you want to check/install Git, lsb-release, rsync, and .NET SDK"; S_CONFIRM_PREREQUISITES[pl]="Czy chcesz sprawdzić/zainstalować Git, lsb-release, rsync oraz .NET SDK"
declare -A S_UPDATING_PACKAGES; S_UPDATING_PACKAGES[en]="Updating package lists..."; S_UPDATING_PACKAGES[pl]="Aktualizowanie list pakietów..."
declare -A S_GIT_NOT_FOUND; S_GIT_NOT_FOUND[en]="Git not found. Installing Git..."; S_GIT_NOT_FOUND[pl]="Nie znaleziono Git. Instalowanie Git..."
declare -A S_GIT_INSTALLED_SUCCESS; S_GIT_INSTALLED_SUCCESS[en]="Git installed."; S_GIT_INSTALLED_SUCCESS[pl]="Git zainstalowany."
declare -A S_GIT_ALREADY_INSTALLED; S_GIT_ALREADY_INSTALLED[en]="Git is already installed."; S_GIT_ALREADY_INSTALLED[pl]="Git jest już zainstalowany."
declare -A S_LSB_RELEASE_NOT_FOUND; S_LSB_RELEASE_NOT_FOUND[en]="'lsb-release' command not found. Installing lsb-release package..."; S_LSB_RELEASE_NOT_FOUND[pl]="Nie znaleziono polecenia 'lsb-release'. Instalowanie pakietu lsb-release..."
declare -A S_LSB_RELEASE_INSTALLED_SUCCESS; S_LSB_RELEASE_INSTALLED_SUCCESS[en]="'lsb-release' package installed."; S_LSB_RELEASE_INSTALLED_SUCCESS[pl]="Pakiet 'lsb-release' zainstalowany."
declare -A S_LSB_RELEASE_ALREADY_INSTALLED; S_LSB_RELEASE_ALREADY_INSTALLED[en]="'lsb-release' is already installed."; S_LSB_RELEASE_ALREADY_INSTALLED[pl]="'lsb-release' jest już zainstalowany."
declare -A S_RSYNC_NOT_FOUND; S_RSYNC_NOT_FOUND[en]="'rsync' command not found. Installing rsync package..."; S_RSYNC_NOT_FOUND[pl]="Nie znaleziono polecenia 'rsync'. Instalowanie pakietu rsync..."
declare -A S_RSYNC_INSTALLED_SUCCESS; S_RSYNC_INSTALLED_SUCCESS[en]="'rsync' package installed."; S_RSYNC_INSTALLED_SUCCESS[pl]="Pakiet 'rsync' zainstalowany."
declare -A S_RSYNC_ALREADY_INSTALLED; S_RSYNC_ALREADY_INSTALLED[en]="'rsync' is already installed."; S_RSYNC_ALREADY_INSTALLED[pl]="'rsync' jest już zainstalowany."
declare -A S_DOTNET_ALREADY_INSTALLED_MSG; S_DOTNET_ALREADY_INSTALLED_MSG[en]=".NET SDK version %s.x seems to be already installed."; S_DOTNET_ALREADY_INSTALLED_MSG[pl]="Wygląda na to, że .NET SDK w wersji %s.x jest już zainstalowany."
declare -A S_DOTNET_CONFIRM_REINSTALL_MSG; S_DOTNET_CONFIRM_REINSTALL_MSG[en]="Do you want to proceed with .NET SDK installation/update anyway?"; S_DOTNET_CONFIRM_REINSTALL_MSG[pl]="Czy chcesz kontynuować instalację/aktualizację .NET SDK mimo to?"
declare -A S_DOTNET_NOT_FOUND_MSG; S_DOTNET_NOT_FOUND_MSG[en]=".NET SDK %s not found or a different major version is primary."; S_DOTNET_NOT_FOUND_MSG[pl]="Nie znaleziono .NET SDK %s lub główna wersja jest inna."
declare -A S_DOTNET_INSTALLING_MSG; S_DOTNET_INSTALLING_MSG[en]="Installing .NET SDK %s (for Debian/Ubuntu)..."; S_DOTNET_INSTALLING_MSG[pl]="Instalowanie .NET SDK %s (dla Debian/Ubuntu)..."
declare -A S_LSB_RELEASE_UNAVAILABLE_MANUAL_PROMPT; S_LSB_RELEASE_UNAVAILABLE_MANUAL_PROMPT[en]="'lsb-release' is not available. You may need to input your OS version manually."; S_LSB_RELEASE_UNAVAILABLE_MANUAL_PROMPT[pl]="Polecenie 'lsb-release' nie jest dostępne. Może być konieczne ręczne wprowadzenie wersji systemu operacyjnego."
declare -A S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT; S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT[en]="Could not automatically detect OS version. Do you want to try to proceed by manually entering your Debian/Ubuntu version (e.g., 11, 12 for Debian; 20.04, 22.04 for Ubuntu)?"; S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT[pl]="Nie można automatycznie wykryć wersji systemu. Czy chcesz spróbować kontynuować, wprowadzając ręcznie wersję Debian/Ubuntu (np. 11, 12 dla Debiana; 20.04, 22.04 dla Ubuntu)?"
declare -A S_OS_VERSION_PROMPT; S_OS_VERSION_PROMPT[en]="Enter your OS version"; S_OS_VERSION_PROMPT[pl]="Wprowadź wersję swojego systemu operacyjnego"
declare -A S_NO_OS_VERSION_ENTERED_ABORT; S_NO_OS_VERSION_ENTERED_ABORT[en]="No OS version entered. Aborting .NET SDK installation."; S_NO_OS_VERSION_ENTERED_ABORT[pl]="Nie wprowadzono wersji systemu. Przerywanie instalacji .NET SDK."
declare -A S_ABORT_NO_OS_VERSION; S_ABORT_NO_OS_VERSION[en]="Aborting .NET SDK installation as OS version is unknown."; S_ABORT_NO_OS_VERSION[pl]="Przerywanie instalacji .NET SDK, ponieważ wersja systemu jest nieznana."
declare -A S_USING_OS_VERSION_FOR_SETUP; S_USING_OS_VERSION_FOR_SETUP[en]="Using OS version: %s for .NET SDK repository setup."; S_USING_OS_VERSION_FOR_SETUP[pl]="Używanie wersji systemu: %s do konfiguracji repozytorium .NET SDK."
declare -A S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN; S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN[en]="Could not reliably determine if OS is Debian or Ubuntu. Assuming Debian structure for .NET repo URL."; S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN[pl]="Nie można wiarygodnie określić, czy system to Debian czy Ubuntu. Przyjmowanie struktury Debiana dla adresu URL repozytorium .NET."
declare -A S_ATTEMPTING_DOWNLOAD_FROM; S_ATTEMPTING_DOWNLOAD_FROM[en]="Attempting to download from: %s"; S_ATTEMPTING_DOWNLOAD_FROM[pl]="Próba pobrania z: %s"
declare -A S_DOTNET_INSTALL_COMPLETE; S_DOTNET_INSTALL_COMPLETE[en]=".NET SDK %s installation process completed."; S_DOTNET_INSTALL_COMPLETE[pl]="Proces instalacji .NET SDK %s zakończony."
declare -A S_DOTNET_VERIFYING_INSTALL; S_DOTNET_VERIFYING_INSTALL[en]="Verifying .NET SDK installation..."; S_DOTNET_VERIFYING_INSTALL[pl]="Weryfikowanie instalacji .NET SDK..."
declare -A S_DOWNLOAD_PKG_FAIL; S_DOWNLOAD_PKG_FAIL[en]="Failed to download packages-microsoft-prod.deb. Please check the URL and your network connection."; S_DOWNLOAD_PKG_FAIL[pl]="Nie udało się pobrać packages-microsoft-prod.deb. Sprawdź adres URL i połączenie sieciowe."
declare -A S_DOTNET_SKIPPING_INSTALL; S_DOTNET_SKIPPING_INSTALL[en]="Skipping .NET SDK installation."; S_DOTNET_SKIPPING_INSTALL[pl]="Pominięcie instalacji .NET SDK."
declare -A S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET; S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET[en]="Could not determine OS version. Skipping .NET SDK installation."; S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET[pl]="Nie można określić wersji systemu. Pominięcie instalacji .NET SDK."
declare -A S_DOTNET_MANUAL_INSTALL_NOTE; S_DOTNET_MANUAL_INSTALL_NOTE[en]="You might need to install it manually for your distribution."; S_DOTNET_MANUAL_INSTALL_NOTE[pl]="Może być konieczna ręczna instalacja dla Twojej dystrybucji."
declare -A S_DOTNET_SKIPPING_UPDATE; S_DOTNET_SKIPPING_UPDATE[en]="Skipping .NET SDK installation/update."; S_DOTNET_SKIPPING_UPDATE[pl]="Pominięcie instalacji/aktualizacji .NET SDK."
declare -A S_PREREQ_SKIPPING_ALL; S_PREREQ_SKIPPING_ALL[en]="Skipping prerequisite installation. Please ensure Git, lsb-release, rsync, and .NET SDK %s are installed."; S_PREREQ_SKIPPING_ALL[pl]="Pominięcie instalacji wymagań wstępnych. Upewnij się, że Git, lsb-release, rsync oraz .NET SDK %s są zainstalowane."
declare -A S_PREREQ_ESSENTIAL_EXIT; S_PREREQ_ESSENTIAL_EXIT[en]="Prerequisites are essential. Exiting."; S_PREREQ_ESSENTIAL_EXIT[pl]="Wymagania wstępne są niezbędne. Zamykanie."
declare -A S_UBUNTU_2004_EOL_WARNING; S_UBUNTU_2004_EOL_WARNING[en]="WARNING: Ubuntu 20.04 reaches its standard end-of-life in April 2025. Microsoft has stated that .NET 9 will NOT be supported on Ubuntu 20.04. You should upgrade your OS to a supported version (e.g., Ubuntu 22.04 or 24.04) to use .NET 9 and receive security updates."; S_UBUNTU_2004_EOL_WARNING[pl]="OSTRZEŻENIE: Standardowe wsparcie dla Ubuntu 20.04 kończy się w kwietniu 2025. Microsoft ogłosił, że .NET 9 NIE będzie wspierany na Ubuntu 20.04. Zalecana jest aktualizacja systemu operacyjnego do wspieranej wersji (np. Ubuntu 22.04 lub 24.04), aby móc korzystać z .NET 9 i otrzymywać aktualizacje bezpieczeństwa."
declare -A S_DEBIAN_10_EOL_WARNING; S_DEBIAN_10_EOL_WARNING[en]="WARNING: Debian 10 (Buster) has reached its end-of-life (June 2024 for LTS). .NET 9 is NOT supported on Debian 10. You should upgrade your OS to a supported version (e.g., Debian 11 or 12) to use .NET 9 and receive security updates."; S_DEBIAN_10_EOL_WARNING[pl]="OSTRZEŻENIE: Debian 10 (Buster) osiągnął koniec wsparcia (czerwiec 2024 dla LTS). .NET 9 NIE jest wspierany na Debianie 10. Zalecana jest aktualizacja systemu operacyjnego do wspieranej wersji (np. Debian 11 lub 12), aby móc korzystać z .NET 9 i otrzymywać aktualizacje bezpieczeństwa."
declare -A S_CONFIRM_DOTNET9_ON_UNSUPPORTED_OS; S_CONFIRM_DOTNET9_ON_UNSUPPORTED_OS[en]="Do you wish to attempt installing .NET 9.0 on this unsupported OS version despite the warning (this is highly likely to fail)?"; S_CONFIRM_DOTNET9_ON_UNSUPPORTED_OS[pl]="Czy chcesz spróbować zainstalować .NET 9.0 na tej niewspieranej wersji systemu pomimo ostrzeżenia (jest to wysoce prawdopodobne, że się nie uda)?"
declare -A S_SKIPPING_DOTNET9_UNSUPPORTED_OS; S_SKIPPING_DOTNET9_UNSUPPORTED_OS[en]="Skipping .NET 9.0 installation due to OS limitations and user choice."; S_SKIPPING_DOTNET9_UNSUPPORTED_OS[pl]="Pominięcie instalacji .NET 9.0 z powodu ograniczeń systemu operacyjnego i wyboru użytkownika."
declare -A S_USING_PPA_FOR_UBUNTU; S_USING_PPA_FOR_UBUNTU[en]="Using Ubuntu PPA method for .NET SDK installation on Ubuntu %s..."; S_USING_PPA_FOR_UBUNTU[pl]="Używanie metody PPA Ubuntu do instalacji .NET SDK na Ubuntu %s..."
declare -A S_INSTALLING_SOFTWARE_PROPERTIES; S_INSTALLING_SOFTWARE_PROPERTIES[en]="Ensuring 'software-properties-common' is installed for PPA support..."; S_INSTALLING_SOFTWARE_PROPERTIES[pl]="Zapewnianie instalacji 'software-properties-common' dla obsługi PPA..."
declare -A S_ADDING_PPA_DOTNET_BACKPORTS; S_ADDING_PPA_DOTNET_BACKPORTS[en]="Adding ppa:dotnet/backports repository..."; S_ADDING_PPA_DOTNET_BACKPORTS[pl]="Dodawanie repozytorium ppa:dotnet/backports..."
declare -A S_DOTNET9_PPA_INSTALL_FAILED; S_DOTNET9_PPA_INSTALL_FAILED[en]="Failed to install dotnet-sdk-%s from PPA. This might mean it's not yet available in backports for your Ubuntu version, or another issue occurred. Please check .NET 9.0 availability for your OS or try installing it manually."; S_DOTNET9_PPA_INSTALL_FAILED[pl]="Nie udało się zainstalować dotnet-sdk-%s z PPA. Może to oznaczać, że nie jest jeszcze dostępny w backports dla Twojej wersji Ubuntu lub wystąpił inny problem. Sprawdź dostępność .NET 9.0 dla swojego systemu lub spróbuj zainstalować ręcznie."
declare -A S_USING_MS_REPO_METHOD; S_USING_MS_REPO_METHOD[en]="Using Microsoft package repository method for .NET SDK installation..."; S_USING_MS_REPO_METHOD[pl]="Używanie metody repozytorium pakietów Microsoft do instalacji .NET SDK..."
declare -A S_DOTNET9_MSREPO_INSTALL_FAILED; S_DOTNET9_MSREPO_INSTALL_FAILED[en]="Failed to install dotnet-sdk-%s from Microsoft repository. Please check .NET 9.0 availability for your OS or try installing it manually."; S_DOTNET9_MSREPO_INSTALL_FAILED[pl]="Nie udało się zainstalować dotnet-sdk-%s z repozytorium Microsoft. Sprawdź dostępność .NET 9.0 dla swojego systemu lub spróbuj zainstalować ręcznie."
declare -A S_DOTNET_AUTO_INSTALL_FAIL_MANUAL_NOTE; S_DOTNET_AUTO_INSTALL_FAIL_MANUAL_NOTE[en]="Automatic .NET SDK installation for this OS combination is not fully configured. Please try manual installation."; S_DOTNET_AUTO_INSTALL_FAIL_MANUAL_NOTE[pl]="Automatyczna instalacja .NET SDK dla tej kombinacji systemu operacyjnego nie jest w pełni skonfigurowana. Spróbuj instalacji ręcznej."
declare -A S_DOTNET_CMD_NOT_FOUND_AFTER_ATTEMPT; S_DOTNET_CMD_NOT_FOUND_AFTER_ATTEMPT[en]="dotnet command not found after installation attempt. .NET SDK installation likely failed."; S_DOTNET_CMD_NOT_FOUND_AFTER_ATTEMPT[pl]="Nie znaleziono polecenia dotnet po próbie instalacji. Instalacja .NET SDK prawdopodobnie nie powiodła się."
declare -A S_ESSENTIAL_TOOLS_VERIFY_UPDATE; S_ESSENTIAL_TOOLS_VERIFY_UPDATE[en]="[UPDATE MODE] Verifying essential tools for update..."; S_ESSENTIAL_TOOLS_VERIFY_UPDATE[pl]="[TRYB AKTUALIZACJI] Weryfikacja niezbędnych narzędzi do aktualizacji..."
declare -A S_ESSENTIAL_TOOLS_MISSING_UPDATE_EXIT; S_ESSENTIAL_TOOLS_MISSING_UPDATE_EXIT[en]="[UPDATE MODE] Essential tools missing. Please run the installer interactively first to install prerequisites."; S_ESSENTIAL_TOOLS_MISSING_UPDATE_EXIT[pl]="[TRYB AKTUALIZACJI] Brakuje niezbędnych narzędzi. Uruchom najpierw instalator interaktywnie, aby zainstalować wymagania wstępne."
declare -A S_ESSENTIAL_TOOLS_VERIFIED_UPDATE; S_ESSENTIAL_TOOLS_VERIFIED_UPDATE[en]="[UPDATE MODE] Essential tools verified."; S_ESSENTIAL_TOOLS_VERIFIED_UPDATE[pl]="[TRYB AKTUALIZACJI] Niezbędne narzędzia zweryfikowane."

# --- Step 2: Clone ---
declare -A S_STEP2_TITLE; S_STEP2_TITLE[en]="Step 2: Cloning/Verifying GbbConnect2 Repository"; S_STEP2_TITLE[pl]="Krok 2: Klonowanie/Weryfikacja Repozytorium GbbConnect2"
declare -A S_PROMPT_CLONE_DIR; S_PROMPT_CLONE_DIR[en]="Enter directory where the repository should be (or already is)"; S_PROMPT_CLONE_DIR[pl]="Wprowadź katalog, w którym repozytorium powinno się znajdować (lub już jest)"
declare -A S_REPO_DIR_EXISTS; S_REPO_DIR_EXISTS[en]="Repository directory '%s' already exists."; S_REPO_DIR_EXISTS[pl]="Katalog repozytorium '%s' już istnieje."
declare -A S_IS_CORRECT_REPO; S_IS_CORRECT_REPO[en]="It appears to be the correct GbbConnect2 repository."; S_IS_CORRECT_REPO[pl]="Wygląda na to, że jest to poprawne repozytorium GbbConnect2."
declare -A S_CONFIRM_GIT_PULL; S_CONFIRM_GIT_PULL[en]="Do you want to fetch the latest changes (git pull)?"; S_CONFIRM_GIT_PULL[pl]="Czy chcesz pobrać najnowsze zmiany (git pull)?"
declare -A S_FETCHING_LATEST; S_FETCHING_LATEST[en]="Fetching latest changes for '%s'..."; S_FETCHING_LATEST[pl]="Pobieranie najnowszych zmian dla '%s'..."
declare -A S_REPO_UPDATED; S_REPO_UPDATED[en]="Repository updated."; S_REPO_UPDATED[pl]="Repozytorium zaktualizowane."
declare -A S_PULL_FAILED; S_PULL_FAILED[en]="Failed to pull latest changes. Continuing with the current version."; S_PULL_FAILED[pl]="Nie udało się pobrać najnowszych zmian. Kontynuowanie z bieżącą wersją."
declare -A S_SKIPPING_UPDATE_USE_CURRENT; S_SKIPPING_UPDATE_USE_CURRENT[en]="Skipping update. Using current version in '%s'."; S_SKIPPING_UPDATE_USE_CURRENT[pl]="Pominięcie aktualizacji. Używanie bieżącej wersji w '%s'."
declare -A S_DIR_EXISTS_WRONG_REPO_URL; S_DIR_EXISTS_WRONG_REPO_URL[en]="The directory '%s' exists but its remote origin URL ('%s') does not match the expected '%s'."; S_DIR_EXISTS_WRONG_REPO_URL[pl]="Katalog '%s' istnieje, ale jego zdalny adres URL ('%s') nie pasuje do oczekiwanego '%s'."
declare -A S_DIR_EXISTS_NOT_GIT; S_DIR_EXISTS_NOT_GIT[en]="The directory '%s' exists but does not appear to be a Git repository."; S_DIR_EXISTS_NOT_GIT[pl]="Katalog '%s' istnieje, ale nie wydaje się być repozytorium Git."
declare -A S_CONFIRM_REMOVE_AND_RECLONE; S_CONFIRM_REMOVE_AND_RECLONE[en]="Do you want to remove the existing directory '%s' and clone the correct repository anew?"; S_CONFIRM_REMOVE_AND_RECLONE[pl]="Czy chcesz usunąć istniejący katalog '%s' i sklonować poprawne repozytorium od nowa?"
declare -A S_REMOVING_DIR; S_REMOVING_DIR[en]="Removing existing directory '%s'..."; S_REMOVING_DIR[pl]="Usuwanie istniejącego katalogu '%s'..."
declare -A S_CLONING_REPO_TO; S_CLONING_REPO_TO[en]="Cloning %s into %s..."; S_CLONING_REPO_TO[pl]="Klonowanie %s do %s..."
declare -A S_REPO_CLONED_SUCCESS; S_REPO_CLONED_SUCCESS[en]="Repository cloned."; S_REPO_CLONED_SUCCESS[pl]="Repozytorium sklonowane."
declare -A S_CANNOT_PROCEED_WRONG_REPO; S_CANNOT_PROCEED_WRONG_REPO[en]="Cannot proceed without the correct repository at '%s'. Exiting."; S_CANNOT_PROCEED_WRONG_REPO[pl]="Nie można kontynuować bez poprawnego repozytorium w '%s'. Zamykanie."
declare -A S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE; S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE[en]="Repository directory '%s' does not exist. Do you want to clone %s into it?"; S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE[pl]="Katalog repozytorium '%s' nie istnieje. Czy chcesz sklonować %s do niego?"
declare -A S_REPO_NOT_FOUND_DECLINED_CLONE; S_REPO_NOT_FOUND_DECLINED_CLONE[en]="Repository not found at '%s' and cloning was declined. Exiting."; S_REPO_NOT_FOUND_DECLINED_CLONE[pl]="Nie znaleziono repozytorium w '%s', a klonowanie zostało odrzucone. Zamykanie."
declare -A S_PROMPT_DEFAULT_CLONE_DIR_UPDATE; S_PROMPT_DEFAULT_CLONE_DIR_UPDATE[en]="[UPDATE MODE] Using clone directory: %s"; S_PROMPT_DEFAULT_CLONE_DIR_UPDATE[pl]="[TRYB AKTUALIZACJI] Używanie katalogu klonowania: %s"
declare -A S_CLONE_DIR_NOT_EXIST_UPDATE_EXIT; S_CLONE_DIR_NOT_EXIST_UPDATE_EXIT[en]="[UPDATE MODE] Clone directory '%s' does not exist. Cannot update. Please run installer interactively first."; S_CLONE_DIR_NOT_EXIST_UPDATE_EXIT[pl]="[TRYB AKTUALIZACJI] Katalog klonowania '%s' nie istnieje. Nie można zaktualizować. Uruchom najpierw instalator interaktywnie."
declare -A S_CLONE_DIR_NOT_GIT_UPDATE_EXIT; S_CLONE_DIR_NOT_GIT_UPDATE_EXIT[en]="[UPDATE MODE] Directory '%s' is not a Git repository. Cannot update."; S_CLONE_DIR_NOT_GIT_UPDATE_EXIT[pl]="[TRYB AKTUALIZACJI] Katalog '%s' nie jest repozytorium Git. Nie można zaktualizować."
declare -A S_REMOTE_URL_MISMATCH_UPDATE_EXIT; S_REMOTE_URL_MISMATCH_UPDATE_EXIT[en]="[UPDATE MODE] Remote URL mismatch in '%s'. Expected '%s', found '%s'. Cannot update."; S_REMOTE_URL_MISMATCH_UPDATE_EXIT[pl]="[TRYB AKTUALIZACJI] Niezgodność zdalnego URL w '%s'. Oczekiwano '%s', znaleziono '%s'. Nie można zaktualizować."
declare -A S_GIT_PULLING_UPDATE; S_GIT_PULLING_UPDATE[en]="[UPDATE MODE] Pulling latest changes for '%s'..."; S_GIT_PULLING_UPDATE[pl]="[TRYB AKTUALIZACJI] Pobieranie najnowszych zmian dla '%s'..."
declare -A S_GIT_PULL_FAILED_UPDATE_EXIT; S_GIT_PULL_FAILED_UPDATE_EXIT[en]="[UPDATE MODE] Failed to pull latest changes. Aborting update."; S_GIT_PULL_FAILED_UPDATE_EXIT[pl]="[TRYB AKTUALIZACJI] Nie udało się pobrać najnowszych zmian. Przerywanie aktualizacji."
declare -A S_REPO_PULLED_SUCCESS_UPDATE; S_REPO_PULLED_SUCCESS_UPDATE[en]="[UPDATE MODE] Repository updated via pull."; S_REPO_PULLED_SUCCESS_UPDATE[pl]="[TRYB AKTUALIZACJI] Repozytorium zaktualizowane przez pull."

# --- Step 3: Compile ---
declare -A S_STEP3_TITLE; S_STEP3_TITLE[en]="Step 3: Compiling GbbConnect2.Console"; S_STEP3_TITLE[pl]="Krok 3: Kompilacja GbbConnect2.Console"
declare -A S_CONSOLE_PROJECT_PATH_NOT_FOUND; S_CONSOLE_PROJECT_PATH_NOT_FOUND[en]="Console project path '%s' not found."; S_CONSOLE_PROJECT_PATH_NOT_FOUND[pl]="Nie znaleziono ścieżki projektu konsoli '%s'."
declare -A S_PROGRAM_CS_SYNTAX_ERROR_DETECTED; S_PROGRAM_CS_SYNTAX_ERROR_DETECTED[en]="Detected potential syntax error (extra dot) in '%s'. Attempting to fix..."; S_PROGRAM_CS_SYNTAX_ERROR_DETECTED[pl]="Wykryto potencjalny błąd składni (dodatkowa kropka) w '%s'. Próba naprawy..."
declare -A S_PROGRAM_CS_SYNTAX_FIXED; S_PROGRAM_CS_SYNTAX_FIXED[en]="Potential syntax error fixed in '%s'."; S_PROGRAM_CS_SYNTAX_FIXED[pl]="Potencjalny błąd składni naprawiony w '%s'."
declare -A S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK; S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK[en]="Program.cs file not found at '%s'. Skipping syntax check."; S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK[pl]="Nie znaleziono pliku Program.cs w '%s'. Pomijanie sprawdzania składni."
declare -A S_CURRENT_DIRECTORY; S_CURRENT_DIRECTORY[en]="Current directory: %s"; S_CURRENT_DIRECTORY[pl]="Bieżący katalog: %s"
declare -A S_CONFIRM_CLEAN_BUILD_ARTIFACTS; S_CONFIRM_CLEAN_BUILD_ARTIFACTS[en]="Clean previous build artifacts (bin, obj, %s)?"; S_CONFIRM_CLEAN_BUILD_ARTIFACTS[pl]="Wyczyścić poprzednie artefakty kompilacji (bin, obj, %s)?"
declare -A S_CLEANING_BUILD_ARTIFACTS; S_CLEANING_BUILD_ARTIFACTS[en]="Cleaning previous build artifacts..."; S_CLEANING_BUILD_ARTIFACTS[pl]="Czyszczenie poprzednich artefaktów kompilacji..."
declare -A S_PUBLISHING_APP_FOR_RUNTIME; S_PUBLISHING_APP_FOR_RUNTIME[en]="Publishing GbbConnect2.Console for %s..."; S_PUBLISHING_APP_FOR_RUNTIME[pl]="Publikowanie GbbConnect2.Console dla %s..."
declare -A S_APP_PUBLISHED_TO; S_APP_PUBLISHED_TO[en]="Application published to '%s'."; S_APP_PUBLISHED_TO[pl]="Aplikacja opublikowana do '%s'."
declare -A S_DOTNET_PUBLISH_FAILED; S_DOTNET_PUBLISH_FAILED[en]="dotnet publish command failed. Please check the output above for errors."; S_DOTNET_PUBLISH_FAILED[pl]="Polecenie dotnet publish nie powiodło się. Sprawdź powyższy wynik w poszukiwaniu błędów."

# --- Step 4: Service Setup & Parameters.xml ---
declare -A S_STEP4_TITLE; S_STEP4_TITLE[en]="Step 4: Configuring Parameters.xml, backing up old versions, and setting up systemd service"; S_STEP4_TITLE[pl]="Krok 4: Konfiguracja Parameters.xml, tworzenie kopii zapasowej starych wersji i ustawianie usługi systemd"
declare -A S_CONFIRM_PARAMS_AND_SERVICE_SETUP; S_CONFIRM_PARAMS_AND_SERVICE_SETUP[en]="Do you want to proceed with configuring Parameters.xml and setting up the systemd service?"; S_CONFIRM_PARAMS_AND_SERVICE_SETUP[pl]="Czy chcesz kontynuować konfigurację Parameters.xml i ustawianie usługi systemd?"
declare -A S_SKIPPING_PARAMS_AND_SERVICE_SETUP; S_SKIPPING_PARAMS_AND_SERVICE_SETUP[en]="Skipping Parameters.xml and systemd service setup."; S_SKIPPING_PARAMS_AND_SERVICE_SETUP[pl]="Pominięcie konfiguracji Parameters.xml i usługi systemd."
declare -A S_SETUP_FINISHED_APP_AT; S_SETUP_FINISHED_APP_AT[en]="Setup script finished. You can find the compiled application at '%s'."; S_SETUP_FINISHED_APP_AT[pl]="Skrypt instalacyjny zakończony. Skompilowaną aplikację można znaleźć w '%s'."
declare -A S_PROMPT_SERVICE_USER; S_PROMPT_SERVICE_USER[en]="Enter desired service user name"; S_PROMPT_SERVICE_USER[pl]="Wprowadź żądaną nazwę użytkownika usługi"
declare -A S_PROMPT_APP_NAME_FOR_SERVICE; S_PROMPT_APP_NAME_FOR_SERVICE[en]="Enter application name for service and directory"; S_PROMPT_APP_NAME_FOR_SERVICE[pl]="Wprowadź nazwę aplikacji dla usługi i katalogu"
declare -A S_PROMPT_DEFAULT_SERVICE_INFO_UPDATE; S_PROMPT_DEFAULT_SERVICE_INFO_UPDATE[en]="[UPDATE MODE] Using service user: %s, app name: %s"; S_PROMPT_DEFAULT_SERVICE_INFO_UPDATE[pl]="[TRYB AKTUALIZACJI] Używanie użytkownika usługi: %s, nazwa aplikacji: %s"
declare -A S_USER_ALREADY_EXISTS; S_USER_ALREADY_EXISTS[en]="User '%s' already exists."; S_USER_ALREADY_EXISTS[pl]="Użytkownik '%s' już istnieje."
declare -A S_CREATING_SYSTEM_USER; S_CREATING_SYSTEM_USER[en]="Creating system user '%s'..."; S_CREATING_SYSTEM_USER[pl]="Tworzenie użytkownika systemowego '%s'..."
declare -A S_USER_CREATED_SUCCESS; S_USER_CREATED_SUCCESS[en]="User '%s' created."; S_USER_CREATED_SUCCESS[pl]="Użytkownik '%s' utworzony."
declare -A S_DEPLOYING_FILES_TO; S_DEPLOYING_FILES_TO[en]="Deploying application files to '%s'..."; S_DEPLOYING_FILES_TO[pl]="Wdrażanie plików aplikacji do '%s'..."
declare -A S_DEPLOY_DIR_EXISTS_EMPTY_SKIP_BACKUP; S_DEPLOY_DIR_EXISTS_EMPTY_SKIP_BACKUP[en]="Deployment directory '%s' exists but seems empty or only contains Parameters.xml/backups. Skipping backup of binaries."; S_DEPLOY_DIR_EXISTS_EMPTY_SKIP_BACKUP[pl]="Katalog wdrożenia '%s' istnieje, ale wydaje się pusty lub zawiera tylko Parameters.xml/kopie zapasowe. Pomijanie tworzenia kopii zapasowej plików binarnych."
declare -A S_BACKING_UP_OLD_VERSION; S_BACKING_UP_OLD_VERSION[en]="Backing up existing application version in '%s' to '%s'..."; S_BACKING_UP_OLD_VERSION[pl]="Tworzenie kopii zapasowej istniejącej wersji aplikacji w '%s' do '%s'..."
declare -A S_BACKUP_SUCCESSFUL; S_BACKUP_SUCCESSFUL[en]="Backup successful."; S_BACKUP_SUCCESSFUL[pl]="Kopia zapasowa utworzona pomyślnie."
declare -A S_BACKUP_FAILED; S_BACKUP_FAILED[en]="Backup failed. Please check permissions or disk space."; S_BACKUP_FAILED[pl]="Tworzenie kopii zapasowej nie powiodło się. Sprawdź uprawnienia lub miejsce na dysku."
declare -A S_PARAMS_XML_EXISTS; S_PARAMS_XML_EXISTS[en]="An existing Parameters.xml file was found at '%s'."; S_PARAMS_XML_EXISTS[pl]="Znaleziono istniejący plik Parameters.xml w '%s'."
declare -A S_CONFIRM_RECONFIGURE_PARAMS; S_CONFIRM_RECONFIGURE_PARAMS[en]="Do you want to reconfigure Parameters.xml now? (Choosing 'N' will keep the existing one)"; S_CONFIRM_RECONFIGURE_PARAMS[pl]="Czy chcesz teraz ponownie skonfigurować Parameters.xml? (Wybór 'N' zachowa istniejący)"
declare -A S_KEEPING_EXISTING_PARAMS; S_KEEPING_EXISTING_PARAMS[en]="Keeping the existing Parameters.xml file."; S_KEEPING_EXISTING_PARAMS[pl]="Zachowywanie istniejącego pliku Parameters.xml."
declare -A S_SKIPPING_PARAMS_CONFIG_USER_CHOICE; S_SKIPPING_PARAMS_CONFIG_USER_CHOICE[en]="Skipping Parameters.xml configuration as per user choice."; S_SKIPPING_PARAMS_CONFIG_USER_CHOICE[pl]="Pominięcie konfiguracji Parameters.xml zgodnie z wyborem użytkownika."
declare -A S_PARAMS_XML_MISSING_UPDATE_CRITICAL; S_PARAMS_XML_MISSING_UPDATE_CRITICAL[en]="[UPDATE MODE] CRITICAL: Parameters.xml not found at '%s' during update. Cannot proceed without configuration. Please run interactively."; S_PARAMS_XML_MISSING_UPDATE_CRITICAL[pl]="[TRYB AKTUALIZACJI] KRYTYCZNY: Nie znaleziono Parameters.xml w '%s' podczas aktualizacji. Nie można kontynuować bez konfiguracji. Uruchom interaktywnie."
declare -A S_PRESERVING_PARAMS_XML_UPDATE; S_PRESERVING_PARAMS_XML_UPDATE[en]="[UPDATE MODE] Preserving existing Parameters.xml at '%s'."; S_PRESERVING_PARAMS_XML_UPDATE[pl]="[TRYB AKTUALIZACJI] Zachowywanie istniejącego Parameters.xml w '%s'."
declare -A S_CONFIGURING_PARAMS_XML; S_CONFIGURING_PARAMS_XML[en]="Configuring Parameters.xml"; S_CONFIGURING_PARAMS_XML[pl]="Konfiguracja Parameters.xml"
declare -A S_PARAMS_PROMPT_INTRO; S_PARAMS_PROMPT_INTRO[en]="You will now be prompted for values to create/update Parameters.xml."; S_PARAMS_PROMPT_INTRO[pl]="Zostaniesz teraz poproszony o wartości do utworzenia/aktualizacji Parameters.xml."
declare -A S_MQTT_SERVER_INFO_URL; S_MQTT_SERVER_INFO_URL[en]="MQTT Server Address can be found at: https://gbboptimizer2.gbbsoft.pl/Manual?Filters.PageNo=14"; S_MQTT_SERVER_INFO_URL[pl]="Adres serwera MQTT można znaleźć pod adresem: https://gbboptimizer2.gbbsoft.pl/Manual?Filters.PageNo=14"
declare -A S_PLANT_ID_TOKEN_INFO; S_PLANT_ID_TOKEN_INFO[en]="Plant ID and Plant Token: Found in Gbb Website menu Plants, button Edit, at the end of the page."; S_PLANT_ID_TOKEN_INFO[pl]="ID Instalacji i Token Instalacji: Znajdują się w menu Instalacje na stronie Gbb, przycisk Edytuj, na końcu strony."
declare -A S_PROMPT_GBB_PLANT_NAME; S_PROMPT_GBB_PLANT_NAME[en]="Enter Gbb Plant Name (e.g., My Home Plant)"; S_PROMPT_GBB_PLANT_NAME[pl]="Wprowadź nazwę instalacji Gbb (np. Moja Domowa Instalacja)"
declare -A S_PROMPT_DEYE_IP; S_PROMPT_DEYE_IP[en]="Enter Deye Dongle IP Address (e.g., 192.168.1.50)"; S_PROMPT_DEYE_IP[pl]="Wprowadź adres IP klucza Deye (np. 192.168.1.50)"
declare -A S_PROMPT_DEYE_SN; S_PROMPT_DEYE_SN[en]="Enter Deye Dongle Serial Number (e.g., 1234567890)"; S_PROMPT_DEYE_SN[pl]="Wprowadź numer seryjny klucza Deye (np. 1234567890)"
declare -A S_PROMPT_PLANT_ID; S_PROMPT_PLANT_ID[en]="Enter GbbVictronWeb Plant ID"; S_PROMPT_PLANT_ID[pl]="Wprowadź ID Instalacji GbbVictronWeb"
declare -A S_PROMPT_PLANT_TOKEN; S_PROMPT_PLANT_TOKEN[en]="Enter GbbVictronWeb Plant Token"; S_PROMPT_PLANT_TOKEN[pl]="Wprowadź Token Instalacji GbbVictronWeb"
declare -A S_PROMPT_MQTT_ADDRESS; S_PROMPT_MQTT_ADDRESS[en]="Enter MQTT Server Address (e.g., gbboptimizerX-mqtt.gbbsoft.pl)"; S_PROMPT_MQTT_ADDRESS[pl]="Wprowadź adres serwera MQTT (np. gbboptimizerX-mqtt.gbbsoft.pl)"
declare -A S_PROMPT_MQTT_PORT; S_PROMPT_MQTT_PORT[en]="Enter MQTT Server Port"; S_PROMPT_MQTT_PORT[pl]="Wprowadź port serwera MQTT"
declare -A S_WRITING_PARAMS_XML_TO; S_WRITING_PARAMS_XML_TO[en]="Writing configured Parameters.xml to '%s'..."; S_WRITING_PARAMS_XML_TO[pl]="Zapisywanie skonfigurowanego Parameters.xml do '%s'..."
declare -A S_PARAMS_XML_CONFIGURED_SUCCESS; S_PARAMS_XML_CONFIGURED_SUCCESS[en]="Parameters.xml configured."; S_PARAMS_XML_CONFIGURED_SUCCESS[pl]="Parameters.xml skonfigurowany."
declare -A S_COPYING_BINARIES_FROM_TO; S_COPYING_BINARIES_FROM_TO[en]="Copying new application binaries from '%s' to '%s'..."; S_COPYING_BINARIES_FROM_TO[pl]="Kopiowanie nowych plików binarnych aplikacji z '%s' do '%s'..."
declare -A S_SETTING_FINAL_OWNERSHIP_PERMS; S_SETTING_FINAL_OWNERSHIP_PERMS[en]="Setting final ownership and permissions for '%s'..."; S_SETTING_FINAL_OWNERSHIP_PERMS[pl]="Ustawianie ostatecznej własności i uprawnień dla '%s'..."
declare -A S_APP_DEPLOYED_PERMS_SET_SUCCESS; S_APP_DEPLOYED_PERMS_SET_SUCCESS[en]="Application deployed and permissions set."; S_APP_DEPLOYED_PERMS_SET_SUCCESS[pl]="Aplikacja wdrożona, a uprawnienia ustawione."
declare -A S_STOPPING_SERVICE_BEFORE_UPDATE; S_STOPPING_SERVICE_BEFORE_UPDATE[en]="[UPDATE MODE] Stopping service '%s' before deploying new files..."; S_STOPPING_SERVICE_BEFORE_UPDATE[pl]="[TRYB AKTUALIZACJI] Zatrzymywanie usługi '%s' przed wdrożeniem nowych plików..."
declare -A S_SERVICE_STOP_FAILED_UPDATE_WARN; S_SERVICE_STOP_FAILED_UPDATE_WARN[en]="[UPDATE MODE] Failed to stop service. Update will proceed, but service might need manual restart if issues occur."; S_SERVICE_STOP_FAILED_UPDATE_WARN[pl]="[TRYB AKTUALIZACJI] Nie udało się zatrzymać usługi. Aktualizacja będzie kontynuowana, ale usługa może wymagać ręcznego restartu w przypadku problemów."
declare -A S_CREATING_SERVICE_FILE_AT; S_CREATING_SERVICE_FILE_AT[en]="Creating systemd service file at '%s'..."; S_CREATING_SERVICE_FILE_AT[pl]="Tworzenie pliku usługi systemd w '%s'..."
declare -A S_SERVICE_NAME_SANITIZED; S_SERVICE_NAME_SANITIZED[en]="Service name '%s' was sanitized to '%s' for the service file name."; S_SERVICE_NAME_SANITIZED[pl]="Nazwa usługi '%s' została oczyszczona do '%s' dla nazwy pliku usługi."
declare -A S_SERVICE_FILE_CREATED_SUCCESS; S_SERVICE_FILE_CREATED_SUCCESS[en]="Systemd service file created."; S_SERVICE_FILE_CREATED_SUCCESS[pl]="Plik usługi systemd utworzony."
declare -A S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE; S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE[en]="Reloading systemd daemon, enabling and starting service '%s'..."; S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE[pl]="Przeładowywanie demona systemd, włączanie i uruchamianie usługi '%s'..."
declare -A S_SERVICE_ENABLED_STARTED_SUCCESS; S_SERVICE_ENABLED_STARTED_SUCCESS[en]="Service '%s' enabled and started/restarted."; S_SERVICE_ENABLED_STARTED_SUCCESS[pl]="Usługa '%s' włączona i uruchomiona/zrestartowana."

# --- Step 5: Verification & Auto-Update Setup ---
declare -A S_STEP5_TITLE; S_STEP5_TITLE[en]="Step 5: Verification and Service Management"; S_STEP5_TITLE[pl]="Krok 5: Weryfikacja i Zarządzanie Usługą" # Removed auto-update from title
declare -A S_SERVICE_SHOULD_BE_RUNNING; S_SERVICE_SHOULD_BE_RUNNING[en]="The service '%s' should now be running."; S_SERVICE_SHOULD_BE_RUNNING[pl]="Usługa '%s' powinna teraz działać."
declare -A S_CHECK_STATUS_WITH; S_CHECK_STATUS_WITH[en]="You can check its status with:"; S_CHECK_STATUS_WITH[pl]="Możesz sprawdzić jej status za pomocą:"
declare -A S_VIEW_LATEST_LOGS_WITH; S_VIEW_LATEST_LOGS_WITH[en]="View latest logs with:"; S_VIEW_LATEST_LOGS_WITH[pl]="Wyświetl najnowsze logi za pomocą:"
declare -A S_FOLLOW_LOGS_WITH; S_FOLLOW_LOGS_WITH[en]="Follow logs in real-time with (Ctrl+C to stop):"; S_FOLLOW_LOGS_WITH[pl]="Śledź logi w czasie rzeczywistym za pomocą (Ctrl+C aby zatrzymać):"
declare -A S_TO_MANAGE_SERVICE; S_TO_MANAGE_SERVICE[en]="To manage the service:"; S_TO_MANAGE_SERVICE[pl]="Aby zarządzać usługą:"
declare -A S_SERVICE_STOP; S_SERVICE_STOP[en]="Stop"; S_SERVICE_STOP[pl]="Zatrzymaj"
declare -A S_SERVICE_START; S_SERVICE_START[en]="Start"; S_SERVICE_START[pl]="Uruchom"
declare -A S_SERVICE_RESTART; S_SERVICE_RESTART[en]="Restart"; S_SERVICE_RESTART[pl]="Zrestartuj"
declare -A S_SERVICE_DISABLE_AUTOSTART; S_SERVICE_DISABLE_AUTOSTART[en]="Disable auto-start"; S_SERVICE_DISABLE_AUTOSTART[pl]="Wyłącz automatyczne uruchamianie"
declare -A S_SCRIPT_FINISHED_SUCCESS; S_SCRIPT_FINISHED_SUCCESS[en]="GbbConnect2.Console setup script finished!"; S_SCRIPT_FINISHED_SUCCESS[pl]="Skrypt instalacyjny GbbConnect2.Console zakończony!"
declare -A S_UPDATE_SILENT_FINISHED; S_UPDATE_SILENT_FINISHED[en]="[SILENT UPDATE] Automated update process finished."; S_UPDATE_SILENT_FINISHED[pl]="[TRYB CICHY] Proces automatycznej aktualizacji zakończony."
declare -A S_UPDATE_USER_TRIGGERED_FINISHED; S_UPDATE_USER_TRIGGERED_FINISHED[en]="[UPDATE MODE] Update process finished."; S_UPDATE_USER_TRIGGERED_FINISHED[pl]="[TRYB AKTUALIZACJI] Proces aktualizacji zakończony."
declare -A S_UPDATE_SERVICE_ACTIVE; S_UPDATE_SERVICE_ACTIVE[en]="[UPDATE MODE] Service '%s' is active after update."; S_UPDATE_SERVICE_ACTIVE[pl]="[TRYB AKTUALIZACJI] Usługa '%s' jest aktywna po aktualizacji."
declare -A S_UPDATE_SERVICE_NOT_ACTIVE; S_UPDATE_SERVICE_NOT_ACTIVE[en]="[UPDATE MODE] Service '%s' is NOT active after update. Please check logs: sudo journalctl -u %s"; S_UPDATE_SERVICE_NOT_ACTIVE[pl]="[TRYB AKTUALIZACJI] Usługa '%s' NIE jest aktywna po aktualizacji. Sprawdź logi: sudo journalctl -u %s"
# Removed cron-specific S_ strings

# --- Configuration Variables ---
DEFAULT_CLONE_DIR="$HOME/GbbConnect2_build"
DEFAULT_CONSOLE_PROJECT_SUBDIR="GbbConnect2Console"
DEFAULT_DOTNET_SDK_VERSION="9.0"
DEFAULT_DEPLOY_BASE_DIR="/opt"
DEFAULT_APP_NAME="gbbconnect2console"
DEFAULT_SERVICE_USER="gbbconsoleuser"
DEFAULT_PUBLISH_TARGET_RUNTIME="linux-x64"
DEFAULT_MQTT_PORT="8883"

# --- Helper Functions ---
print_info() {
    if [ "$SILENT_UPDATE_MODE" = true ]; then return; fi
    echo -e "\n\033[1;34m${S_INFO_PREFIX[$LANG_SELECTED]}\033[0m $1"
}
print_success() {
    if [ "$SILENT_UPDATE_MODE" = true ]; then return; fi
    echo -e "\033[1;32m${S_SUCCESS_PREFIX[$LANG_SELECTED]}\033[0m $1"
}
print_warning() {
    # Warnings should probably still be shown or logged even in silent mode.
    # For now, let's allow them to print to stderr for cron to catch, or log them if we had a dedicated update log.
    # If truly silent means no stdout/stderr, then this should also check SILENT_UPDATE_MODE.
    echo -e "\033[1;33m${S_WARNING_PREFIX[$LANG_SELECTED]}\033[0m $1" >&2
}
print_error() {
    echo -e "\033[1;31m${S_ERROR_PREFIX[$LANG_SELECTED]}\033[0m $1" >&2
}

confirm_action() {
    local prompt_text="$1"
    if [ "$SILENT_UPDATE_MODE" = true ]; then
        # Default 'yes' for non-destructive actions in silent update mode
        if [[ "$prompt_text" == *"${S_CONFIRM_CLEAN_BUILD_ARTIFACTS[$LANG_SELECTED]}"* ]]; then return 0; fi
        # For most other cases in silent update, we should avoid prompting or have specific logic.
        # This is a catch-all; ideally, silent mode won't hit generic confirm_actions.
        return 0 
    fi
    # echo "DEBUG: confirm_action called with prompt: [$prompt_text]" # DEBUG
    while true; do
        read -r -p "$prompt_text ${S_CONFIRM_PROMPT_SUFFIX[$LANG_SELECTED]}" response
        # echo "DEBUG: User response was: [$response]" # DEBUG
        case "$response" in
            [yYtT][aA][kK]|[yYtT]) return 0;;
            [nN][iI][eE]|[nN]|"") return 1;;
            *) echo "${S_INVALID_INPUT_CONFIRM[$LANG_SELECTED]}";;
        esac
    done
}

prompt_with_default() {
    local prompt_message="$1"; local default_value="$2"; local variable_name="$3"; local input_value
    if [ "$SILENT_UPDATE_MODE" = true ]; then
        eval "$variable_name=\"$default_value\""; return
    fi
    read -r -p "$prompt_message [${default_value}]: " input_value
    eval "$variable_name=\"${input_value:-$default_value}\""
}

prompt_for_value() {
    local prompt_message="$1"; local variable_name="$2"; local input_value
    if [ "$SILENT_UPDATE_MODE" = true ]; then
        L_SILENT_PROMPT_ERROR_FORMATTED=$(printf "Attempted to prompt for mandatory value in SILENT mode: %s. This indicates a logic error or missing configuration." "$prompt_message") # TODO: Localize this internal error
        print_error "$L_SILENT_PROMPT_ERROR_FORMATTED"
        exit 1 
    fi
    while true; do
        read -r -p "$prompt_message: " input_value
        if [ -n "$input_value" ]; then
            eval "$variable_name=\"$input_value\""; break
        else
            print_warning "${S_FIELD_CANNOT_BE_EMPTY[$LANG_SELECTED]}"; fi
    done
}

# --- Main Script Body ---

if [ "$INTERACTIVE_MODE" = true ]; then
    # Banner Art
    echo -e "\033[1;36m" 
    echo "  ____ _     _      ____                            _     ____         "
    echo " / ___| |__ | |__  / ___|___  _ __  _ __   ___  ___| |_  |___ \        "
    echo "| |  _| '_ \| '_ \| |   / _ \| '_ \| '_ \ / _ \/ __| __|   __) |       "
    echo "| |_| | |_) | |_) | |__| (_) | | | | | | |  __/ (__| |_   / __/        "
    echo " \____|_.__/|_.__/ \____\___/|_| |_|_| |_|\___|\___|\__| |_____|       "
    echo "|_ _|_ __  ___| |_ __ _| | | ___ _ __   / _| ___  _ __                 "
    echo " | || '_ \/ __| __/ _\` | | |/ _ \ '__| | |_ / _ \| '__|                "
    echo " | || | | \__ \ || (_| | | |  __/ |    |  _| (_) | |                   "
    echo "|___|_| |_|___/\__\__,_|_|_|\___|_|___ |_| _\___/|_|         _         "
    echo "|  _ \  ___| |__ (_) __ _ _ __    / / | | | |__  _   _ _ __ | |_ _   _ "
    echo "| | | |/ _ \ '_ \| |/ _\` | '_ \  / /| | | | '_ \| | | | '_ \| __| | | |"
    echo "| |_| |  __/ |_) | | (_| | | | |/ / | |_| | |_) | |_| | | | | |_| |_| |"
    echo "|____/ \___|_.__/|_|\__,_|_| |_/_/   \___/|_.__/ \__,_|_| |_|\__|\__,_|"
    echo ""
    echo "${S_BANNER_MADE_BY[$LANG_SELECTED]}"
    echo -e "\033[0m" 

    print_info "${S_WELCOME_TITLE[$LANG_SELECTED]}"
    echo "${S_SCRIPT_GUIDE[$LANG_SELECTED]}"
    echo "${S_GUIDE_ITEM1[$LANG_SELECTED]}"
    echo "${S_GUIDE_ITEM2[$LANG_SELECTED]}"
    echo "${S_GUIDE_ITEM3[$LANG_SELECTED]}"
    echo "${S_GUIDE_ITEM4[$LANG_SELECTED]}"
    echo "${S_GUIDE_ITEM5[$LANG_SELECTED]}"
    echo "---"
fi

# --- 1. Prerequisites ---
if [ "$INTERACTIVE_MODE" = true ]; then
    print_info "${S_STEP1_TITLE[$LANG_SELECTED]}"
    PREREQ_CONFIRM_MSG=$(printf "%s %s?" "${S_CONFIRM_PREREQUISITES[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION")

    if confirm_action "$PREREQ_CONFIRM_MSG"; then
        print_info "${S_UPDATING_PACKAGES[$LANG_SELECTED]}"; sudo apt update
        if ! command -v git &> /dev/null; then print_info "${S_GIT_NOT_FOUND[$LANG_SELECTED]}"; sudo apt install -y git; print_success "${S_GIT_INSTALLED_SUCCESS[$LANG_SELECTED]}"; else print_info "${S_GIT_ALREADY_INSTALLED[$LANG_SELECTED]}"; fi
        if ! command -v lsb_release &> /dev/null; then print_info "${S_LSB_RELEASE_NOT_FOUND[$LANG_SELECTED]}"; sudo apt install -y lsb-release; print_success "${S_LSB_RELEASE_INSTALLED_SUCCESS[$LANG_SELECTED]}"; else print_info "${S_LSB_RELEASE_ALREADY_INSTALLED[$LANG_SELECTED]}"; fi
        if ! command -v rsync &> /dev/null; then print_info "${S_RSYNC_NOT_FOUND[$LANG_SELECTED]}"; sudo apt install -y rsync; print_success "${S_RSYNC_INSTALLED_SUCCESS[$LANG_SELECTED]}"; else print_info "${S_RSYNC_ALREADY_INSTALLED[$LANG_SELECTED]}"; fi

        SDK_MAJOR_VERSION=$(echo "$DEFAULT_DOTNET_SDK_VERSION" | cut -d. -f1)
        INSTALL_DOTNET_SDK_NOW=false
        L_DOTNET_ALREADY_INSTALLED_MSG_FORMATTED=$(printf "${S_DOTNET_ALREADY_INSTALLED_MSG[$LANG_SELECTED]}" "$SDK_MAJOR_VERSION")
        L_DOTNET_NOT_FOUND_MSG_FORMATTED=$(printf "${S_DOTNET_NOT_FOUND_MSG[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION")

        if command -v dotnet &> /dev/null && dotnet --list-sdks | grep -q "^${SDK_MAJOR_VERSION}\."; then
            print_info "$L_DOTNET_ALREADY_INSTALLED_MSG_FORMATTED"
            if confirm_action "${S_DOTNET_CONFIRM_REINSTALL_MSG[$LANG_SELECTED]}"; then INSTALL_DOTNET_SDK_NOW=true; fi
        else
            print_info "$L_DOTNET_NOT_FOUND_MSG_FORMATTED"; INSTALL_DOTNET_SDK_NOW=true
        fi

        if [ "$INSTALL_DOTNET_SDK_NOW" = true ]; then
            L_DOTNET_INSTALLING_MSG_FORMATTED=$(printf "${S_DOTNET_INSTALLING_MSG[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION"); print_info "$L_DOTNET_INSTALLING_MSG_FORMATTED"
            OS_VERSION_TO_USE=""; if command -v lsb_release &> /dev/null; then OS_VERSION_TO_USE=$(lsb_release -rs); fi
            if [ -z "$OS_VERSION_TO_USE" ]; then
                if confirm_action "${S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT[$LANG_SELECTED]}"; then
                    read -r -p "${S_OS_VERSION_PROMPT[$LANG_SELECTED]}: " OS_VERSION_MANUAL
                    if [ -z "$OS_VERSION_MANUAL" ]; then print_error "${S_NO_OS_VERSION_ENTERED_ABORT[$LANG_SELECTED]}"; else OS_VERSION_TO_USE="$OS_VERSION_MANUAL"; fi
                else print_error "${S_ABORT_NO_OS_VERSION[$LANG_SELECTED]}"; fi
            fi

            if [ -n "$OS_VERSION_TO_USE" ]; then
                L_USING_OS_VERSION_FOR_SETUP_FORMATTED=$(printf "${S_USING_OS_VERSION_FOR_SETUP[$LANG_SELECTED]}" "$OS_VERSION_TO_USE"); print_info "$L_USING_OS_VERSION_FOR_SETUP_FORMATTED"
                OS_TYPE="unknown" 
                if [ -f /etc/os-release ]; then . /etc/os-release; if [ "$ID" == "ubuntu" ]; then OS_TYPE="ubuntu"; elif [ "$ID" == "debian" ]; then OS_TYPE="debian"; fi; fi
                if [ "$OS_TYPE" == "unknown" ]; then
                    if (grep -qi "ubuntu" /etc/os-release &>/dev/null); then OS_TYPE="ubuntu"; elif (grep -qi "debian" /etc/os-release &>/dev/null || [ -f /etc/debian_version ]); then OS_TYPE="debian"; else L_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN_FORMATTED=$(printf "${S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN[$LANG_SELECTED]}"); print_warning "$L_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN_FORMATTED"; OS_TYPE="debian"; fi
                fi
                ATTEMPT_DOTNET_INSTALL_FLAG=true 
                if [ "$OS_TYPE" == "ubuntu" ] && [ "$OS_VERSION_TO_USE" == "20.04" ]; then
                    print_warning "${S_UBUNTU_2004_EOL_WARNING[$LANG_SELECTED]}"; if ! confirm_action "${S_CONFIRM_DOTNET9_ON_UNSUPPORTED_OS[$LANG_SELECTED]}"; then print_info "${S_SKIPPING_DOTNET9_UNSUPPORTED_OS[$LANG_SELECTED]}"; ATTEMPT_DOTNET_INSTALL_FLAG=false; fi
                elif [ "$OS_TYPE" == "debian" ] && [ "$OS_VERSION_TO_USE" == "10" ]; then # Debian 10 is version "10"
                    print_warning "${S_DEBIAN_10_EOL_WARNING[$LANG_SELECTED]}"; if ! confirm_action "${S_CONFIRM_DOTNET9_ON_UNSUPPORTED_OS[$LANG_SELECTED]}"; then print_info "${S_SKIPPING_DOTNET9_UNSUPPORTED_OS[$LANG_SELECTED]}"; ATTEMPT_DOTNET_INSTALL_FLAG=false; fi
                fi

                if [ "$ATTEMPT_DOTNET_INSTALL_FLAG" = true ]; then
                    if [ "$OS_TYPE" == "ubuntu" ] && ([ "$OS_VERSION_TO_USE" == "22.04" ] || [ "$OS_VERSION_TO_USE" == "24.04" ]); then
                        L_USING_PPA_FOR_UBUNTU_FORMATTED=$(printf "${S_USING_PPA_FOR_UBUNTU[$LANG_SELECTED]}" "$OS_VERSION_TO_USE"); print_info "$L_USING_PPA_FOR_UBUNTU_FORMATTED"
                        print_info "${S_INSTALLING_SOFTWARE_PROPERTIES[$LANG_SELECTED]}"; sudo apt install -y software-properties-common 
                        print_info "${S_ADDING_PPA_DOTNET_BACKPORTS[$LANG_SELECTED]}"; sudo add-apt-repository -y ppa:dotnet/backports; sudo apt update
                        if ! sudo apt install -y "dotnet-sdk-${DEFAULT_DOTNET_SDK_VERSION}"; then L_DOTNET9_PPA_INSTALL_FAILED_FORMATTED=$(printf "${S_DOTNET9_PPA_INSTALL_FAILED[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION"); print_error "$L_DOTNET9_PPA_INSTALL_FAILED_FORMATTED"; else L_DOTNET_INSTALL_COMPLETE_FORMATTED=$(printf "${S_DOTNET_INSTALL_COMPLETE[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION"); print_success "$L_DOTNET_INSTALL_COMPLETE_FORMATTED"; fi
                    # Exclude Debian 10 explicitly from MS repo method if ATTEMPT_DOTNET_INSTALL_FLAG was set to false for it
                    elif ([ "$OS_TYPE" == "debian" ] && [ "$OS_VERSION_TO_USE" != "10" ]) || \
                         ([ "$OS_TYPE" == "ubuntu" ] && ([ "$OS_VERSION_TO_USE" == "20.04" ] || ([ "$OS_VERSION_TO_USE" != "22.04" ] && [ "$OS_VERSION_TO_USE" != "24.04" ]))) || \
                         ([ "$OS_TYPE" == "debian" ] && [ "$OS_VERSION_TO_USE" == "10" ] && [ "$ATTEMPT_DOTNET_INSTALL_FLAG" = true ]) || \
                         ([ "$OS_TYPE" == "ubuntu" ] && [ "$OS_VERSION_TO_USE" == "20.04" ] && [ "$ATTEMPT_DOTNET_INSTALL_FLAG" = true ]); then # User forced attempt on unsupported
                        print_info "${S_USING_MS_REPO_METHOD[$LANG_SELECTED]}"
                        PACKAGE_URL="https://packages.microsoft.com/config/${OS_TYPE}/${OS_VERSION_TO_USE}/packages-microsoft-prod.deb"
                        L_ATTEMPTING_DOWNLOAD_FROM_FORMATTED=$(printf "${S_ATTEMPTING_DOWNLOAD_FROM[$LANG_SELECTED]}" "$PACKAGE_URL"); print_info "$L_ATTEMPTING_DOWNLOAD_FROM_FORMATTED"
                        if wget "$PACKAGE_URL" -O packages-microsoft-prod.deb; then
                            sudo dpkg -i packages-microsoft-prod.deb; rm packages-microsoft-prod.deb; sudo apt update; sudo apt install -y apt-transport-https; sudo apt update 
                            if ! sudo apt install -y "dotnet-sdk-${DEFAULT_DOTNET_SDK_VERSION}"; then L_DOTNET9_MSREPO_INSTALL_FAILED_FORMATTED=$(printf "${S_DOTNET9_MSREPO_INSTALL_FAILED[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION"); print_error "$L_DOTNET9_MSREPO_INSTALL_FAILED_FORMATTED"; else L_DOTNET_INSTALL_COMPLETE_FORMATTED=$(printf "${S_DOTNET_INSTALL_COMPLETE[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION"); print_success "$L_DOTNET_INSTALL_COMPLETE_FORMATTED"; fi
                        else print_error "${S_DOWNLOAD_PKG_FAIL[$LANG_SELECTED]}"; print_error "${S_DOTNET_SKIPPING_INSTALL[$LANG_SELECTED]}"; fi
                    elif [ "$ATTEMPT_DOTNET_INSTALL_FLAG" = true ]; then # This means it's an OS we don't have a specific rule for, but user didn't say no for an unsupported one.
                         print_warning "${S_DOTNET_AUTO_INSTALL_FAIL_MANUAL_NOTE[$LANG_SELECTED]}";
                    fi
                fi 
                
                if command -v dotnet &> /dev/null; then print_info "${S_DOTNET_VERIFYING_INSTALL[$LANG_SELECTED]}"; dotnet --version; elif [ "$ATTEMPT_DOTNET_INSTALL_FLAG" = true ]; then print_error "${S_DOTNET_CMD_NOT_FOUND_AFTER_ATTEMPT[$LANG_SELECTED]}"; fi
            else print_error "${S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET[$LANG_SELECTED]}"; print_error "${S_DOTNET_MANUAL_INSTALL_NOTE[$LANG_SELECTED]}"; fi
        else print_info "${S_DOTNET_SKIPPING_UPDATE[$LANG_SELECTED]}"; fi
    else 
        L_PREREQ_SKIPPING_ALL_FORMATTED=$(printf "${S_PREREQ_SKIPPING_ALL[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION"); print_info "$L_PREREQ_SKIPPING_ALL_FORMATTED"
        print_error "${S_PREREQ_ESSENTIAL_EXIT[$LANG_SELECTED]}"; exit 1
    fi
    echo "---"
elif [ "$UPDATE_MODE" = true ]; then 
    print_info "${S_ESSENTIAL_TOOLS_VERIFY_UPDATE[$LANG_SELECTED]}"
    ESSENTIALS_MET=true
    if ! command -v git &> /dev/null; then print_error "[UPDATE MODE] Git not found. Cannot update."; ESSENTIALS_MET=false; fi 
    if ! command -v rsync &> /dev/null; then print_error "[UPDATE MODE] rsync not found. Cannot update."; ESSENTIALS_MET=false; fi 
    if ! command -v dotnet &> /dev/null || ! dotnet --list-sdks | grep -q "^$(echo $DEFAULT_DOTNET_SDK_VERSION | cut -d. -f1)\."; then
        print_error "[UPDATE MODE] .NET SDK ${DEFAULT_DOTNET_SDK_VERSION} not found. Cannot proceed with update." 
        ESSENTIALS_MET=false
    fi
    if [ "$ESSENTIALS_MET" = false ]; then print_error "${S_ESSENTIAL_TOOLS_MISSING_UPDATE_EXIT[$LANG_SELECTED]}"; exit 1; fi
    print_success "${S_ESSENTIAL_TOOLS_VERIFIED_UPDATE[$LANG_SELECTED]}"
    echo "---"
fi
# --- Continuation of Script: Part 2 ---

# --- 2. Clone Repository ---
print_info "${S_STEP2_TITLE[$LANG_SELECTED]}"
GITHUB_REPO="https://github.com/gbbsoft/GbbConnect2.git" 

if [ "$INTERACTIVE_MODE" = true ]; then
    L_PROMPT_CLONE_DIR_FORMATTED=$(printf "%s" "${S_PROMPT_CLONE_DIR[$LANG_SELECTED]}")
    prompt_with_default "$L_PROMPT_CLONE_DIR_FORMATTED" "$DEFAULT_CLONE_DIR" CLONE_DIR
else 
    CLONE_DIR="$DEFAULT_CLONE_DIR" 
    if [ "$SILENT_UPDATE_MODE" = false ]; then 
        L_PROMPT_DEFAULT_CLONE_DIR_UPDATE_FORMATTED=$(printf "${S_PROMPT_DEFAULT_CLONE_DIR_UPDATE[$LANG_SELECTED]}" "$CLONE_DIR")
        print_info "$L_PROMPT_DEFAULT_CLONE_DIR_UPDATE_FORMATTED"
    fi
fi

if [ ! -d "$CLONE_DIR" ]; then
    if [ "$UPDATE_MODE" = true ]; then 
        L_CLONE_DIR_NOT_EXIST_UPDATE_EXIT_FORMATTED=$(printf "${S_CLONE_DIR_NOT_EXIST_UPDATE_EXIT[$LANG_SELECTED]}" "$CLONE_DIR"); print_error "$L_CLONE_DIR_NOT_EXIST_UPDATE_EXIT_FORMATTED"; exit 1
    fi
    L_REPO_DIR_NOT_EXIST_CONFIRM_CLONE_FORMATTED=$(printf "${S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE[$LANG_SELECTED]}" "$CLONE_DIR" "$GITHUB_REPO")
    if confirm_action "$L_REPO_DIR_NOT_EXIST_CONFIRM_CLONE_FORMATTED"; then
        L_CLONING_REPO_TO_FORMATTED=$(printf "${S_CLONING_REPO_TO[$LANG_SELECTED]}" "$GITHUB_REPO" "$CLONE_DIR"); print_info "$L_CLONING_REPO_TO_FORMATTED"; git clone "$GITHUB_REPO" "$CLONE_DIR"; print_success "${S_REPO_CLONED_SUCCESS[$LANG_SELECTED]}"
    else L_REPO_NOT_FOUND_DECLINED_CLONE_FORMATTED=$(printf "${S_REPO_NOT_FOUND_DECLINED_CLONE[$LANG_SELECTED]}" "$CLONE_DIR"); print_error "$L_REPO_NOT_FOUND_DECLINED_CLONE_FORMATTED"; exit 1; fi
fi

if [ ! -d "$CLONE_DIR/.git" ]; then
    if [ "$UPDATE_MODE" = true ]; then
        L_CLONE_DIR_NOT_GIT_UPDATE_EXIT_FORMATTED=$(printf "${S_CLONE_DIR_NOT_GIT_UPDATE_EXIT[$LANG_SELECTED]}" "$CLONE_DIR"); print_error "$L_CLONE_DIR_NOT_GIT_UPDATE_EXIT_FORMATTED"; exit 1
    fi
    L_DIR_EXISTS_NOT_GIT_FORMATTED=$(printf "${S_DIR_EXISTS_NOT_GIT[$LANG_SELECTED]}" "$CLONE_DIR"); print_warning "$L_DIR_EXISTS_NOT_GIT_FORMATTED"
    L_CONFIRM_REMOVE_AND_RECLONE_FORMATTED=$(printf "${S_CONFIRM_REMOVE_AND_RECLONE[$LANG_SELECTED]}" "$CLONE_DIR") 
    if confirm_action "$L_CONFIRM_REMOVE_AND_RECLONE_FORMATTED"; then
        L_REMOVING_DIR_FORMATTED=$(printf "${S_REMOVING_DIR[$LANG_SELECTED]}" "$CLONE_DIR"); print_info "$L_REMOVING_DIR_FORMATTED"; rm -rf "$CLONE_DIR"
        L_CLONING_REPO_TO_FORMATTED=$(printf "${S_CLONING_REPO_TO[$LANG_SELECTED]}" "$GITHUB_REPO" "$CLONE_DIR"); print_info "$L_CLONING_REPO_TO_FORMATTED"; git clone "$GITHUB_REPO" "$CLONE_DIR"; print_success "${S_REPO_CLONED_SUCCESS[$LANG_SELECTED]}"
    else L_CANNOT_PROCEED_WRONG_REPO_FORMATTED=$(printf "${S_CANNOT_PROCEED_WRONG_REPO[$LANG_SELECTED]}" "$CLONE_DIR"); print_error "$L_CANNOT_PROCEED_WRONG_REPO_FORMATTED"; exit 1; fi
fi

CURRENT_REMOTE_URL=$(git -C "$CLONE_DIR" config --get remote.origin.url 2>/dev/null || true)
if [ "$CURRENT_REMOTE_URL" != "$GITHUB_REPO" ]; then
    if [ "$UPDATE_MODE" = true ]; then
        L_REMOTE_URL_MISMATCH_UPDATE_EXIT_FORMATTED=$(printf "${S_REMOTE_URL_MISMATCH_UPDATE_EXIT[$LANG_SELECTED]}" "$CLONE_DIR" "$CURRENT_REMOTE_URL" "$GITHUB_REPO"); print_error "$L_REMOTE_URL_MISMATCH_UPDATE_EXIT_FORMATTED"; exit 1
    fi
    L_DIR_EXISTS_WRONG_REPO_URL_FORMATTED=$(printf "${S_DIR_EXISTS_WRONG_REPO_URL[$LANG_SELECTED]}" "$CLONE_DIR" "$CURRENT_REMOTE_URL" "$GITHUB_REPO"); print_warning "$L_DIR_EXISTS_WRONG_REPO_URL_FORMATTED"
    L_CONFIRM_REMOVE_AND_RECLONE_FORMATTED=$(printf "${S_CONFIRM_REMOVE_AND_RECLONE[$LANG_SELECTED]}" "$CLONE_DIR")
    if confirm_action "$L_CONFIRM_REMOVE_AND_RECLONE_FORMATTED"; then
        L_REMOVING_DIR_FORMATTED=$(printf "${S_REMOVING_DIR[$LANG_SELECTED]}" "$CLONE_DIR"); print_info "$L_REMOVING_DIR_FORMATTED"; rm -rf "$CLONE_DIR"
        L_CLONING_REPO_TO_FORMATTED=$(printf "${S_CLONING_REPO_TO[$LANG_SELECTED]}" "$GITHUB_REPO" "$CLONE_DIR"); print_info "$L_CLONING_REPO_TO_FORMATTED"; git clone "$GITHUB_REPO" "$CLONE_DIR"; print_success "${S_REPO_CLONED_SUCCESS[$LANG_SELECTED]}"
    else L_CANNOT_PROCEED_WRONG_REPO_FORMATTED=$(printf "${S_CANNOT_PROCEED_WRONG_REPO[$LANG_SELECTED]}" "$CLONE_DIR"); print_error "$L_CANNOT_PROCEED_WRONG_REPO_FORMATTED"; exit 1; fi
fi

if [ "$UPDATE_MODE" = true ]; then
    L_GIT_PULLING_UPDATE_FORMATTED=$(printf "${S_GIT_PULLING_UPDATE[$LANG_SELECTED]}" "$CLONE_DIR")
    print_info "$L_GIT_PULLING_UPDATE_FORMATTED"
    if ! git -C "$CLONE_DIR" pull origin master; then # Assuming master, change if needed
        print_error "${S_GIT_PULL_FAILED_UPDATE_EXIT[$LANG_SELECTED]}"
        exit 1 
    fi
    print_success "${S_REPO_PULLED_SUCCESS_UPDATE[$LANG_SELECTED]}"
elif [ "$INTERACTIVE_MODE" = true ]; then 
    L_REPO_DIR_EXISTS_FORMATTED=$(printf "${S_REPO_DIR_EXISTS[$LANG_SELECTED]}" "$CLONE_DIR") 
    print_info "$L_REPO_DIR_EXISTS_FORMATTED"
    print_info "${S_IS_CORRECT_REPO[$LANG_SELECTED]}"
    if confirm_action "${S_CONFIRM_GIT_PULL[$LANG_SELECTED]}"; then
        L_FETCHING_LATEST_FORMATTED=$(printf "${S_FETCHING_LATEST[$LANG_SELECTED]}" "$CLONE_DIR"); print_info "$L_FETCHING_LATEST_FORMATTED"
        if git -C "$CLONE_DIR" pull; then print_success "${S_REPO_UPDATED[$LANG_SELECTED]}"; else print_warning "${S_PULL_FAILED[$LANG_SELECTED]}"; fi
    else
        L_SKIPPING_UPDATE_USE_CURRENT_FORMATTED=$(printf "${S_SKIPPING_UPDATE_USE_CURRENT[$LANG_SELECTED]}" "$CLONE_DIR"); print_info "$L_SKIPPING_UPDATE_USE_CURRENT_FORMATTED"
    fi
fi
echo "---"

# --- 3. Compile Application ---
print_info "${S_STEP3_TITLE[$LANG_SELECTED]}"
CONSOLE_PROJECT_PATH="${CLONE_DIR}/${DEFAULT_CONSOLE_PROJECT_SUBDIR}"
PUBLISH_OUTPUT_DIR_NAME="publish_output_self_contained"
PUBLISHED_ARTIFACTS_PATH="${CONSOLE_PROJECT_PATH}/${PUBLISH_OUTPUT_DIR_NAME}"

if [ ! -d "$CONSOLE_PROJECT_PATH" ]; then L_CONSOLE_PROJECT_PATH_NOT_FOUND_FORMATTED=$(printf "${S_CONSOLE_PROJECT_PATH_NOT_FOUND[$LANG_SELECTED]}" "$CONSOLE_PROJECT_PATH"); print_error "$L_CONSOLE_PROJECT_PATH_NOT_FOUND_FORMATTED"; exit 1; fi

PROGRAM_CS_FILE="${CONSOLE_PROJECT_PATH}/Program.cs"
if [ -f "$PROGRAM_CS_FILE" ]; then
    if grep -q 'Task.Delay(Timeout.Infinite, cts.Token);.' "$PROGRAM_CS_FILE"; then 
        L_PROGRAM_CS_SYNTAX_ERROR_DETECTED_FORMATTED=$(printf "${S_PROGRAM_CS_SYNTAX_ERROR_DETECTED[$LANG_SELECTED]}" "$PROGRAM_CS_FILE"); print_warning "$L_PROGRAM_CS_SYNTAX_ERROR_DETECTED_FORMATTED"
        sed 's/Task.Delay(Timeout.Infinite, cts.Token);./Task.Delay(Timeout.Infinite, cts.Token);/g' "$PROGRAM_CS_FILE" > "${PROGRAM_CS_FILE}.tmp" && mv "${PROGRAM_CS_FILE}.tmp" "$PROGRAM_CS_FILE"
        L_PROGRAM_CS_SYNTAX_FIXED_FORMATTED=$(printf "${S_PROGRAM_CS_SYNTAX_FIXED[$LANG_SELECTED]}" "$PROGRAM_CS_FILE"); print_success "$L_PROGRAM_CS_SYNTAX_FIXED_FORMATTED"
    fi
else L_PROGRAM_CS_NOT_FOUND_SKIP_CHECK_FORMATTED=$(printf "${S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK[$LANG_SELECTED]}" "$PROGRAM_CS_FILE"); print_warning "$L_PROGRAM_CS_NOT_FOUND_SKIP_CHECK_FORMATTED"; fi

cd "$CONSOLE_PROJECT_PATH"
L_CURRENT_DIRECTORY_FORMATTED=$(printf "${S_CURRENT_DIRECTORY[$LANG_SELECTED]}" "$(pwd)"); print_info "$L_CURRENT_DIRECTORY_FORMATTED"

L_CONFIRM_CLEAN_BUILD_ARTIFACTS_FORMATTED=$(printf "${S_CONFIRM_CLEAN_BUILD_ARTIFACTS[$LANG_SELECTED]}" "$PUBLISH_OUTPUT_DIR_NAME")
if [ "$UPDATE_MODE" = true ] || confirm_action "$L_CONFIRM_CLEAN_BUILD_ARTIFACTS_FORMATTED"; then
    print_info "${S_CLEANING_BUILD_ARTIFACTS[$LANG_SELECTED]}"; rm -rf ./bin ./obj "./${PUBLISH_OUTPUT_DIR_NAME}"
fi

L_PUBLISHING_APP_FOR_RUNTIME_FORMATTED=$(printf "${S_PUBLISHING_APP_FOR_RUNTIME[$LANG_SELECTED]}" "$DEFAULT_PUBLISH_TARGET_RUNTIME"); print_info "$L_PUBLISHING_APP_FOR_RUNTIME_FORMATTED"
if dotnet publish -c Release -r "${DEFAULT_PUBLISH_TARGET_RUNTIME}" --self-contained true -o "./${PUBLISH_OUTPUT_DIR_NAME}" /p:PublishSingleFile=true; then
    L_APP_PUBLISHED_TO_FORMATTED=$(printf "${S_APP_PUBLISHED_TO[$LANG_SELECTED]}" "$PUBLISHED_ARTIFACTS_PATH"); print_success "$L_APP_PUBLISHED_TO_FORMATTED"
else print_error "${S_DOTNET_PUBLISH_FAILED[$LANG_SELECTED]}"; exit 1; fi
cd - > /dev/null
echo "---"

# --- 4. Systemd Service Setup (Includes Backup, Parameters.xml Handling, and Generation) ---
print_info "${S_STEP4_TITLE[$LANG_SELECTED]}" 

if [ "$INTERACTIVE_MODE" = true ]; then
    if ! confirm_action "${S_CONFIRM_PARAMS_AND_SERVICE_SETUP[$LANG_SELECTED]}"; then
        print_info "${S_SKIPPING_PARAMS_AND_SERVICE_SETUP[$LANG_SELECTED]}"
        L_SETUP_FINISHED_APP_AT_FORMATTED=$(printf "${S_SETUP_FINISHED_APP_AT[$LANG_SELECTED]}" "$PUBLISHED_ARTIFACTS_PATH"); print_info "$L_SETUP_FINISHED_APP_AT_FORMATTED"
        exit 0
    fi
    prompt_with_default "${S_PROMPT_SERVICE_USER[$LANG_SELECTED]}" "$DEFAULT_SERVICE_USER" SERVICE_USER
    prompt_with_default "${S_PROMPT_APP_NAME_FOR_SERVICE[$LANG_SELECTED]}" "$DEFAULT_APP_NAME" APP_NAME
else 
    SERVICE_USER="$DEFAULT_SERVICE_USER"; APP_NAME="$DEFAULT_APP_NAME"
    if [ "$SILENT_UPDATE_MODE" = false ]; then 
        L_PROMPT_DEFAULT_SERVICE_INFO_UPDATE_FORMATTED=$(printf "${S_PROMPT_DEFAULT_SERVICE_INFO_UPDATE[$LANG_SELECTED]}" "$SERVICE_USER" "$APP_NAME")
        print_info "$L_PROMPT_DEFAULT_SERVICE_INFO_UPDATE_FORMATTED"
    fi
fi

DEPLOY_DIR="${DEFAULT_DEPLOY_BASE_DIR}/${APP_NAME}"; EXECUTABLE_NAME="GbbConnect2Console"; PARAMETERS_FILE_PATH="${DEPLOY_DIR}/Parameters.xml"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S"); BACKUP_DIR_BASE="${DEPLOY_DIR}_backup" 

if [ "$INTERACTIVE_MODE" = true ]; then 
    if ! id -u "$SERVICE_USER" &>/dev/null; then
        L_CREATING_SYSTEM_USER_FORMATTED=$(printf "${S_CREATING_SYSTEM_USER[$LANG_SELECTED]}" "$SERVICE_USER"); print_info "$L_CREATING_SYSTEM_USER_FORMATTED"
        sudo useradd --system --no-create-home --shell /usr/sbin/nologin "$SERVICE_USER"
        L_USER_CREATED_SUCCESS_FORMATTED=$(printf "${S_USER_CREATED_SUCCESS[$LANG_SELECTED]}" "$SERVICE_USER"); print_success "$L_USER_CREATED_SUCCESS_FORMATTED"
    else L_USER_ALREADY_EXISTS_FORMATTED=$(printf "${S_USER_ALREADY_EXISTS[$LANG_SELECTED]}" "$SERVICE_USER"); print_info "$L_USER_ALREADY_EXISTS_FORMATTED"; fi
fi

L_DEPLOYING_FILES_TO_FORMATTED=$(printf "${S_DEPLOYING_FILES_TO[$LANG_SELECTED]}" "$DEPLOY_DIR"); print_info "$L_DEPLOYING_FILES_TO_FORMATTED"
if [ -d "$DEPLOY_DIR" ] && [ "$(ls -A $DEPLOY_DIR | grep -vE '^(Parameters.xml|backups?(_[0-9]+)?)$' )" ]; then 
    BACKUP_DIR="${BACKUP_DIR_BASE}_${TIMESTAMP}"
    L_BACKING_UP_OLD_VERSION_FORMATTED=$(printf "${S_BACKING_UP_OLD_VERSION[$LANG_SELECTED]}" "$DEPLOY_DIR" "$BACKUP_DIR"); print_info "$L_BACKING_UP_OLD_VERSION_FORMATTED"
    if sudo mkdir -p "$BACKUP_DIR" && sudo rsync -a --remove-source-files --exclude="Parameters.xml" --exclude="backups*" --exclude="*_backup_*" "$DEPLOY_DIR/" "$BACKUP_DIR/"; then
        sudo find "$DEPLOY_DIR" -mindepth 1 -maxdepth 1 ! -name 'Parameters.xml' ! -name 'backups*' ! -name '*_backup_*' -exec rm -rf {} +
        print_success "${S_BACKUP_SUCCESSFUL[$LANG_SELECTED]}"
    else print_warning "${S_BACKUP_FAILED[$LANG_SELECTED]}"; fi
elif [ -d "$DEPLOY_DIR" ]; then
     L_DEPLOY_DIR_EXISTS_EMPTY_SKIP_BACKUP_FORMATTED=$(printf "${S_DEPLOY_DIR_EXISTS_EMPTY_SKIP_BACKUP[$LANG_SELECTED]}" "$DEPLOY_DIR"); print_info "$L_DEPLOY_DIR_EXISTS_EMPTY_SKIP_BACKUP_FORMATTED"
fi
sudo mkdir -p "$DEPLOY_DIR" 

CONFIGURE_PARAMETERS=false 
if [ "$INTERACTIVE_MODE" = true ]; then
    CONFIGURE_PARAMETERS=true 
    if [ -f "$PARAMETERS_FILE_PATH" ]; then
        L_PARAMS_XML_EXISTS_FORMATTED=$(printf "${S_PARAMS_XML_EXISTS[$LANG_SELECTED]}" "$PARAMETERS_FILE_PATH"); print_info "$L_PARAMS_XML_EXISTS_FORMATTED"
        if ! confirm_action "${S_CONFIRM_RECONFIGURE_PARAMS[$LANG_SELECTED]}"; then
            print_info "${S_KEEPING_EXISTING_PARAMS[$LANG_SELECTED]}"; CONFIGURE_PARAMETERS=false
        fi
    fi
elif [ "$UPDATE_MODE" = true ]; then 
    if [ ! -f "$PARAMETERS_FILE_PATH" ]; then 
        L_PARAMS_XML_MISSING_UPDATE_CRITICAL_FORMATTED=$(printf "${S_PARAMS_XML_MISSING_UPDATE_CRITICAL[$LANG_SELECTED]}" "$PARAMETERS_FILE_PATH"); print_error "$L_PARAMS_XML_MISSING_UPDATE_CRITICAL_FORMATTED"; exit 1 
    fi
fi

if [ "$CONFIGURE_PARAMETERS" = true ]; then 
    print_info "${S_CONFIGURING_PARAMS_XML[$LANG_SELECTED]}"; echo "${S_PARAMS_PROMPT_INTRO[$LANG_SELECTED]}"; echo "${S_MQTT_SERVER_INFO_URL[$LANG_SELECTED]}"; echo "${S_PLANT_ID_TOKEN_INFO[$LANG_SELECTED]}"
    prompt_for_value "${S_PROMPT_GBB_PLANT_NAME[$LANG_SELECTED]}" INPUT_GBB_PLANT_NAME; prompt_for_value "${S_PROMPT_DEYE_IP[$LANG_SELECTED]}" INPUT_DEYE_DONGLE_IP
    prompt_for_value "${S_PROMPT_DEYE_SN[$LANG_SELECTED]}" INPUT_DEYE_DONGLE_SN; prompt_for_value "${S_PROMPT_PLANT_ID[$LANG_SELECTED]}" INPUT_PLANT_ID
    prompt_for_value "${S_PROMPT_PLANT_TOKEN[$LANG_SELECTED]}" INPUT_PLANT_TOKEN; prompt_for_value "${S_PROMPT_MQTT_ADDRESS[$LANG_SELECTED]}" INPUT_MQTT_ADDRESS
    prompt_with_default "${S_PROMPT_MQTT_PORT[$LANG_SELECTED]}" "$DEFAULT_MQTT_PORT" INPUT_MQTT_PORT
    PARAMETERS_XML_CONTENT=$(cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<Parameters Version="1" Server_AutoStart="1" IsVerboseLog="1" IsDriverLog="0" IsDriverLog2="0">
  <Plant Version="1" Number="1" Name="${INPUT_GBB_PLANT_NAME}" IsDisabled="0" AddressIP="${INPUT_DEYE_DONGLE_IP}" PortNo="8899" SerialNumber="${INPUT_DEYE_DONGLE_SN}" GbbVictronWeb_PlantId="${INPUT_PLANT_ID}" GbbVictronWeb_PlantToken="${INPUT_PLANT_TOKEN}" GbbVictronWeb_Mqtt_Address="${INPUT_MQTT_ADDRESS}" GbbVictronWeb_Mqtt_Port="${INPUT_MQTT_PORT}"/>
</Parameters>
EOF
)
    L_WRITING_PARAMS_XML_TO_FORMATTED=$(printf "${S_WRITING_PARAMS_XML_TO[$LANG_SELECTED]}" "$PARAMETERS_FILE_PATH"); print_info "$L_WRITING_PARAMS_XML_TO_FORMATTED"
    echo "$PARAMETERS_XML_CONTENT" | sudo tee "$PARAMETERS_FILE_PATH" > /dev/null; print_success "${S_PARAMS_XML_CONFIGURED_SUCCESS[$LANG_SELECTED]}"
else 
    if [ "$UPDATE_MODE" = true ]; then
        L_PRESERVING_PARAMS_XML_UPDATE_FORMATTED=$(printf "${S_PRESERVING_PARAMS_XML_UPDATE[$LANG_SELECTED]}" "$PARAMETERS_FILE_PATH"); print_info "$L_PRESERVING_PARAMS_XML_UPDATE_FORMATTED"
    # else: interactive mode already printed "Keeping existing..." if applicable from confirm_action block
    fi
fi

if [ "$UPDATE_MODE" = true ]; then
    SERVICE_EXISTS_CMD="sudo systemctl list-unit-files | grep -q \"${APP_NAME}.service\""
    SERVICE_ACTIVE_CMD="sudo systemctl is-active --quiet \"${APP_NAME}.service\""
    SERVICE_EXISTS_RESULT=$(eval "$SERVICE_EXISTS_CMD"; echo $?)
    SERVICE_ACTIVE_RESULT=$(eval "$SERVICE_ACTIVE_CMD"; echo $?)

    if [ "$SERVICE_EXISTS_RESULT" -eq 0 ] && [ "$SERVICE_ACTIVE_RESULT" -eq 0 ]; then
        L_STOPPING_SERVICE_BEFORE_UPDATE_FORMATTED=$(printf "${S_STOPPING_SERVICE_BEFORE_UPDATE[$LANG_SELECTED]}" "$APP_NAME"); print_info "$L_STOPPING_SERVICE_BEFORE_UPDATE_FORMATTED"
        if ! sudo systemctl stop "${APP_NAME}.service"; then print_warning "${S_SERVICE_STOP_FAILED_UPDATE_WARN[$LANG_SELECTED]}"; fi
    fi
fi

L_COPYING_BINARIES_FROM_TO_FORMATTED=$(printf "${S_COPYING_BINARIES_FROM_TO[$LANG_SELECTED]}" "$PUBLISHED_ARTIFACTS_PATH" "$DEPLOY_DIR"); print_info "$L_COPYING_BINARIES_FROM_TO_FORMATTED"
sudo rsync -av --exclude 'Parameters.xml' "${PUBLISHED_ARTIFACTS_PATH}/" "$DEPLOY_DIR/" 

L_SETTING_FINAL_OWNERSHIP_PERMS_FORMATTED=$(printf "${S_SETTING_FINAL_OWNERSHIP_PERMS[$LANG_SELECTED]}" "$DEPLOY_DIR"); print_info "$L_SETTING_FINAL_OWNERSHIP_PERMS_FORMATTED"
sudo chown -R "${SERVICE_USER}:${SERVICE_USER}" "$DEPLOY_DIR"; sudo chmod +x "${DEPLOY_DIR}/${EXECUTABLE_NAME}"
if [ -f "$PARAMETERS_FILE_PATH" ]; then sudo chmod 640 "$PARAMETERS_FILE_PATH"; fi
print_success "${S_APP_DEPLOYED_PERMS_SET_SUCCESS[$LANG_SELECTED]}"

SERVICE_FILE_PATH="/etc/systemd/system/${APP_NAME}.service"
L_CREATING_SERVICE_FILE_AT_FORMATTED=$(printf "${S_CREATING_SERVICE_FILE_AT[$LANG_SELECTED]}" "$SERVICE_FILE_PATH"); print_info "$L_CREATING_SERVICE_FILE_AT_FORMATTED"
SAFE_APP_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9_-]//g')
if [ "$APP_NAME" != "$SAFE_APP_NAME" ]; then L_SERVICE_NAME_SANITIZED_FORMATTED=$(printf "${S_SERVICE_NAME_SANITIZED[$LANG_SELECTED]}" "$APP_NAME" "$SAFE_APP_NAME"); print_warning "$L_SERVICE_NAME_SANITIZED_FORMATTED"; APP_NAME="$SAFE_APP_NAME"; SERVICE_FILE_PATH="/etc/systemd/system/${APP_NAME}.service"; fi
sudo bash -c "cat > '$SERVICE_FILE_PATH'" <<EOF
[Unit]
Description=GbbConnect2 Console Application ($APP_NAME)
After=network-online.target
[Service]
Type=simple
User=$SERVICE_USER
Group=$SERVICE_USER
WorkingDirectory=$DEPLOY_DIR
ExecStart=${DEPLOY_DIR}/${EXECUTABLE_NAME} --dont-wait-for-key
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=$APP_NAME
Environment="DOTNET_PRINT_TELEMETRY_MESSAGE=false"
[Install]
WantedBy=multi-user.target
EOF
print_success "${S_SERVICE_FILE_CREATED_SUCCESS[$LANG_SELECTED]}"

L_RELOADING_DAEMON_ENABLING_STARTING_SERVICE_FORMATTED=$(printf "${S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE[$LANG_SELECTED]}" "$APP_NAME"); print_info "$L_RELOADING_DAEMON_ENABLING_STARTING_SERVICE_FORMATTED"
sudo systemctl daemon-reload; sudo systemctl enable "${APP_NAME}.service"; sudo systemctl restart "${APP_NAME}.service"
L_SERVICE_ENABLED_STARTED_SUCCESS_FORMATTED=$(printf "${S_SERVICE_ENABLED_STARTED_SUCCESS[$LANG_SELECTED]}" "$APP_NAME"); print_success "$L_SERVICE_ENABLED_STARTED_SUCCESS_FORMATTED"
echo "---"

# --- 5. Verification ---
print_info "${S_STEP5_TITLE[$LANG_SELECTED]}"
L_SERVICE_SHOULD_BE_RUNNING_FORMATTED=$(printf "${S_SERVICE_SHOULD_BE_RUNNING[$LANG_SELECTED]}" "$APP_NAME"); echo "$L_SERVICE_SHOULD_BE_RUNNING_FORMATTED"

if [ "$INTERACTIVE_MODE" = true ]; then
    echo "${S_CHECK_STATUS_WITH[$LANG_SELECTED]}"; echo "  sudo systemctl status ${APP_NAME}.service"
    echo "${S_VIEW_LATEST_LOGS_WITH[$LANG_SELECTED]}"; echo "  sudo journalctl -u ${APP_NAME}.service -n 50 --no-pager"
    echo "${S_FOLLOW_LOGS_WITH[$LANG_SELECTED]}"; echo "  sudo journalctl -f -u ${APP_NAME}.service"; echo ""
    echo "${S_TO_MANAGE_SERVICE[$LANG_SELECTED]}"
    echo "  ${S_SERVICE_STOP[$LANG_SELECTED]}:    sudo systemctl stop ${APP_NAME}.service"; echo "  ${S_SERVICE_START[$LANG_SELECTED]}:   sudo systemctl start ${APP_NAME}.service"
    echo "  ${S_SERVICE_RESTART[$LANG_SELECTED]}: sudo systemctl restart ${APP_NAME}.service"; echo "  ${S_SERVICE_DISABLE_AUTOSTART[$LANG_SELECTED]}: sudo systemctl disable ${APP_NAME}.service"; echo ""
    # Auto Update Setup (Cron Job) is now removed from here
    echo "---" 
fi

if [ "$UPDATE_MODE" = true ]; then
    # For --update (non-silent), print status. For --update-silent, this is suppressed by print_info/success.
    L_UPDATE_SERVICE_ACTIVE_FORMATTED=$(printf "${S_UPDATE_SERVICE_ACTIVE[$LANG_SELECTED]}" "$APP_NAME")
    L_UPDATE_SERVICE_NOT_ACTIVE_FORMATTED=$(printf "${S_UPDATE_SERVICE_NOT_ACTIVE[$LANG_SELECTED]}" "$APP_NAME" "$APP_NAME")
    if [ "$SILENT_UPDATE_MODE" = false ]; then print_info "${S_ESSENTIAL_TOOLS_VERIFY_UPDATE[$LANG_SELECTED]}"; fi
    if sudo systemctl is-active --quiet "${APP_NAME}.service"; then
        if [ "$SILENT_UPDATE_MODE" = false ]; then print_success "$L_UPDATE_SERVICE_ACTIVE_FORMATTED"; fi
    else
        if [ "$SILENT_UPDATE_MODE" = false ]; then print_error "$L_UPDATE_SERVICE_NOT_ACTIVE_FORMATTED"; fi
    fi
fi

if [ "$SILENT_UPDATE_MODE" = true ]; then
    # For silent mode, the success message should primarily go to a log if standard output is suppressed.
    # Since print_success is now silent in SILENT_UPDATE_MODE, this won't print to stdout.
    # If you need a record, ensure the calling script (cron checker) logs completion.
    print_success "${S_UPDATE_SILENT_FINISHED[$LANG_SELECTED]}" 
elif [ "$UPDATE_MODE" = true ]; then
    print_success "${S_UPDATE_USER_TRIGGERED_FINISHED[$LANG_SELECTED]}"
else # Interactive mode
    print_success "${S_SCRIPT_FINISHED_SUCCESS[$LANG_SELECTED]}"
fi

exit 0
