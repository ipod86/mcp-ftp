#!/bin/bash
# Setup script for mcp-ftp
# Run once after cloning: bash setup.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== mcp-ftp setup ==="

# 1. Dependencies
echo "Installing dependencies..."
python3 -m pip install -r "$SCRIPT_DIR/requirements.txt" --break-system-packages -q

# 2. Config
if [ ! -f "$SCRIPT_DIR/ftp_config.ini" ]; then
    cp "$SCRIPT_DIR/ftp_config.ini.example" "$SCRIPT_DIR/ftp_config.ini"
    echo "Created ftp_config.ini from example — fill in your FTP credentials."
fi

# 3. Lock down the config file so only the current user can read it
chmod 600 "$SCRIPT_DIR/ftp_config.ini"
echo "Set ftp_config.ini permissions to 600 (owner-read only)."

# 4. Register MCP server in Claude Code
claude mcp add ftp python3 "$SCRIPT_DIR/ftp_server.py" 2>/dev/null && \
    echo "MCP server 'ftp' registered in Claude Code." || \
    echo "Could not register MCP server automatically — run manually:"
    echo "  claude mcp add ftp python3 $SCRIPT_DIR/ftp_server.py"

echo ""
echo "=== Done ==="
echo "Next: open ftp_config.ini in a text editor and fill in your FTP credentials."
echo "Do NOT use Claude Code to edit ftp_config.ini — that file is intentionally blocked."
