#!/bin/bash
# Setup script for mcp-ftp
# Run once after cloning: bash setup.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/mcp-ftp"
CONFIG_FILE="$CONFIG_DIR/ftp_config.ini"

echo "=== mcp-ftp setup ==="

# 1. Dependencies
echo "Installing dependencies..."
python3 -m pip install -r "$SCRIPT_DIR/requirements.txt" --break-system-packages -q

# 2. Config directory + file (outside project folder)
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_FILE" ]; then
    cp "$SCRIPT_DIR/ftp_config.ini.example" "$CONFIG_FILE"
    echo "Created $CONFIG_FILE — fill in your FTP credentials."
else
    echo "Config already exists: $CONFIG_FILE"
fi

# 3. Lock down permissions (owner-read/write only)
chmod 700 "$CONFIG_DIR"
chmod 600 "$CONFIG_FILE"
echo "Set permissions: $CONFIG_DIR (700), $CONFIG_FILE (600)."

# 4. Register MCP server in Claude Code
if claude mcp add ftp python3 "$SCRIPT_DIR/ftp_server.py" 2>/dev/null; then
    echo "MCP server 'ftp' registered in Claude Code."
else
    echo "Could not register automatically — run manually:"
    echo "  claude mcp add ftp python3 $SCRIPT_DIR/ftp_server.py"
fi

echo ""
echo "=== Done ==="
echo "Next: open $CONFIG_FILE in a text editor and fill in your FTP credentials."
echo "Do NOT use Claude Code to edit that file — it is intentionally blocked."
