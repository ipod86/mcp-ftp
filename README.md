# mcp-ftp

MCP server that provides FTP access for [Claude Code](https://claude.ai/code).
Manage files on FTP servers directly from Claude Code — upload, download, list, rename, delete, chmod.

## Requirements

- Python 3.10 or newer
- `pip`

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/ipod86/mcp-ftp.git ~/mcp-ftp
cd ~/mcp-ftp
```

### 2. Run setup

```bash
bash setup.sh
```

This will:
- Install Python dependencies
- Create `~/.config/mcp-ftp/` with permissions `700`
- Copy `ftp_config.ini.example` to `~/.config/mcp-ftp/ftp_config.ini` with permissions `600`
- Register the MCP server in Claude Code

### 3. Fill in your FTP credentials

Open the config file in a **regular text editor** (not Claude Code — that is intentionally blocked):

```bash
nano ~/.config/mcp-ftp/ftp_config.ini
```

See [Configuration](#configuration) below for the format.

### 4. Verify the MCP server is running

```bash
claude mcp list
```

---

## Configuration

The config file lives at `~/.config/mcp-ftp/ftp_config.ini` — **outside** the project folder,
never in Git, never readable by Claude Code.

Each FTP server gets its own named block:

```ini
[mein-server]
host = ftp.beispiel.de
port = 21
username = benutzername
password = passwort

[zweiter-server]
host = ftp.anderer.de
port = 21
username = benutzer2
password = passwort2
```

To add a new server: add a blank line, a new `[name]` block, and the four fields. That's it.

---

## Available tools

| Tool | Description |
|------|-------------|
| `list_servers` | List all configured server names |
| `list_directory` | List files and folders in a directory on a server |
| `upload_file` | Upload a local file to the FTP server |
| `download_file` | Download a file from the FTP server to a local path |
| `delete_file` | Delete a file on the FTP server |
| `rename_file` | Rename or move a file on the FTP server |
| `make_directory` | Create a directory on the FTP server |
| `get_permissions` | Show the permissions (chmod) of a file or directory |
| `set_permissions` | Set the permissions (chmod) of a file or directory |

Every tool that accesses a server takes `server_name` as first parameter — matching a block name in the config.

---

## One-liner setup for Claude Code

Paste this into Claude Code on any new machine:

```
Install the MCP FTP server from https://github.com/ipod86/mcp-ftp:
clone the repo to ~/mcp-ftp, then run: bash ~/mcp-ftp/setup.sh
This installs dependencies, creates ~/.config/mcp-ftp/ftp_config.ini and registers the MCP server.
After setup verify with: claude mcp list
Do NOT fill in or read the credentials file — the user does that manually.
```

---

## License

MIT © 2026 ipod86
