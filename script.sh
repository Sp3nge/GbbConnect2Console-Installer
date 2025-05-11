#!/bin/bash

# Script to compile GbbConnect2.Console, configure Parameters.xml,
# and set it up as a systemd service.
# Verbose output and user input for configuration.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Language Selection ---
LANG_SELECTED="en" # Default to English

echo "Please select your language / Proszę wybrać język:"
echo "1. English"
echo "2. Polski"

while true; do
    read -r -p "Enter your choice (1 or 2) / Wprowadź wybór (1 lub 2): " lang_choice
    case "$lang_choice" in
        1)
            LANG_SELECTED="en"
            echo "Language set to English."
            break
            ;;
        2)
            LANG_SELECTED="pl"
            echo "Język ustawiony na Polski."
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2. / Nieprawidłowy wybór. Proszę wpisać 1 lub 2."
            ;;
    esac
done
echo "---"


# --- Localized Strings ---
# --- Titles & General ---
declare -A S_BANNER_MADE_BY
S_BANNER_MADE_BY[en]="                                Made by @Sp3nge                               "
S_BANNER_MADE_BY[pl]="                             Stworzone przez @Sp3nge                            "

declare -A S_WELCOME_TITLE
S_WELCOME_TITLE[en]="GbbConnect2.Console Setup Script"
S_WELCOME_TITLE[pl]="Skrypt Instalacyjny GbbConnect2.Console"

declare -A S_SCRIPT_GUIDE
S_SCRIPT_GUIDE[en]="This script will guide you through:"
S_SCRIPT_GUIDE[pl]="Ten skrypt przeprowadzi Cię przez:"

declare -A S_GUIDE_ITEM1
S_GUIDE_ITEM1[en]="1. Installing prerequisites (Git, lsb-release, rsync, .NET SDK)."
S_GUIDE_ITEM1[pl]="1. Instalację wymagań wstępnych (Git, lsb-release, rsync, .NET SDK)."
declare -A S_GUIDE_ITEM2
S_GUIDE_ITEM2[en]="2. Cloning/Verifying the GbbConnect2 repository."
S_GUIDE_ITEM2[pl]="2. Klonowanie/Weryfikację repozytorium GbbConnect2."
declare -A S_GUIDE_ITEM3
S_GUIDE_ITEM3[en]="3. Compiling GbbConnect2.Console."
S_GUIDE_ITEM3[pl]="3. Kompilację GbbConnect2.Console."
declare -A S_GUIDE_ITEM4
S_GUIDE_ITEM4[en]="4. Configuring Parameters.xml with your details."
S_GUIDE_ITEM4[pl]="4. Konfigurację Parameters.xml z Twoimi danymi."
declare -A S_GUIDE_ITEM5
S_GUIDE_ITEM5[en]="5. Setting up a systemd service for auto-start and persistence."
S_GUIDE_ITEM5[pl]="5. Konfigurację usługi systemd do automatycznego startu i trwałości."

# --- Helper Function Messages ---
declare -A S_INFO_PREFIX
S_INFO_PREFIX[en]="[INFO]"
S_INFO_PREFIX[pl]="[INFO]"

declare -A S_SUCCESS_PREFIX
S_SUCCESS_PREFIX[en]="[SUCCESS]"
S_SUCCESS_PREFIX[pl]="[SUKCES]"

declare -A S_WARNING_PREFIX
S_WARNING_PREFIX[en]="[WARNING]"
S_WARNING_PREFIX[pl]="[OSTRZEŻENIE]"

declare -A S_ERROR_PREFIX
S_ERROR_PREFIX[en]="[ERROR]"
S_ERROR_PREFIX[pl]="[BŁĄD]"

declare -A S_CONFIRM_PROMPT_SUFFIX
S_CONFIRM_PROMPT_SUFFIX[en]="[y/N]: "
S_CONFIRM_PROMPT_SUFFIX[pl]="[t/N]: "

declare -A S_INVALID_INPUT_CONFIRM
S_INVALID_INPUT_CONFIRM[en]="Invalid input. Please answer 'y' or 'n'."
S_INVALID_INPUT_CONFIRM[pl]="Nieprawidłowe dane. Proszę odpowiedzieć 't' lub 'n'."

declare -A S_FIELD_CANNOT_BE_EMPTY
S_FIELD_CANNOT_BE_EMPTY[en]="This field cannot be empty."
S_FIELD_CANNOT_BE_EMPTY[pl]="To pole nie może być puste."

# --- Step 1: Prerequisites ---
declare -A S_STEP1_TITLE
S_STEP1_TITLE[en]="Step 1: Checking and Installing Prerequisites"
S_STEP1_TITLE[pl]="Krok 1: Sprawdzanie i Instalowanie Wymagań Wstępnych"

declare -A S_CONFIRM_PREREQUISITES
S_CONFIRM_PREREQUISITES[en]="Do you want to check/install Git, lsb-release, rsync, and .NET SDK" # Version will be appended
S_CONFIRM_PREREQUISITES[pl]="Czy chcesz sprawdzić/zainstalować Git, lsb-release, rsync oraz .NET SDK"

declare -A S_UPDATING_PACKAGES
S_UPDATING_PACKAGES[en]="Updating package lists..."
S_UPDATING_PACKAGES[pl]="Aktualizowanie list pakietów..."

declare -A S_GIT_NOT_FOUND
S_GIT_NOT_FOUND[en]="Git not found. Installing Git..."
S_GIT_NOT_FOUND[pl]="Nie znaleziono Git. Instalowanie Git..."
declare -A S_GIT_INSTALLED_SUCCESS
S_GIT_INSTALLED_SUCCESS[en]="Git installed."
S_GIT_INSTALLED_SUCCESS[pl]="Git zainstalowany."
declare -A S_GIT_ALREADY_INSTALLED
S_GIT_ALREADY_INSTALLED[en]="Git is already installed."
S_GIT_ALREADY_INSTALLED[pl]="Git jest już zainstalowany."

declare -A S_LSB_RELEASE_NOT_FOUND
S_LSB_RELEASE_NOT_FOUND[en]="'lsb-release' command not found. Installing lsb-release package..."
S_LSB_RELEASE_NOT_FOUND[pl]="Nie znaleziono polecenia 'lsb-release'. Instalowanie pakietu lsb-release..."
declare -A S_LSB_RELEASE_INSTALLED_SUCCESS
S_LSB_RELEASE_INSTALLED_SUCCESS[en]="'lsb-release' package installed."
S_LSB_RELEASE_INSTALLED_SUCCESS[pl]="Pakiet 'lsb-release' zainstalowany."
declare -A S_LSB_RELEASE_ALREADY_INSTALLED
S_LSB_RELEASE_ALREADY_INSTALLED[en]="'lsb-release' is already installed."
S_LSB_RELEASE_ALREADY_INSTALLED[pl]="'lsb-release' jest już zainstalowany."

declare -A S_RSYNC_NOT_FOUND
S_RSYNC_NOT_FOUND[en]="'rsync' command not found. Installing rsync package..."
S_RSYNC_NOT_FOUND[pl]="Nie znaleziono polecenia 'rsync'. Instalowanie pakietu rsync..."
declare -A S_RSYNC_INSTALLED_SUCCESS
S_RSYNC_INSTALLED_SUCCESS[en]="'rsync' package installed."
S_RSYNC_INSTALLED_SUCCESS[pl]="Pakiet 'rsync' zainstalowany."
declare -A S_RSYNC_ALREADY_INSTALLED
S_RSYNC_ALREADY_INSTALLED[en]="'rsync' is already installed."
S_RSYNC_ALREADY_INSTALLED[pl]="'rsync' jest już zainstalowany."

declare -A S_DOTNET_ALREADY_INSTALLED_MSG
S_DOTNET_ALREADY_INSTALLED_MSG[en]=".NET SDK version %s.x seems to be already installed." # %s will be SDK_MAJOR_VERSION
S_DOTNET_ALREADY_INSTALLED_MSG[pl]="Wygląda na to, że .NET SDK w wersji %s.x jest już zainstalowany."
declare -A S_DOTNET_CONFIRM_REINSTALL_MSG
S_DOTNET_CONFIRM_REINSTALL_MSG[en]="Do you want to proceed with .NET SDK installation/update anyway?"
S_DOTNET_CONFIRM_REINSTALL_MSG[pl]="Czy chcesz kontynuować instalację/aktualizację .NET SDK mimo to?"
declare -A S_DOTNET_NOT_FOUND_MSG
S_DOTNET_NOT_FOUND_MSG[en]=".NET SDK %s not found or a different major version is primary." # %s will be DEFAULT_DOTNET_SDK_VERSION
S_DOTNET_NOT_FOUND_MSG[pl]="Nie znaleziono .NET SDK %s lub główna wersja jest inna."
declare -A S_DOTNET_INSTALLING_MSG
S_DOTNET_INSTALLING_MSG[en]="Installing .NET SDK %s (for Debian/Ubuntu)..." # %s will be DEFAULT_DOTNET_SDK_VERSION
S_DOTNET_INSTALLING_MSG[pl]="Instalowanie .NET SDK %s (dla Debian/Ubuntu)..."
declare -A S_LSB_RELEASE_UNAVAILABLE_MANUAL_PROMPT
S_LSB_RELEASE_UNAVAILABLE_MANUAL_PROMPT[en]="'lsb-release' is not available. You may need to input your OS version manually."
S_LSB_RELEASE_UNAVAILABLE_MANUAL_PROMPT[pl]="Polecenie 'lsb-release' nie jest dostępne. Może być konieczne ręczne wprowadzenie wersji systemu operacyjnego."
declare -A S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT
S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT[en]="Could not automatically detect OS version. Do you want to try to proceed by manually entering your Debian/Ubuntu version (e.g., 11, 12 for Debian; 20.04, 22.04 for Ubuntu)?"
S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT[pl]="Nie można automatycznie wykryć wersji systemu. Czy chcesz spróbować kontynuować, wprowadzając ręcznie wersję Debian/Ubuntu (np. 11, 12 dla Debiana; 20.04, 22.04 dla Ubuntu)?"
declare -A S_OS_VERSION_PROMPT
S_OS_VERSION_PROMPT[en]="Enter your OS version"
S_OS_VERSION_PROMPT[pl]="Wprowadź wersję swojego systemu operacyjnego"
declare -A S_NO_OS_VERSION_ENTERED_ABORT
S_NO_OS_VERSION_ENTERED_ABORT[en]="No OS version entered. Aborting .NET SDK installation."
S_NO_OS_VERSION_ENTERED_ABORT[pl]="Nie wprowadzono wersji systemu. Przerywanie instalacji .NET SDK."
declare -A S_ABORT_NO_OS_VERSION
S_ABORT_NO_OS_VERSION[en]="Aborting .NET SDK installation as OS version is unknown."
S_ABORT_NO_OS_VERSION[pl]="Przerywanie instalacji .NET SDK, ponieważ wersja systemu jest nieznana."
declare -A S_USING_OS_VERSION_FOR_SETUP
S_USING_OS_VERSION_FOR_SETUP[en]="Using OS version: %s for .NET SDK repository setup." # %s is OS_VERSION_TO_USE
S_USING_OS_VERSION_FOR_SETUP[pl]="Używanie wersji systemu: %s do konfiguracji repozytorium .NET SDK."
declare -A S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN
S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN[en]="Could not reliably determine if OS is Debian or Ubuntu. Assuming Debian structure for .NET repo URL."
S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN[pl]="Nie można wiarygodnie określić, czy system to Debian czy Ubuntu. Przyjmowanie struktury Debiana dla adresu URL repozytorium .NET."
declare -A S_ATTEMPTING_DOWNLOAD_FROM
S_ATTEMPTING_DOWNLOAD_FROM[en]="Attempting to download from: %s" # %s is PACKAGE_URL
S_ATTEMPTING_DOWNLOAD_FROM[pl]="Próba pobrania z: %s"
declare -A S_DOTNET_INSTALL_COMPLETE
S_DOTNET_INSTALL_COMPLETE[en]=".NET SDK %s installation process completed." # %s is DEFAULT_DOTNET_SDK_VERSION
S_DOTNET_INSTALL_COMPLETE[pl]="Proces instalacji .NET SDK %s zakończony."
declare -A S_DOTNET_VERIFYING_INSTALL
S_DOTNET_VERIFYING_INSTALL[en]="Verifying .NET SDK installation..."
S_DOTNET_VERIFYING_INSTALL[pl]="Weryfikowanie instalacji .NET SDK..."
declare -A S_DOWNLOAD_PKG_FAIL
S_DOWNLOAD_PKG_FAIL[en]="Failed to download packages-microsoft-prod.deb. Please check the URL and your network connection."
S_DOWNLOAD_PKG_FAIL[pl]="Nie udało się pobrać packages-microsoft-prod.deb. Sprawdź adres URL i połączenie sieciowe."
declare -A S_DOTNET_SKIPPING_INSTALL
S_DOTNET_SKIPPING_INSTALL[en]="Skipping .NET SDK installation."
S_DOTNET_SKIPPING_INSTALL[pl]="Pominięcie instalacji .NET SDK."
declare -A S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET
S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET[en]="Could not determine OS version. Skipping .NET SDK installation."
S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET[pl]="Nie można określić wersji systemu. Pominięcie instalacji .NET SDK."
declare -A S_DOTNET_MANUAL_INSTALL_NOTE
S_DOTNET_MANUAL_INSTALL_NOTE[en]="You might need to install it manually for your distribution."
S_DOTNET_MANUAL_INSTALL_NOTE[pl]="Może być konieczna ręczna instalacja dla Twojej dystrybucji."
declare -A S_DOTNET_SKIPPING_UPDATE
S_DOTNET_SKIPPING_UPDATE[en]="Skipping .NET SDK installation/update."
S_DOTNET_SKIPPING_UPDATE[pl]="Pominięcie instalacji/aktualizacji .NET SDK."
declare -A S_PREREQ_SKIPPING_ALL
S_PREREQ_SKIPPING_ALL[en]="Skipping prerequisite installation. Please ensure Git, lsb-release, rsync, and .NET SDK %s are installed." # %s is DEFAULT_DOTNET_SDK_VERSION
S_PREREQ_SKIPPING_ALL[pl]="Pominięcie instalacji wymagań wstępnych. Upewnij się, że Git, lsb-release, rsync oraz .NET SDK %s są zainstalowane."

# --- Step 2: Clone ---
declare -A S_STEP2_TITLE
S_STEP2_TITLE[en]="Step 2: Cloning/Verifying GbbConnect2 Repository"
S_STEP2_TITLE[pl]="Krok 2: Klonowanie/Weryfikacja Repozytorium GbbConnect2"
declare -A S_PROMPT_CLONE_DIR
S_PROMPT_CLONE_DIR[en]="Enter directory where the repository should be (or already is)"
S_PROMPT_CLONE_DIR[pl]="Wprowadź katalog, w którym repozytorium powinno się znajdować (lub już jest)"
declare -A S_REPO_DIR_EXISTS
S_REPO_DIR_EXISTS[en]="Repository directory '%s' already exists." # %s is CLONE_DIR
S_REPO_DIR_EXISTS[pl]="Katalog repozytorium '%s' już istnieje."
declare -A S_IS_CORRECT_REPO
S_IS_CORRECT_REPO[en]="It appears to be the correct GbbConnect2 repository."
S_IS_CORRECT_REPO[pl]="Wygląda na to, że jest to poprawne repozytorium GbbConnect2."
declare -A S_CONFIRM_GIT_PULL
S_CONFIRM_GIT_PULL[en]="Do you want to fetch the latest changes (git pull)?"
S_CONFIRM_GIT_PULL[pl]="Czy chcesz pobrać najnowsze zmiany (git pull)?"
declare -A S_FETCHING_LATEST
S_FETCHING_LATEST[en]="Fetching latest changes for '%s'..." # %s is CLONE_DIR
S_FETCHING_LATEST[pl]="Pobieranie najnowszych zmian dla '%s'..."
declare -A S_REPO_UPDATED
S_REPO_UPDATED[en]="Repository updated."
S_REPO_UPDATED[pl]="Repozytorium zaktualizowane."
declare -A S_PULL_FAILED
S_PULL_FAILED[en]="Failed to pull latest changes. Continuing with the current version."
S_PULL_FAILED[pl]="Nie udało się pobrać najnowszych zmian. Kontynuowanie z bieżącą wersją."
declare -A S_SKIPPING_UPDATE_USE_CURRENT
S_SKIPPING_UPDATE_USE_CURRENT[en]="Skipping update. Using current version in '%s'." # %s is CLONE_DIR
S_SKIPPING_UPDATE_USE_CURRENT[pl]="Pominięcie aktualizacji. Używanie bieżącej wersji w '%s'."
declare -A S_DIR_EXISTS_WRONG_REPO_URL
S_DIR_EXISTS_WRONG_REPO_URL[en]="The directory '%s' exists but its remote origin URL ('%s') does not match the expected '%s'." # $CLONE_DIR, $CURRENT_REMOTE_URL, $GITHUB_REPO
S_DIR_EXISTS_WRONG_REPO_URL[pl]="Katalog '%s' istnieje, ale jego zdalny adres URL ('%s') nie pasuje do oczekiwanego '%s'."
declare -A S_DIR_EXISTS_NOT_GIT
S_DIR_EXISTS_NOT_GIT[en]="The directory '%s' exists but does not appear to be a Git repository." # %s is CLONE_DIR
S_DIR_EXISTS_NOT_GIT[pl]="Katalog '%s' istnieje, ale nie wydaje się być repozytorium Git."
declare -A S_CONFIRM_REMOVE_AND_RECLONE
S_CONFIRM_REMOVE_AND_RECLONE[en]="Do you want to remove the existing directory '%s' and clone the correct repository anew?" # %s is CLONE_DIR
S_CONFIRM_REMOVE_AND_RECLONE[pl]="Czy chcesz usunąć istniejący katalog '%s' i sklonować poprawne repozytorium od nowa?"
declare -A S_REMOVING_DIR
S_REMOVING_DIR[en]="Removing existing directory '%s'..." # %s is CLONE_DIR
S_REMOVING_DIR[pl]="Usuwanie istniejącego katalogu '%s'..."
declare -A S_CLONING_REPO_TO
S_CLONING_REPO_TO[en]="Cloning %s into %s..." # %s is GITHUB_REPO, %s is CLONE_DIR
S_CLONING_REPO_TO[pl]="Klonowanie %s do %s..."
declare -A S_REPO_CLONED_SUCCESS
S_REPO_CLONED_SUCCESS[en]="Repository cloned."
S_REPO_CLONED_SUCCESS[pl]="Repozytorium sklonowane."
declare -A S_CANNOT_PROCEED_WRONG_REPO
S_CANNOT_PROCEED_WRONG_REPO[en]="Cannot proceed without the correct repository at '%s'. Exiting." # %s is CLONE_DIR
S_CANNOT_PROCEED_WRONG_REPO[pl]="Nie można kontynuować bez poprawnego repozytorium w '%s'. Zamykanie."
declare -A S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE
S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE[en]="Repository directory '%s' does not exist. Do you want to clone %s into it?" # %s is CLONE_DIR, %s is GITHUB_REPO
S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE[pl]="Katalog repozytorium '%s' nie istnieje. Czy chcesz sklonować %s do niego?"
declare -A S_REPO_NOT_FOUND_DECLINED_CLONE
S_REPO_NOT_FOUND_DECLINED_CLONE[en]="Repository not found at '%s' and cloning was declined. Exiting." # %s is CLONE_DIR
S_REPO_NOT_FOUND_DECLINED_CLONE[pl]="Nie znaleziono repozytorium w '%s', a klonowanie zostało odrzucone. Zamykanie."

# --- Step 3: Compile ---
declare -A S_STEP3_TITLE
S_STEP3_TITLE[en]="Step 3: Compiling GbbConnect2.Console"
S_STEP3_TITLE[pl]="Krok 3: Kompilacja GbbConnect2.Console"
declare -A S_CONSOLE_PROJECT_PATH_NOT_FOUND
S_CONSOLE_PROJECT_PATH_NOT_FOUND[en]="Console project path '%s' not found." # %s is CONSOLE_PROJECT_PATH
S_CONSOLE_PROJECT_PATH_NOT_FOUND[pl]="Nie znaleziono ścieżki projektu konsoli '%s'."
declare -A S_PROGRAM_CS_SYNTAX_ERROR_DETECTED
S_PROGRAM_CS_SYNTAX_ERROR_DETECTED[en]="Detected potential syntax error (extra dot) in '%s'. Attempting to fix..." # %s is PROGRAM_CS_FILE
S_PROGRAM_CS_SYNTAX_ERROR_DETECTED[pl]="Wykryto potencjalny błąd składni (dodatkowa kropka) w '%s'. Próba naprawy..."
declare -A S_PROGRAM_CS_SYNTAX_FIXED
S_PROGRAM_CS_SYNTAX_FIXED[en]="Potential syntax error fixed in '%s'." # %s is PROGRAM_CS_FILE
S_PROGRAM_CS_SYNTAX_FIXED[pl]="Potencjalny błąd składni naprawiony w '%s'."
declare -A S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK
S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK[en]="Program.cs file not found at '%s'. Skipping syntax check." # %s is PROGRAM_CS_FILE
S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK[pl]="Nie znaleziono pliku Program.cs w '%s'. Pomijanie sprawdzania składni."
declare -A S_CURRENT_DIRECTORY
S_CURRENT_DIRECTORY[en]="Current directory: %s" # %s is $(pwd)
S_CURRENT_DIRECTORY[pl]="Bieżący katalog: %s"
declare -A S_CONFIRM_CLEAN_BUILD_ARTIFACTS
S_CONFIRM_CLEAN_BUILD_ARTIFACTS[en]="Clean previous build artifacts (bin, obj, %s)?" # %s is PUBLISH_OUTPUT_DIR_NAME
S_CONFIRM_CLEAN_BUILD_ARTIFACTS[pl]="Wyczyścić poprzednie artefakty kompilacji (bin, obj, %s)?"
declare -A S_CLEANING_BUILD_ARTIFACTS
S_CLEANING_BUILD_ARTIFACTS[en]="Cleaning previous build artifacts..."
S_CLEANING_BUILD_ARTIFACTS[pl]="Czyszczenie poprzednich artefaktów kompilacji..."
declare -A S_PUBLISHING_APP_FOR_RUNTIME
S_PUBLISHING_APP_FOR_RUNTIME[en]="Publishing GbbConnect2.Console for %s..." # %s is DEFAULT_PUBLISH_TARGET_RUNTIME
S_PUBLISHING_APP_FOR_RUNTIME[pl]="Publikowanie GbbConnect2.Console dla %s..."
declare -A S_APP_PUBLISHED_TO
S_APP_PUBLISHED_TO[en]="Application published to '%s'." # %s is PUBLISHED_ARTIFACTS_PATH
S_APP_PUBLISHED_TO[pl]="Aplikacja opublikowana do '%s'."
declare -A S_DOTNET_PUBLISH_FAILED
S_DOTNET_PUBLISH_FAILED[en]="dotnet publish command failed. Please check the output above for errors."
S_DOTNET_PUBLISH_FAILED[pl]="Polecenie dotnet publish nie powiodło się. Sprawdź powyższy wynik w poszukiwaniu błędów."

# --- Step 4: Service Setup & Parameters.xml ---
declare -A S_STEP4_TITLE
S_STEP4_TITLE[en]="Step 4: Configuring Parameters.xml and Setting up systemd Service"
S_STEP4_TITLE[pl]="Krok 4: Konfiguracja Parameters.xml i Ustawianie Usługi systemd"
declare -A S_CONFIRM_PARAMS_AND_SERVICE_SETUP
S_CONFIRM_PARAMS_AND_SERVICE_SETUP[en]="Do you want to proceed with configuring Parameters.xml and setting up the systemd service?"
S_CONFIRM_PARAMS_AND_SERVICE_SETUP[pl]="Czy chcesz kontynuować konfigurację Parameters.xml i ustawianie usługi systemd?"
declare -A S_SKIPPING_PARAMS_AND_SERVICE_SETUP
S_SKIPPING_PARAMS_AND_SERVICE_SETUP[en]="Skipping Parameters.xml and systemd service setup."
S_SKIPPING_PARAMS_AND_SERVICE_SETUP[pl]="Pominięcie konfiguracji Parameters.xml i usługi systemd."
declare -A S_SETUP_FINISHED_APP_AT
S_SETUP_FINISHED_APP_AT[en]="Setup script finished. You can find the compiled application at '%s'." # %s is PUBLISHED_ARTIFACTS_PATH
S_SETUP_FINISHED_APP_AT[pl]="Skrypt instalacyjny zakończony. Skompilowaną aplikację można znaleźć w '%s'."
declare -A S_PROMPT_SERVICE_USER
S_PROMPT_SERVICE_USER[en]="Enter desired service user name"
S_PROMPT_SERVICE_USER[pl]="Wprowadź żądaną nazwę użytkownika usługi"
declare -A S_PROMPT_APP_NAME_FOR_SERVICE
S_PROMPT_APP_NAME_FOR_SERVICE[en]="Enter application name for service and directory"
S_PROMPT_APP_NAME_FOR_SERVICE[pl]="Wprowadź nazwę aplikacji dla usługi i katalogu"
declare -A S_USER_ALREADY_EXISTS
S_USER_ALREADY_EXISTS[en]="User '%s' already exists." # %s is SERVICE_USER
S_USER_ALREADY_EXISTS[pl]="Użytkownik '%s' już istnieje."
declare -A S_CREATING_SYSTEM_USER
S_CREATING_SYSTEM_USER[en]="Creating system user '%s'..." # %s is SERVICE_USER
S_CREATING_SYSTEM_USER[pl]="Tworzenie użytkownika systemowego '%s'..."
declare -A S_USER_CREATED_SUCCESS
S_USER_CREATED_SUCCESS[en]="User '%s' created." # %s is SERVICE_USER
S_USER_CREATED_SUCCESS[pl]="Użytkownik '%s' utworzony."
declare -A S_DEPLOYING_FILES_TO
S_DEPLOYING_FILES_TO[en]="Deploying application files to '%s'..." # %s is DEPLOY_DIR
S_DEPLOYING_FILES_TO[pl]="Wdrażanie plików aplikacji do '%s'..."
declare -A S_DEPLOY_DIR_EXISTS
S_DEPLOY_DIR_EXISTS[en]="Deployment directory '%s' already exists." # %s is DEPLOY_DIR
S_DEPLOY_DIR_EXISTS[pl]="Katalog wdrożenia '%s' już istnieje."
declare -A S_CONFIRM_REMOVE_CONTENTS_REDEPLOY
S_CONFIRM_REMOVE_CONTENTS_REDEPLOY[en]="Do you want to remove its contents (excluding Parameters.xml if present) and redeploy application binaries?"
S_CONFIRM_REMOVE_CONTENTS_REDEPLOY[pl]="Czy chcesz usunąć jego zawartość (z wyjątkiem Parameters.xml, jeśli istnieje) i ponownie wdrożyć pliki binarne aplikacji?"
declare -A S_SKIPPING_REMOVAL_OVERWRITE_NOTE
S_SKIPPING_REMOVAL_OVERWRITE_NOTE[en]="Skipping removal. New files might overwrite existing ones."
S_SKIPPING_REMOVAL_OVERWRITE_NOTE[pl]="Pominięcie usuwania. Nowe pliki mogą nadpisać istniejące."
declare -A S_COPYING_BINARIES_FROM_TO
S_COPYING_BINARIES_FROM_TO[en]="Copying application binaries from '%s' to '%s'..." # %s PUBLISHED_ARTIFACTS_PATH, %s DEPLOY_DIR
S_COPYING_BINARIES_FROM_TO[pl]="Kopiowanie plików binarnych aplikacji z '%s' do '%s'..."
declare -A S_CONFIGURING_PARAMS_XML
S_CONFIGURING_PARAMS_XML[en]="Configuring Parameters.xml"
S_CONFIGURING_PARAMS_XML[pl]="Konfiguracja Parameters.xml"
declare -A S_PARAMS_PROMPT_INTRO
S_PARAMS_PROMPT_INTRO[en]="You will now be prompted for values to create/update Parameters.xml."
S_PARAMS_PROMPT_INTRO[pl]="Zostaniesz teraz poproszony o wartości do utworzenia/aktualizacji Parameters.xml."
declare -A S_MQTT_SERVER_INFO_URL
S_MQTT_SERVER_INFO_URL[en]="MQTT Server Address can be found at: https://gbboptimizer2.gbbsoft.pl/Manual?Filters.PageNo=14"
S_MQTT_SERVER_INFO_URL[pl]="Adres serwera MQTT można znaleźć pod adresem: https://gbboptimizer2.gbbsoft.pl/Manual?Filters.PageNo=14"
declare -A S_PLANT_ID_TOKEN_INFO
S_PLANT_ID_TOKEN_INFO[en]="Plant ID and Plant Token: Found in Gbb Website menu Plants, button Edit, at the end of the page."
S_PLANT_ID_TOKEN_INFO[pl]="ID Instalacji i Token Instalacji: Znajdują się w menu Instalacje na stronie Gbb, przycisk Edytuj, na końcu strony."
declare -A S_PROMPT_GBB_PLANT_NAME
S_PROMPT_GBB_PLANT_NAME[en]="Enter Gbb Plant Name (e.g., My Home Plant)"
S_PROMPT_GBB_PLANT_NAME[pl]="Wprowadź nazwę instalacji Gbb (np. Moja Domowa Instalacja)"
declare -A S_PROMPT_DEYE_IP
S_PROMPT_DEYE_IP[en]="Enter Deye Dongle IP Address (e.g., 192.168.1.50)"
S_PROMPT_DEYE_IP[pl]="Wprowadź adres IP klucza Deye (np. 192.168.1.50)"
declare -A S_PROMPT_DEYE_SN
S_PROMPT_DEYE_SN[en]="Enter Deye Dongle Serial Number (e.g., 1234567890)"
S_PROMPT_DEYE_SN[pl]="Wprowadź numer seryjny klucza Deye (np. 1234567890)"
declare -A S_PROMPT_PLANT_ID
S_PROMPT_PLANT_ID[en]="Enter GbbVictronWeb Plant ID"
S_PROMPT_PLANT_ID[pl]="Wprowadź ID Instalacji GbbVictronWeb"
declare -A S_PROMPT_PLANT_TOKEN
S_PROMPT_PLANT_TOKEN[en]="Enter GbbVictronWeb Plant Token"
S_PROMPT_PLANT_TOKEN[pl]="Wprowadź Token Instalacji GbbVictronWeb"
declare -A S_PROMPT_MQTT_ADDRESS
S_PROMPT_MQTT_ADDRESS[en]="Enter MQTT Server Address (e.g., gbboptimizerX-mqtt.gbbsoft.pl)"
S_PROMPT_MQTT_ADDRESS[pl]="Wprowadź adres serwera MQTT (np. gbboptimizerX-mqtt.gbbsoft.pl)"
declare -A S_PROMPT_MQTT_PORT
S_PROMPT_MQTT_PORT[en]="Enter MQTT Server Port"
S_PROMPT_MQTT_PORT[pl]="Wprowadź port serwera MQTT"
declare -A S_WRITING_PARAMS_XML_TO
S_WRITING_PARAMS_XML_TO[en]="Writing configured Parameters.xml to '%s'..." # %s PARAMETERS_FILE_PATH
S_WRITING_PARAMS_XML_TO[pl]="Zapisywanie skonfigurowanego Parameters.xml do '%s'..."
declare -A S_PARAMS_XML_CONFIGURED_SUCCESS
S_PARAMS_XML_CONFIGURED_SUCCESS[en]="Parameters.xml configured."
S_PARAMS_XML_CONFIGURED_SUCCESS[pl]="Parameters.xml skonfigurowany."
declare -A S_SETTING_FINAL_OWNERSHIP_PERMS
S_SETTING_FINAL_OWNERSHIP_PERMS[en]="Setting final ownership and permissions for '%s'..." # %s DEPLOY_DIR
S_SETTING_FINAL_OWNERSHIP_PERMS[pl]="Ustawianie ostatecznej własności i uprawnień dla '%s'..."
declare -A S_APP_DEPLOYED_PERMS_SET_SUCCESS
S_APP_DEPLOYED_PERMS_SET_SUCCESS[en]="Application deployed and permissions set."
S_APP_DEPLOYED_PERMS_SET_SUCCESS[pl]="Aplikacja wdrożona, a uprawnienia ustawione."
declare -A S_CREATING_SERVICE_FILE_AT
S_CREATING_SERVICE_FILE_AT[en]="Creating systemd service file at '%s'..." # %s SERVICE_FILE_PATH
S_CREATING_SERVICE_FILE_AT[pl]="Tworzenie pliku usługi systemd w '%s'..."
declare -A S_SERVICE_NAME_SANITIZED
S_SERVICE_NAME_SANITIZED[en]="Service name '%s' was sanitized to '%s' for the service file name." # %s APP_NAME, %s SAFE_APP_NAME
S_SERVICE_NAME_SANITIZED[pl]="Nazwa usługi '%s' została oczyszczona do '%s' dla nazwy pliku usługi."
declare -A S_SERVICE_FILE_CREATED_SUCCESS
S_SERVICE_FILE_CREATED_SUCCESS[en]="Systemd service file created."
S_SERVICE_FILE_CREATED_SUCCESS[pl]="Plik usługi systemd utworzony."
declare -A S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE
S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE[en]="Reloading systemd daemon, enabling and starting service '%s'..." # %s APP_NAME
S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE[pl]="Przeładowywanie demona systemd, włączanie i uruchamianie usługi '%s'..."
declare -A S_SERVICE_ENABLED_STARTED_SUCCESS
S_SERVICE_ENABLED_STARTED_SUCCESS[en]="Service '%s' enabled and started/restarted." # %s APP_NAME
S_SERVICE_ENABLED_STARTED_SUCCESS[pl]="Usługa '%s' włączona i uruchomiona/zrestartowana."

# --- Step 5: Verification ---
declare -A S_STEP5_TITLE
S_STEP5_TITLE[en]="Step 5: Verification"
S_STEP5_TITLE[pl]="Krok 5: Weryfikacja"
declare -A S_SERVICE_SHOULD_BE_RUNNING
S_SERVICE_SHOULD_BE_RUNNING[en]="The service '%s' should now be running." # %s APP_NAME
S_SERVICE_SHOULD_BE_RUNNING[pl]="Usługa '%s' powinna teraz działać."
declare -A S_CHECK_STATUS_WITH
S_CHECK_STATUS_WITH[en]="You can check its status with:"
S_CHECK_STATUS_WITH[pl]="Możesz sprawdzić jej status za pomocą:"
declare -A S_VIEW_LATEST_LOGS_WITH
S_VIEW_LATEST_LOGS_WITH[en]="View latest logs with:"
S_VIEW_LATEST_LOGS_WITH[pl]="Wyświetl najnowsze logi za pomocą:"
declare -A S_FOLLOW_LOGS_WITH
S_FOLLOW_LOGS_WITH[en]="Follow logs in real-time with (Ctrl+C to stop):"
S_FOLLOW_LOGS_WITH[pl]="Śledź logi w czasie rzeczywistym za pomocą (Ctrl+C aby zatrzymać):"
declare -A S_TO_MANAGE_SERVICE
S_TO_MANAGE_SERVICE[en]="To manage the service:"
S_TO_MANAGE_SERVICE[pl]="Aby zarządzać usługą:"
declare -A S_SERVICE_STOP
S_SERVICE_STOP[en]="Stop"
S_SERVICE_STOP[pl]="Zatrzymaj"
declare -A S_SERVICE_START
S_SERVICE_START[en]="Start"
S_SERVICE_START[pl]="Uruchom"
declare -A S_SERVICE_RESTART
S_SERVICE_RESTART[en]="Restart"
S_SERVICE_RESTART[pl]="Zrestartuj"
declare -A S_SERVICE_DISABLE_AUTOSTART
S_SERVICE_DISABLE_AUTOSTART[en]="Disable auto-start"
S_SERVICE_DISABLE_AUTOSTART[pl]="Wyłącz automatyczne uruchamianie"
declare -A S_SCRIPT_FINISHED_SUCCESS
S_SCRIPT_FINISHED_SUCCESS[en]="GbbConnect2.Console setup script finished!"
S_SCRIPT_FINISHED_SUCCESS[pl]="Skrypt instalacyjny GbbConnect2.Console zakończony!"


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
    echo -e "\n\033[1;34m${S_INFO_PREFIX[$LANG_SELECTED]}\033[0m $1"
}
print_success() {
    echo -e "\033[1;32m${S_SUCCESS_PREFIX[$LANG_SELECTED]}\033[0m $1"
}
print_warning() {
    echo -e "\033[1;33m${S_WARNING_PREFIX[$LANG_SELECTED]}\033[0m $1"
}
print_error() {
    echo -e "\033[1;31m${S_ERROR_PREFIX[$LANG_SELECTED]}\033[0m $1" >&2
}
confirm_action() {
    local prompt_text="$1"
    while true; do
        read -r -p "$prompt_text ${S_CONFIRM_PROMPT_SUFFIX[$LANG_SELECTED]}" response
        case "$response" in
            [yYtT][aA][kK]|[yYtT])
                return 0;;
            [nN][iI][eE]|[nN]|"")
                return 1;;
            *)
                echo "${S_INVALID_INPUT_CONFIRM[$LANG_SELECTED]}";;
        esac
    done
}
prompt_with_default() {
    local prompt_message="$1"; local default_value="$2"; local variable_name="$3"; local input_value
    read -r -p "$prompt_message [${default_value}]: " input_value
    eval "$variable_name=\"${input_value:-$default_value}\""
}
prompt_for_value() {
    local prompt_message="$1"; local variable_name="$2"; local input_value
    while true; do
        read -r -p "$prompt_message: " input_value
        if [ -n "$input_value" ]; then
            eval "$variable_name=\"$input_value\""; break
        else
            print_warning "${S_FIELD_CANNOT_BE_EMPTY[$LANG_SELECTED]}"; fi
    done
}

# --- Main Script ---

# Banner Art
echo -e "\033[1;36m" # Cyan color for banner
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
echo -e "\033[0m" # Reset color

# Welcome message
print_info "${S_WELCOME_TITLE[$LANG_SELECTED]}"
echo "${S_SCRIPT_GUIDE[$LANG_SELECTED]}"
echo "${S_GUIDE_ITEM1[$LANG_SELECTED]}"
echo "${S_GUIDE_ITEM2[$LANG_SELECTED]}"
echo "${S_GUIDE_ITEM3[$LANG_SELECTED]}"
echo "${S_GUIDE_ITEM4[$LANG_SELECTED]}"
echo "${S_GUIDE_ITEM5[$LANG_SELECTED]}"
echo "---"

# --- 1. Prerequisites ---
print_info "${S_STEP1_TITLE[$LANG_SELECTED]}"
PREREQ_CONFIRM_MSG_RAW="${S_CONFIRM_PREREQUISITES[$LANG_SELECTED]} ${DEFAULT_DOTNET_SDK_VERSION}?"
# Using printf for safer variable expansion in confirm_action
PREREQ_CONFIRM_MSG=$(printf "%s %s?" "${S_CONFIRM_PREREQUISITES[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION")


if confirm_action "$PREREQ_CONFIRM_MSG"; then
    print_info "${S_UPDATING_PACKAGES[$LANG_SELECTED]}"
    sudo apt update

    if ! command -v git &> /dev/null; then
        print_info "${S_GIT_NOT_FOUND[$LANG_SELECTED]}"
        sudo apt install -y git
        print_success "${S_GIT_INSTALLED_SUCCESS[$LANG_SELECTED]}"
    else
        print_info "${S_GIT_ALREADY_INSTALLED[$LANG_SELECTED]}"
    fi

    if ! command -v lsb_release &> /dev/null; then
        print_info "${S_LSB_RELEASE_NOT_FOUND[$LANG_SELECTED]}"
        sudo apt install -y lsb-release
        print_success "${S_LSB_RELEASE_INSTALLED_SUCCESS[$LANG_SELECTED]}"
    else
        print_info "${S_LSB_RELEASE_ALREADY_INSTALLED[$LANG_SELECTED]}"
    fi

    if ! command -v rsync &> /dev/null; then
        print_info "${S_RSYNC_NOT_FOUND[$LANG_SELECTED]}"
        sudo apt install -y rsync
        print_success "${S_RSYNC_INSTALLED_SUCCESS[$LANG_SELECTED]}"
    else
        print_info "${S_RSYNC_ALREADY_INSTALLED[$LANG_SELECTED]}"
    fi

    SDK_MAJOR_VERSION=$(echo "$DEFAULT_DOTNET_SDK_VERSION" | cut -d. -f1)
    INSTALL_DOTNET_SDK=false
    
    L_DOTNET_ALREADY_INSTALLED_MSG_FORMATTED=$(printf "${S_DOTNET_ALREADY_INSTALLED_MSG[$LANG_SELECTED]}" "$SDK_MAJOR_VERSION")
    L_DOTNET_NOT_FOUND_MSG_FORMATTED=$(printf "${S_DOTNET_NOT_FOUND_MSG[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION")

    if command -v dotnet &> /dev/null && dotnet --list-sdks | grep -q "^${SDK_MAJOR_VERSION}\."; then
        print_info "$L_DOTNET_ALREADY_INSTALLED_MSG_FORMATTED"
        if confirm_action "${S_DOTNET_CONFIRM_REINSTALL_MSG[$LANG_SELECTED]}"; then
            INSTALL_DOTNET_SDK=true
        fi
    else
        print_info "$L_DOTNET_NOT_FOUND_MSG_FORMATTED"
        INSTALL_DOTNET_SDK=true
    fi

    if [ "$INSTALL_DOTNET_SDK" = true ]; then
        L_DOTNET_INSTALLING_MSG_FORMATTED=$(printf "${S_DOTNET_INSTALLING_MSG[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION")
        print_info "$L_DOTNET_INSTALLING_MSG_FORMATTED"
        
        OS_VERSION_TO_USE=""
        if command -v lsb_release &> /dev/null; then
            OS_VERSION_TO_USE=$(lsb_release -rs)
        else
            print_warning "${S_LSB_RELEASE_UNAVAILABLE_MANUAL_PROMPT[$LANG_SELECTED]}"
        fi

        if [ -z "$OS_VERSION_TO_USE" ]; then
            if confirm_action "${S_OS_VERSION_AUTO_DETECT_FAIL_PROMPT[$LANG_SELECTED]}"; then
                read -r -p "${S_OS_VERSION_PROMPT[$LANG_SELECTED]}: " OS_VERSION_MANUAL
                if [ -z "$OS_VERSION_MANUAL" ]; then
                    print_error "${S_NO_OS_VERSION_ENTERED_ABORT[$LANG_SELECTED]}"
                else
                    OS_VERSION_TO_USE="$OS_VERSION_MANUAL"
                fi
            else
                 print_error "${S_ABORT_NO_OS_VERSION[$LANG_SELECTED]}"
            fi
        fi
        
        if [ -n "$OS_VERSION_TO_USE" ]; then
            L_USING_OS_VERSION_FOR_SETUP_FORMATTED=$(printf "${S_USING_OS_VERSION_FOR_SETUP[$LANG_SELECTED]}" "$OS_VERSION_TO_USE")
            print_info "$L_USING_OS_VERSION_FOR_SETUP_FORMATTED"
            
            if (grep -q "Debian" /etc/os-release &>/dev/null || [ -f /etc/debian_version ]); then
                OS_TYPE="debian"
            elif (grep -q "Ubuntu" /etc/os-release &>/dev/null) ; then
                OS_TYPE="ubuntu"
            else
                print_warning "${S_OS_TYPE_DETERMINE_FAIL_ASSUME_DEBIAN[$LANG_SELECTED]}"
                OS_TYPE="debian" 
            fi

            PACKAGE_URL="https://packages.microsoft.com/config/${OS_TYPE}/${OS_VERSION_TO_USE}/packages-microsoft-prod.deb"
            L_ATTEMPTING_DOWNLOAD_FROM_FORMATTED=$(printf "${S_ATTEMPTING_DOWNLOAD_FROM[$LANG_SELECTED]}" "$PACKAGE_URL")
            print_info "$L_ATTEMPTING_DOWNLOAD_FROM_FORMATTED"

            if wget "$PACKAGE_URL" -O packages-microsoft-prod.deb; then
                sudo dpkg -i packages-microsoft-prod.deb
                rm packages-microsoft-prod.deb
                sudo apt update
                sudo apt install -y apt-transport-https 
                sudo apt install -y "dotnet-sdk-${DEFAULT_DOTNET_SDK_VERSION}"
                L_DOTNET_INSTALL_COMPLETE_FORMATTED=$(printf "${S_DOTNET_INSTALL_COMPLETE[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION")
                print_success "$L_DOTNET_INSTALL_COMPLETE_FORMATTED"
                print_info "${S_DOTNET_VERIFYING_INSTALL[$LANG_SELECTED]}"
                dotnet --version
            else
                print_error "${S_DOWNLOAD_PKG_FAIL[$LANG_SELECTED]}"
                print_error "${S_DOTNET_SKIPPING_INSTALL[$LANG_SELECTED]}"
            fi
        else # OS_VERSION_TO_USE is still empty after prompts
            print_error "${S_COULD_NOT_DETERMINE_OS_VERSION_SKIP_DOTNET[$LANG_SELECTED]}"
            print_error "${S_DOTNET_MANUAL_INSTALL_NOTE[$LANG_SELECTED]}"
        fi
    else # INSTALL_DOTNET_SDK is false
      print_info "${S_DOTNET_SKIPPING_UPDATE[$LANG_SELECTED]}"
    fi
else # User chose not to install prerequisites
    L_PREREQ_SKIPPING_ALL_FORMATTED=$(printf "${S_PREREQ_SKIPPING_ALL[$LANG_SELECTED]}" "$DEFAULT_DOTNET_SDK_VERSION")
    print_info "$L_PREREQ_SKIPPING_ALL_FORMATTED"
fi
echo "---"

# --- 2. Clone Repository ---
print_info "${S_STEP2_TITLE[$LANG_SELECTED]}"
GITHUB_REPO="https://github.com/gbbsoft/GbbConnect2.git" # Hardcoded

L_PROMPT_CLONE_DIR_FORMATTED=$(printf "${S_PROMPT_CLONE_DIR[$LANG_SELECTED]}")
prompt_with_default "$L_PROMPT_CLONE_DIR_FORMATTED" "$DEFAULT_CLONE_DIR" CLONE_DIR

if [ -d "$CLONE_DIR" ]; then
    L_REPO_DIR_EXISTS_FORMATTED=$(printf "${S_REPO_DIR_EXISTS[$LANG_SELECTED]}" "$CLONE_DIR")
    print_info "$L_REPO_DIR_EXISTS_FORMATTED"
    IS_CORRECT_REPO=false
    if [ -d "$CLONE_DIR/.git" ]; then
        CURRENT_REMOTE_URL=$(git -C "$CLONE_DIR" config --get remote.origin.url 2>/dev/null || true)
        if [ "$CURRENT_REMOTE_URL" == "$GITHUB_REPO" ]; then
            print_info "${S_IS_CORRECT_REPO[$LANG_SELECTED]}"
            IS_CORRECT_REPO=true
            if confirm_action "${S_CONFIRM_GIT_PULL[$LANG_SELECTED]}"; then
                L_FETCHING_LATEST_FORMATTED=$(printf "${S_FETCHING_LATEST[$LANG_SELECTED]}" "$CLONE_DIR")
                print_info "$L_FETCHING_LATEST_FORMATTED"
                if git -C "$CLONE_DIR" pull; then
                    print_success "${S_REPO_UPDATED[$LANG_SELECTED]}"
                else
                    print_warning "${S_PULL_FAILED[$LANG_SELECTED]}"
                fi
            else
                L_SKIPPING_UPDATE_USE_CURRENT_FORMATTED=$(printf "${S_SKIPPING_UPDATE_USE_CURRENT[$LANG_SELECTED]}" "$CLONE_DIR")
                print_info "$L_SKIPPING_UPDATE_USE_CURRENT_FORMATTED"
            fi
        else
            L_DIR_EXISTS_WRONG_REPO_URL_FORMATTED=$(printf "${S_DIR_EXISTS_WRONG_REPO_URL[$LANG_SELECTED]}" "$CLONE_DIR" "$CURRENT_REMOTE_URL" "$GITHUB_REPO")
            print_warning "$L_DIR_EXISTS_WRONG_REPO_URL_FORMATTED"
        fi
    else
        L_DIR_EXISTS_NOT_GIT_FORMATTED=$(printf "${S_DIR_EXISTS_NOT_GIT[$LANG_SELECTED]}" "$CLONE_DIR")
        print_warning "$L_DIR_EXISTS_NOT_GIT_FORMATTED"
    fi

    if ! $IS_CORRECT_REPO ; then
        L_CONFIRM_REMOVE_AND_RECLONE_FORMATTED=$(printf "${S_CONFIRM_REMOVE_AND_RECLONE[$LANG_SELECTED]}" "$CLONE_DIR")
        if confirm_action "$L_CONFIRM_REMOVE_AND_RECLONE_FORMATTED"; then
            L_REMOVING_DIR_FORMATTED=$(printf "${S_REMOVING_DIR[$LANG_SELECTED]}" "$CLONE_DIR")
            print_info "$L_REMOVING_DIR_FORMATTED"
            rm -rf "$CLONE_DIR"
            L_CLONING_REPO_TO_FORMATTED=$(printf "${S_CLONING_REPO_TO[$LANG_SELECTED]}" "$GITHUB_REPO" "$CLONE_DIR")
            print_info "$L_CLONING_REPO_TO_FORMATTED"
            git clone "$GITHUB_REPO" "$CLONE_DIR"
            print_success "${S_REPO_CLONED_SUCCESS[$LANG_SELECTED]}"
        else
            L_CANNOT_PROCEED_WRONG_REPO_FORMATTED=$(printf "${S_CANNOT_PROCEED_WRONG_REPO[$LANG_SELECTED]}" "$CLONE_DIR")
            print_error "$L_CANNOT_PROCEED_WRONG_REPO_FORMATTED"
            exit 1
        fi
    fi
else
    L_REPO_DIR_NOT_EXIST_CONFIRM_CLONE_FORMATTED=$(printf "${S_REPO_DIR_NOT_EXIST_CONFIRM_CLONE[$LANG_SELECTED]}" "$CLONE_DIR" "$GITHUB_REPO")
    if confirm_action "$L_REPO_DIR_NOT_EXIST_CONFIRM_CLONE_FORMATTED"; then
        L_CLONING_REPO_TO_FORMATTED=$(printf "${S_CLONING_REPO_TO[$LANG_SELECTED]}" "$GITHUB_REPO" "$CLONE_DIR")
        print_info "$L_CLONING_REPO_TO_FORMATTED"
        git clone "$GITHUB_REPO" "$CLONE_DIR"
        print_success "${S_REPO_CLONED_SUCCESS[$LANG_SELECTED]}"
    else
        L_REPO_NOT_FOUND_DECLINED_CLONE_FORMATTED=$(printf "${S_REPO_NOT_FOUND_DECLINED_CLONE[$LANG_SELECTED]}" "$CLONE_DIR")
        print_error "$L_REPO_NOT_FOUND_DECLINED_CLONE_FORMATTED"
        exit 1
    fi
fi
echo "---"

# --- 3. Compile Application ---
print_info "${S_STEP3_TITLE[$LANG_SELECTED]}"
CONSOLE_PROJECT_PATH="${CLONE_DIR}/${DEFAULT_CONSOLE_PROJECT_SUBDIR}"
PUBLISH_OUTPUT_DIR_NAME="publish_output_self_contained"
PUBLISHED_ARTIFACTS_PATH="${CONSOLE_PROJECT_PATH}/${PUBLISH_OUTPUT_DIR_NAME}"

if [ ! -d "$CONSOLE_PROJECT_PATH" ]; then
    L_CONSOLE_PROJECT_PATH_NOT_FOUND_FORMATTED=$(printf "${S_CONSOLE_PROJECT_PATH_NOT_FOUND[$LANG_SELECTED]}" "$CONSOLE_PROJECT_PATH")
    print_error "$L_CONSOLE_PROJECT_PATH_NOT_FOUND_FORMATTED"
    exit 1
fi

PROGRAM_CS_FILE="${CONSOLE_PROJECT_PATH}/Program.cs"
if [ -f "$PROGRAM_CS_FILE" ]; then
    if grep -q 'Task.Delay(Timeout.Infinite, cts.Token);.' "$PROGRAM_CS_FILE"; then
        L_PROGRAM_CS_SYNTAX_ERROR_DETECTED_FORMATTED=$(printf "${S_PROGRAM_CS_SYNTAX_ERROR_DETECTED[$LANG_SELECTED]}" "$PROGRAM_CS_FILE")
        print_warning "$L_PROGRAM_CS_SYNTAX_ERROR_DETECTED_FORMATTED"
        # Using a temporary file for sed in-place editing for safety
        sed 's/Task.Delay(Timeout.Infinite, cts.Token);./Task.Delay(Timeout.Infinite, cts.Token);/g' "$PROGRAM_CS_FILE" > "${PROGRAM_CS_FILE}.tmp" && \
        mv "${PROGRAM_CS_FILE}.tmp" "$PROGRAM_CS_FILE"
        L_PROGRAM_CS_SYNTAX_FIXED_FORMATTED=$(printf "${S_PROGRAM_CS_SYNTAX_FIXED[$LANG_SELECTED]}" "$PROGRAM_CS_FILE")
        print_success "$L_PROGRAM_CS_SYNTAX_FIXED_FORMATTED"
    fi
else
    L_PROGRAM_CS_NOT_FOUND_SKIP_CHECK_FORMATTED=$(printf "${S_PROGRAM_CS_NOT_FOUND_SKIP_CHECK[$LANG_SELECTED]}" "$PROGRAM_CS_FILE")
    print_warning "$L_PROGRAM_CS_NOT_FOUND_SKIP_CHECK_FORMATTED"
fi

cd "$CONSOLE_PROJECT_PATH"
L_CURRENT_DIRECTORY_FORMATTED=$(printf "${S_CURRENT_DIRECTORY[$LANG_SELECTED]}" "$(pwd)")
print_info "$L_CURRENT_DIRECTORY_FORMATTED"

L_CONFIRM_CLEAN_BUILD_ARTIFACTS_FORMATTED=$(printf "${S_CONFIRM_CLEAN_BUILD_ARTIFACTS[$LANG_SELECTED]}" "$PUBLISH_OUTPUT_DIR_NAME")
if confirm_action "$L_CONFIRM_CLEAN_BUILD_ARTIFACTS_FORMATTED"; then
    print_info "${S_CLEANING_BUILD_ARTIFACTS[$LANG_SELECTED]}"
    rm -rf ./bin ./obj "./${PUBLISH_OUTPUT_DIR_NAME}"
fi

L_PUBLISHING_APP_FOR_RUNTIME_FORMATTED=$(printf "${S_PUBLISHING_APP_FOR_RUNTIME[$LANG_SELECTED]}" "$DEFAULT_PUBLISH_TARGET_RUNTIME")
print_info "$L_PUBLISHING_APP_FOR_RUNTIME_FORMATTED"
if dotnet publish -c Release -r "${DEFAULT_PUBLISH_TARGET_RUNTIME}" --self-contained true -o "./${PUBLISH_OUTPUT_DIR_NAME}" /p:PublishSingleFile=true; then
    L_APP_PUBLISHED_TO_FORMATTED=$(printf "${S_APP_PUBLISHED_TO[$LANG_SELECTED]}" "$PUBLISHED_ARTIFACTS_PATH")
    print_success "$L_APP_PUBLISHED_TO_FORMATTED"
else
    print_error "${S_DOTNET_PUBLISH_FAILED[$LANG_SELECTED]}"
    exit 1
fi
cd - > /dev/null
echo "---"

# --- 4. Systemd Service Setup (Includes Parameters.xml Generation) ---
print_info "${S_STEP4_TITLE[$LANG_SELECTED]}"

if ! confirm_action "${S_CONFIRM_PARAMS_AND_SERVICE_SETUP[$LANG_SELECTED]}"; then
    print_info "${S_SKIPPING_PARAMS_AND_SERVICE_SETUP[$LANG_SELECTED]}"
    L_SETUP_FINISHED_APP_AT_FORMATTED=$(printf "${S_SETUP_FINISHED_APP_AT[$LANG_SELECTED]}" "$PUBLISHED_ARTIFACTS_PATH")
    print_info "$L_SETUP_FINISHED_APP_AT_FORMATTED"
    exit 0
fi

prompt_with_default "${S_PROMPT_SERVICE_USER[$LANG_SELECTED]}" "$DEFAULT_SERVICE_USER" SERVICE_USER
prompt_with_default "${S_PROMPT_APP_NAME_FOR_SERVICE[$LANG_SELECTED]}" "$DEFAULT_APP_NAME" APP_NAME

DEPLOY_DIR="${DEFAULT_DEPLOY_BASE_DIR}/${APP_NAME}"
EXECUTABLE_NAME="GbbConnect2Console"
PARAMETERS_FILE_PATH="${DEPLOY_DIR}/Parameters.xml"

if id -u "$SERVICE_USER" &>/dev/null; then
    L_USER_ALREADY_EXISTS_FORMATTED=$(printf "${S_USER_ALREADY_EXISTS[$LANG_SELECTED]}" "$SERVICE_USER")
    print_info "$L_USER_ALREADY_EXISTS_FORMATTED"
else
    L_CREATING_SYSTEM_USER_FORMATTED=$(printf "${S_CREATING_SYSTEM_USER[$LANG_SELECTED]}" "$SERVICE_USER")
    print_info "$L_CREATING_SYSTEM_USER_FORMATTED"
    sudo useradd --system --no-create-home --shell /usr/sbin/nologin "$SERVICE_USER"
    L_USER_CREATED_SUCCESS_FORMATTED=$(printf "${S_USER_CREATED_SUCCESS[$LANG_SELECTED]}" "$SERVICE_USER")
    print_success "$L_USER_CREATED_SUCCESS_FORMATTED"
fi

L_DEPLOYING_FILES_TO_FORMATTED=$(printf "${S_DEPLOYING_FILES_TO[$LANG_SELECTED]}" "$DEPLOY_DIR")
print_info "$L_DEPLOYING_FILES_TO_FORMATTED"
if [ -d "$DEPLOY_DIR" ]; then
    L_DEPLOY_DIR_EXISTS_FORMATTED=$(printf "${S_DEPLOY_DIR_EXISTS[$LANG_SELECTED]}" "$DEPLOY_DIR")
    print_warning "$L_DEPLOY_DIR_EXISTS_FORMATTED"
    if confirm_action "${S_CONFIRM_REMOVE_CONTENTS_REDEPLOY[$LANG_SELECTED]}"; then
        sudo find "$DEPLOY_DIR" -mindepth 1 -maxdepth 1 ! -name 'Parameters.xml' -exec rm -rf {} +
    else
        print_info "${S_SKIPPING_REMOVAL_OVERWRITE_NOTE[$LANG_SELECTED]}"
    fi
fi
sudo mkdir -p "$DEPLOY_DIR"
L_COPYING_BINARIES_FROM_TO_FORMATTED=$(printf "${S_COPYING_BINARIES_FROM_TO[$LANG_SELECTED]}" "$PUBLISHED_ARTIFACTS_PATH" "$DEPLOY_DIR")
print_info "$L_COPYING_BINARIES_FROM_TO_FORMATTED"
sudo rsync -av --exclude 'Parameters.xml' "${PUBLISHED_ARTIFACTS_PATH}/" "$DEPLOY_DIR/"

print_info "${S_CONFIGURING_PARAMS_XML[$LANG_SELECTED]}"
echo "${S_PARAMS_PROMPT_INTRO[$LANG_SELECTED]}"
echo "${S_MQTT_SERVER_INFO_URL[$LANG_SELECTED]}"
echo "${S_PLANT_ID_TOKEN_INFO[$LANG_SELECTED]}"

prompt_for_value "${S_PROMPT_GBB_PLANT_NAME[$LANG_SELECTED]}" INPUT_GBB_PLANT_NAME
prompt_for_value "${S_PROMPT_DEYE_IP[$LANG_SELECTED]}" INPUT_DEYE_DONGLE_IP
prompt_for_value "${S_PROMPT_DEYE_SN[$LANG_SELECTED]}" INPUT_DEYE_DONGLE_SN
prompt_for_value "${S_PROMPT_PLANT_ID[$LANG_SELECTED]}" INPUT_PLANT_ID
prompt_for_value "${S_PROMPT_PLANT_TOKEN[$LANG_SELECTED]}" INPUT_PLANT_TOKEN
prompt_for_value "${S_PROMPT_MQTT_ADDRESS[$LANG_SELECTED]}" INPUT_MQTT_ADDRESS
prompt_with_default "${S_PROMPT_MQTT_PORT[$LANG_SELECTED]}" "$DEFAULT_MQTT_PORT" INPUT_MQTT_PORT

PARAMETERS_XML_CONTENT=$(cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<Parameters Version="1" Server_AutoStart="1" IsVerboseLog="1" IsDriverLog="0" IsDriverLog2="0">
  <Plant Version="1"
         Number="1"
         Name="${INPUT_GBB_PLANT_NAME}"
         IsDisabled="0"
         AddressIP="${INPUT_DEYE_DONGLE_IP}"
         PortNo="8899"
         SerialNumber="${INPUT_DEYE_DONGLE_SN}"
         GbbVictronWeb_PlantId="${INPUT_PLANT_ID}"
         GbbVictronWeb_PlantToken="${INPUT_PLANT_TOKEN}"
         GbbVictronWeb_Mqtt_Address="${INPUT_MQTT_ADDRESS}"
         GbbVictronWeb_Mqtt_Port="${INPUT_MQTT_PORT}"
         />
</Parameters>
EOF
)

L_WRITING_PARAMS_XML_TO_FORMATTED=$(printf "${S_WRITING_PARAMS_XML_TO[$LANG_SELECTED]}" "$PARAMETERS_FILE_PATH")
print_info "$L_WRITING_PARAMS_XML_TO_FORMATTED"
echo "$PARAMETERS_XML_CONTENT" | sudo tee "$PARAMETERS_FILE_PATH" > /dev/null
print_success "${S_PARAMS_XML_CONFIGURED_SUCCESS[$LANG_SELECTED]}"

L_SETTING_FINAL_OWNERSHIP_PERMS_FORMATTED=$(printf "${S_SETTING_FINAL_OWNERSHIP_PERMS[$LANG_SELECTED]}" "$DEPLOY_DIR")
print_info "$L_SETTING_FINAL_OWNERSHIP_PERMS_FORMATTED"
sudo chown -R "${SERVICE_USER}:${SERVICE_USER}" "$DEPLOY_DIR"
sudo chmod +x "${DEPLOY_DIR}/${EXECUTABLE_NAME}"
sudo chmod 640 "${DEPLOY_DIR}/Parameters.xml"
print_success "${S_APP_DEPLOYED_PERMS_SET_SUCCESS[$LANG_SELECTED]}"

SERVICE_FILE_PATH="/etc/systemd/system/${APP_NAME}.service"
L_CREATING_SERVICE_FILE_AT_FORMATTED=$(printf "${S_CREATING_SERVICE_FILE_AT[$LANG_SELECTED]}" "$SERVICE_FILE_PATH")
print_info "$L_CREATING_SERVICE_FILE_AT_FORMATTED"

SAFE_APP_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9_-]//g')
if [ "$APP_NAME" != "$SAFE_APP_NAME" ]; then
    L_SERVICE_NAME_SANITIZED_FORMATTED=$(printf "${S_SERVICE_NAME_SANITIZED[$LANG_SELECTED]}" "$APP_NAME" "$SAFE_APP_NAME")
    print_warning "$L_SERVICE_NAME_SANITIZED_FORMATTED"
    APP_NAME="$SAFE_APP_NAME"
    SERVICE_FILE_PATH="/etc/systemd/system/${APP_NAME}.service"
fi

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

L_RELOADING_DAEMON_ENABLING_STARTING_SERVICE_FORMATTED=$(printf "${S_RELOADING_DAEMON_ENABLING_STARTING_SERVICE[$LANG_SELECTED]}" "$APP_NAME")
print_info "$L_RELOADING_DAEMON_ENABLING_STARTING_SERVICE_FORMATTED"
sudo systemctl daemon-reload
sudo systemctl enable "${APP_NAME}.service"
sudo systemctl restart "${APP_NAME}.service"
L_SERVICE_ENABLED_STARTED_SUCCESS_FORMATTED=$(printf "${S_SERVICE_ENABLED_STARTED_SUCCESS[$LANG_SELECTED]}" "$APP_NAME")
print_success "$L_SERVICE_ENABLED_STARTED_SUCCESS_FORMATTED"
echo "---"

# --- 5. Verification ---
print_info "${S_STEP5_TITLE[$LANG_SELECTED]}"
L_SERVICE_SHOULD_BE_RUNNING_FORMATTED=$(printf "${S_SERVICE_SHOULD_BE_RUNNING[$LANG_SELECTED]}" "$APP_NAME")
echo "$L_SERVICE_SHOULD_BE_RUNNING_FORMATTED"
echo "${S_CHECK_STATUS_WITH[$LANG_SELECTED]}"
echo "  sudo systemctl status ${APP_NAME}.service"
echo "${S_VIEW_LATEST_LOGS_WITH[$LANG_SELECTED]}"
echo "  sudo journalctl -u ${APP_NAME}.service -n 50 --no-pager"
echo "${S_FOLLOW_LOGS_WITH[$LANG_SELECTED]}"
echo "  sudo journalctl -f -u ${APP_NAME}.service"
echo ""
echo "${S_TO_MANAGE_SERVICE[$LANG_SELECTED]}"
echo "  ${S_SERVICE_STOP[$LANG_SELECTED]}:    sudo systemctl stop ${APP_NAME}.service"
echo "  ${S_SERVICE_START[$LANG_SELECTED]}:   sudo systemctl start ${APP_NAME}.service"
echo "  ${S_SERVICE_RESTART[$LANG_SELECTED]}: sudo systemctl restart ${APP_NAME}.service"
echo "  ${S_SERVICE_DISABLE_AUTOSTART[$LANG_SELECTED]}: sudo systemctl disable ${APP_NAME}.service"
echo ""
print_success "${S_SCRIPT_FINISHED_SUCCESS[$LANG_SELECTED]}"

exit 0