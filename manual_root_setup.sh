#!/bin/bash
# manual_root_setup.sh
# Einmalig als root / mit sudo ausfuehren, NACHDEM du Claude Code beendet hast.
# Quelle: geklontes Repo in ~/mcp-ftp

set -e
REPO="$HOME/mcp-ftp"

echo "=== mcp-ftp: Root-Setup ==="

# 1) Dedizierten Dienst-Benutzer ohne Login anlegen
sudo useradd --system --no-create-home --shell /usr/sbin/nologin mcp-ftp

# 2) Server-Code an einen geschuetzten Ort kopieren
#    (gehoert mcp-ftp, fuer Alltagsbenutzer nicht schreibbar)
sudo mkdir -p /opt/mcp-ftp
sudo cp "$REPO/ftp_server.py" /opt/mcp-ftp/
sudo python3 -m venv /opt/mcp-ftp/venv
sudo /opt/mcp-ftp/venv/bin/pip install mcp --quiet
sudo chown -R mcp-ftp:mcp-ftp /opt/mcp-ftp
sudo chmod -R go-w /opt/mcp-ftp

# 3) Config-Verzeichnis + -Datei anlegen (gehoert mcp-ftp, Rechte 600)
sudo mkdir -p /etc/mcp-ftp
sudo cp "$REPO/ftp_config.ini.example" /etc/mcp-ftp/ftp_config.ini
sudo chown -R mcp-ftp:mcp-ftp /etc/mcp-ftp
sudo chmod 700 /etc/mcp-ftp
sudo chmod 600 /etc/mcp-ftp/ftp_config.ini

# 4) Austauschordner fuer Downloads anlegen
sudo mkdir -p /var/lib/mcp-ftp/exchange
sudo chown -R mcp-ftp:mcp-ftp /var/lib/mcp-ftp
sudo chmod 770 /var/lib/mcp-ftp/exchange
# Alltagsbenutzer der Gruppe hinzufuegen (Zugriff auf heruntergeladene Dateien)
sudo usermod -aG mcp-ftp "$USER"
echo "HINWEIS: Bitte einmal ab- und wieder anmelden, damit die Gruppenzugehoerigkeit aktiv wird."

# 5) systemd-Dienst installieren und starten
sudo cp "$REPO/mcp-ftp.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now mcp-ftp.service

# 6) Status pruefen
echo ""
systemctl status mcp-ftp.service --no-pager

echo ""
echo "=== Fertig ==="
echo ""
echo "Zugangsdaten eintragen (Rechte bleiben erhalten):"
echo "  sudo -u mcp-ftp nano /etc/mcp-ftp/ftp_config.ini"
echo ""
echo "Danach Dienst neu starten:"
echo "  sudo systemctl restart mcp-ftp.service"
