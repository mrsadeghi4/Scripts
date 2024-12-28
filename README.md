# Automation Scripts

This repository contains a collection of PowerShell and Bash scripts designed to automate various tasks for system administrators. These scripts cover a wide range of activities, including software installation, daily maintenance, and other administrative workflows.
This Repo will be growth day to day, I hope ;)

## Table of Contents

1- Purpose

2- Prerequisites

3- Scripts Overview

4- Usage

5- Customization

6- Contributing

7- License

## Purpose

These scripts are designed to:

- Automate repetitive tasks.

- Streamline installations and configurations.

- Save time and reduce human error in system administration tasks.

## Prerequisites

- Operating System: Most scripts are designed for Windows (PowerShell) or Linux (Bash). Ensure you are using the appropriate platform.

- Permissions: Administrator/root privileges may be required for some scripts.

- Dependencies: Install any required tools or libraries as mentioned in the script documentation.

- Scripting Environment:

  - PowerShell: Version 5.1 or higher (preferably PowerShell 7+).

  - Bash: Ensure the bash shell and necessary utilities are available on your system.

## Scripts Overview

### PowerShell Scripts

1- Install-Software.ps1

  - Automates software installation for Windows systems.

  - Supports MSI and EXE installers with silent installation options.

2- Daily-Task-Automation.ps1

  - Handles recurring tasks such as clearing logs, updating software, and verifying system health.

3- Configure-Windows.ps1

  - Configures Windows settings, such as enabling/disabling services, modifying registry keys, and configuring network settings.

## Bash Scripts

1- install_packages.sh

  - Installs and configures required software on Linux systems.

  - Supports package managers like apt, yum, and dnf.

2- daily_maintenance.sh

  - Automates daily maintenance tasks such as log rotation, disk cleanup, and package updates.

3- configure_linux.sh

  - Configures system settings, such as firewall rules, network interfaces, and SSH configurations.

## Usage

1- Clone the repository to your local machine:
```bash
git clone <repository_url>
cd <repository_directory>
```

2- Identify the script you need for your task.

3- Run the script with the appropriate interpreter:

- For PowerShell:
```ps1
pwsh ./script_name.ps1
```
- For Bash:
```bash
bash ./script_name.sh
```
4- Follow any additional instructions or input prompts provided by the script.

## Customization

Each script is designed to be modular and customizable. To tailor a script to your specific requirements:

1- Open the script in a text editor.

2- Modify variables and parameters as needed (these are usually defined at the top of the script).

Save the changes and test the script in a controlled environment before deploying it to production.

## Contributing

Contributions are welcome! To contribute:

1- Fork this repository.

2- Create a new branch for your feature or bugfix.

3- Commit your changes and submit a pull request with a detailed description.


## Disclaimer

These scripts are provided "as-is" without any warranty. Test them in a non-production environment before use, and use them at your own risk.
