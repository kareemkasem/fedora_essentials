#!/bin/bash

set -eu # Exit on error or unset variables

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Ensure an internet connection is available
if ! ping -c 1 google.com &>/dev/null; then
    echo "No internet connection. Please check your connection and try again."
    exit 1
fi

# Update and upgrade system
dnf upgrade --refresh -y

# Enable RPM Fusion repositories
dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install multimedia group
dnf swap ffmpeg-free ffmpeg --allowerasing -y
dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Check if flatpak is installed
if ! command -v flatpak &>/dev/null; then
    dnf install flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Check if curl is installed
if ! command -v curl &>/dev/null; then
    dnf install curl -y
fi

# Check if wget is installed
if ! command -v wget &>/dev/null; then
    dnf install wget -y
fi

# Install Gnome Essentials
dnf install -y gnome-tweaks gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock gnome-shell-extension-light-style
git clone https://github.com/mukul29/legacy-theme-auto-switcher-gnome-extension.git /usr/share/gnome-shell/extensions/
git clone https://github.com/dpejoh/Adwaita-colors /usr/share/gnome-shell/extensions/
flatpak install --noninteractive flathub com.mattjakeman.ExtensionManager
flatpak install --noninteractive flathub com.github.tchx84.Flatseal
flatpak install --noninteractive flathub io.github.realmazharhussain.GdmSettings
flatpak install --noninteractive flathub org.localsend.localsend_app
flatpak install --noninteractive flathub io.github.peazip.PeaZip

# Install brave browser
dnf install dnf-plugins-core -y
dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf install brave-browser -y

# Modify firefox theme to be more gnome like
if command -v firefox &>/dev/null; then
    curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
fi

# Install ulauncher
dnf install ulauncer
mkdir -p ~/.config/ulauncher/user-themes
git clone https://github.com/kareemkasem/ulauncher-theme-libadwaita-dark \
    ~/.config/ulauncher/user-themes/libadwaita-dark

# Install Github command line tools
dnf install dnf5-plugins -y
dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
dnf install gh --repo gh-cli -y

# (optional) Install my nodejs development software
echo "Do you want to install the Node.js development tools? (y/n)"
read response

if [ "$response" = "y" ]; then
    # Install Node.js
    dnf install -y nodejs npm

    # Get Latest MongoDB Version
    MONGO_VERSION=$(curl -s https://www.mongodb.com/try/download/community | grep -oP '(?<=mongodb-org/)[0-9]+\.[0-9]+' | head -1)

    # Add MongoDB Repository
    tee /etc/yum.repos.d/mongodb-org.repo >/dev/null <<EOF
[mongodb-org]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/9/mongodb-org/$MONGO_VERSION/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-$MONGO_VERSION.asc
EOF

    # Install Latest MongoDB
    dnf install -y mongodb-org
    dnf swap -y mongodb-mongosh mongodb-mongosh-shared-openssl3

    # Install Postman via Flatpak
    flatpak install --noninteractive flathub com.getpostman.Postman

    # Install jq
    dnf install -y jq

    # Download & Install WebStorm
    cd /tmp
    LATEST_URL=$(curl -s https://data.services.jetbrains.com/products/releases?code=WS | jq -r '.WS[0].downloads.linux.link')
    wget "$LATEST_URL" -O WebStorm-latest.tar.gz
    tar -xzf WebStorm-latest.tar.gz -C /opt/
    ln -sf /opt/WebStorm-*/bin/webstorm.sh /usr/local/bin/webstorm

    # Create WebStorm Desktop Entry
    WEBSTORM_DIR=$(ls -d /opt/WebStorm-*/ | head -1)
    tee /usr/share/applications/jetbrains-webstorm.desktop >/dev/null <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=WebStorm
Icon=${WEBSTORM_DIR}bin/webstorm.svg
Exec="${WEBSTORM_DIR}bin/webstorm" %f
Comment=The smartest JavaScript IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-webstorm
StartupNotify=true
EOF

    # Clean up WebStorm tar file
    rm -f WebStorm-latest.tar.gz

    # Download & Install MongoDB Compass
    LATEST_URL=$(curl -s https://www.mongodb.com/try/download/compass | grep -oP 'https://downloads\.mongodb\.com/compass/mongodb-compass-[^"]+\.x86_64\.rpm' | head -1)
    wget "$LATEST_URL" -O mongodb-compass-latest.rpm
    dnf install -y mongodb-compass-latest.rpm
    rm -f mongodb-compass-latest.rpm
fi

echo "Done :)"
