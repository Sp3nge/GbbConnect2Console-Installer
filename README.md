# GbbConnect2.Console Linux Installer Script

This Bash script automates the installation and configuration of the `GbbConnect2.Console` application on Debian-based Linux systems (like Debian, Ubuntu). It handles prerequisites, compilation, configuration, and sets up the application to run as a persistent `systemd` service.

**Made by @Sp3nge**

## Features

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
    *   Warns users of Ubuntu 20.04 about .NET 9 incompatibility and its End-of-Life status, allowing them to proceed with the installation attempt at their own risk.
    *   Uses the Microsoft package repository for Debian and other Ubuntu versions.

## Prerequisites (for the system running the script)

*   A Debian-based Linux system (e.g., Debian 10+, Ubuntu 20.04+).
*   `sudo` (administrator) privileges to install packages and manage services.
*   Internet connection to download packages and clone the repository.
*   Basic familiarity with the command line.

## How to Use

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

## Script Steps Overview

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

## Default Configuration Values

The script uses some default values which you'll be prompted to confirm or change:

*   **.NET SDK Version:** 9.0
*   **Clone Directory:** `$HOME/GbbConnect2_build`
*   **Deployment Base Directory:** `/opt`
*   **Application/Service Name:** `gbbconnect2console`
*   **Service User:** `gbbconsoleuser`

## Managing the Service (after installation)

Once installed, you can manage the `gbbconnect2console` (or your chosen app name) service using `systemctl`:

*   **Check Status:**
    ```bash
    sudo systemctl status gbbconnect2console.service
    ```
*   **View Logs:**
    ```bash
    sudo journalctl -u gbbconnect2console.service
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

## Log File Location (Application Logs)

The `GbbConnect2.Console` application itself (not the systemd service logs) typically creates its logs in a subdirectory relative to its execution. Given the systemd service configuration:

*   **Working Directory:** `/opt/gbbconnect2console` (or `/opt/your-app-name`)
*   The application usually creates a `GbbConnect2/Log/` subdirectory.

So, the application logs are likely found in:
**`/opt/gbbconnect2console/GbbConnect2/Log/YYYY-MM-DD.txt`**

## Important Notes

*   **Review Before Running:** Always review scripts from the internet before executing them with `sudo` privileges.
*   **Test Environment:** If possible, test this script in a non-critical environment or a virtual machine first.
*   **`Parameters.xml` Sensitivity:** The `Parameters.xml` file will contain sensitive information like your Plant Token and MQTT details. The script sets permissions on this file to `640` (readable by the service user and its group, no access for others), but ensure your system's overall security is maintained.
*   **.NET 9 Requirement:** This script and the GbbConnect2.Console project it builds target .NET 9. Ensure your OS can support this or that the .NET 9 SDK installs correctly.
*   **Updates to GbbConnect2:** If the `gbbsoft/GbbConnect2` repository structure or build process changes significantly, this script might need updates.

## Contributing / Issues

If you find issues with this installer script or have suggestions for improvement, please feel free to raise an issue or contribute to its development (if it's hosted in a repository).
