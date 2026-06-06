#!/bin/bash
# update.sh
# Aktualisiert mcp-ftp auf die neueste GitHub-Version.
# Muss mit sudo ausgefuehrt werden.
#
# Ausfuehren:
#   sudo bash ~/mcp-ftp/update.sh

set -e

REPO="/opt/mcp-ftp"
SRC="$HOME/mcp-ftp"

echo "=== mcp-ftp Update ==="

# 1) Dienst stoppen
echo "Stoppe Dienst..."
sudo systemctl stop mcp-ftp.service

# 2) Neueste Version aus GitHub holen
echo "Hole neueste Version (git pull)..."
git -C "$SRC" pull

# 3) Server-Code kopieren
echo "Aktualisiere Server-Code in $REPO ..."
sudo cp "$SRC/ftp_server.py" "$REPO/"

# 4) Python-Packages aktualisieren (mcp + paramiko fuer SFTP)
echo "Aktualisiere Python-Packages..."
sudo "$REPO/venv/bin/pip" install --upgrade mcp paramiko --quiet

# 5) Rechte sicherstellen
sudo chown -R mcp-ftp:mcp-ftp "$REPO"
sudo chmod -R go-w "$REPO"

# 6) Dienst wieder starten
echo "Starte Dienst neu..."
sudo systemctl start mcp-ftp.service

echo ""
echo "=== Update abgeschlossen ==="
systemctl is-active mcp-ftp.service && echo "Dienst: aktiv" || echo "Dienst: NICHT aktiv -- bitte pruefen"
