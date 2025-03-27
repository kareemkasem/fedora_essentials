# Description

This Bash script automates the setup of a Fedora system, ensuring it is updated, configured with essential software, and optimized for development and daily use. It installs multimedia codecs, Flatpak applications, GNOME extensions, and useful development tools. Additionally, it offers an optional installation of Node.js development tools, MongoDB, and WebStorm.

# Features

*RPM Fusion Repositories:* Enables free and non-free repositories for better software availability.

*Multimedia Support:* Installs essential codecs and replaces ffmpeg-free with the full ffmpeg package.

*Flatpak & Essential Apps:* Installs Flatpak and key applications like Flatseal, LocalSend, and PeaZip.

*GNOME Customization:* Installs useful GNOME extensions and themes (extensions hve to be enabled manually)

*Brave Browser:* Installs and configures the Brave web browser.

*Firefox GNOME Theme:* Enhances Firefox to match GNOME’s aesthetics.

*GitHub CLI:* Installs GitHub’s command-line interface for better workflow.

*Optional Node.js Development Setup:*

Installs Node.js and npm.

Installs the latest MongoDB and Compass.

Installs Postman via Flatpak.

Installs WebStorm with a desktop entry.



# Usage

1. Run the script as root:

sudo ./script.sh


2. The script will prompt you for optional Node.js development tool installation. Type y to proceed or n to skip.



# Prerequisites

Fedora-based system

Internet connection

Root privileges (sudo)


# Notes

The script ensures all required dependencies are available before proceeding.

It performs error handling to prevent issues due to missing internet or incorrect privileges.

WebStorm and MongoDB versions are fetched dynamically for up-to-date installations.

