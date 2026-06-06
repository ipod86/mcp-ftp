# mcp-ftp

MCP server that provides FTP access for [Claude Code](https://claude.ai/code).
Manage files on FTP servers directly from Claude Code — upload, download, list, rename, delete, chmod.

## Requirements

- Python 3.10 or newer
- `pip`

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/ipod86/mcp-ftp.git
cd mcp-ftp
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure FTP credentials

```bash
cp ftp_config.ini.example ftp_config.ini
```

Open `ftp_config.ini` and fill in your FTP credentials (see [Configuration](#configuration) below).

### 4. Register the MCP server in Claude Code

```bash
claude mcp add ftp python /absolute/path/to/mcp-ftp/ftp_server.py
```

Replace `/absolute/path/to/mcp-ftp/` with the actual path where you cloned the repo.

To verify it is registered:

```bash
claude mcp list
```

---

## Configuration

`ftp_config.ini` uses a simple INI format. Each FTP server gets its own named block:

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

`ftp_config.ini` is listed in `.gitignore` and will never be committed to Git.

---

## Available tools

| Tool | Description |
|------|-------------|
| `list_servers` | List all configured server names from `ftp_config.ini` |
| `list_directory` | List files and folders in a directory on a server |
| `upload_file` | Upload a local file to the FTP server |
| `download_file` | Download a file from the FTP server to a local path |
| `delete_file` | Delete a file on the FTP server |
| `rename_file` | Rename or move a file on the FTP server |
| `make_directory` | Create a directory on the FTP server |
| `get_permissions` | Show the permissions (chmod) of a file or directory |
| `set_permissions` | Set the permissions (chmod) of a file or directory |

Every tool that accesses a server takes `server_name` as first parameter — matching a block name in `ftp_config.ini`.

---

## One-liner setup for Claude Code

Paste this into Claude Code on any new machine to clone, install and register the server in one go:

```
Install the MCP FTP server from https://github.com/ipod86/mcp-ftp:
clone the repo to ~/mcp-ftp, run pip install -r requirements.txt,
then register it with: claude mcp add ftp python ~/mcp-ftp/ftp_server.py
Do NOT start or test it — just install and register.
```

---

## License

MIT © 2026 ipod86
