# mcp-ftp

MCP server that provides **FTP / FTPS / SFTP** access for [Claude Code](https://claude.ai/code).
Manage files on remote servers directly from Claude Code — upload, download, list, search, rename, delete, chmod.

> **Windows?** Use the [mcp-ftp-win](https://github.com/ipod86/mcp-ftp-win) repo instead.

---

## Requirements

- Python 3.10 or newer
- `pip`

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/ipod86/mcp-ftp.git ~/mcp-ftp
```

### 2. Run the root setup (once, as root / sudo)

```bash
sudo bash ~/mcp-ftp/manual_root_setup.sh
```

This will:
- Create a dedicated system user `mcp-ftp` (no login shell)
- Install server code to `/opt/mcp-ftp/` with a Python venv (includes `mcp` + `paramiko`)
- Create `/etc/mcp-ftp/ftp_config.ini` (from the example) with strict permissions (owner: mcp-ftp, chmod 600)
- Create `/var/lib/mcp-ftp/exchange/` (chmod 770, group mcp-ftp) and add your user to the group
- Install and start the systemd service `mcp-ftp`

Log out and back in once after setup so the group membership takes effect.

### 3. Register the MCP connector (no sudo required)

```bash
claude mcp add --transport sse ftp http://127.0.0.1:8765/sse
```

### 4. Enter your credentials

Open the config file in a **regular text editor** (not Claude Code — that is intentionally blocked):

```bash
sudo -u mcp-ftp nano /etc/mcp-ftp/ftp_config.ini
```

See [Configuration](#configuration) below for the format.

### 5. Verify

```bash
systemctl status mcp-ftp.service
```

---

## Configuration

The config lives at `/etc/mcp-ftp/ftp_config.ini` — owned by the `mcp-ftp` service user,
not readable by your normal account or Claude Code.

Each server is one INI block. The `type` field is optional and defaults to `ftp`:

```ini
[my-ftp-server]
type     = ftp
host     = ftp.example.com
port     = 21
username = user
password = secret

[my-ftps-server]
type     = ftps
host     = ftp.example.com
port     = 21
username = user
password = secret

[my-sftp-server]
type     = sftp
host     = ssh.example.com
port     = 22
username = user
password = secret
```

After editing, restart the service:

```bash
sudo systemctl restart mcp-ftp.service
```

---

## Available tools

### Diagnostics

| Tool | Description |
|------|-------------|
| `list_servers` | List all configured server names |
| `test_connection` | Check that a server is reachable and credentials are correct |

### Browsing

| Tool | Description |
|------|-------------|
| `list_directory` | List files and folders in a directory |
| `find_files` | Recursively search for files by name pattern (e.g. `*.log`, `backup_*`) |
| `get_file_info` | Show size, modification time and permissions of a file |
| `read_text_file` | Read a text file directly as a string (no download needed) |

### Transfer

| Tool | Description |
|------|-------------|
| `upload_file` | Upload a local file to the server |
| `download_file` | Download a file from the server into the exchange directory |
| `upload_directory` | Recursively upload a local directory to the server |
| `download_directory` | Recursively download a remote directory into the exchange directory |

### File operations

| Tool | Description |
|------|-------------|
| `delete_file` | Delete a file on the server |
| `rename_file` | Rename or move a file on the server |
| `make_directory` | Create a directory on the server |
| `remove_directory` | Remove an empty directory on the server |
| `get_permissions` | Show the chmod permissions of a file or directory |
| `set_permissions` | Set the chmod permissions of a file or directory |

---

## Exchange directory

Because the `mcp-ftp` service runs as an isolated user, it cannot access your home directory.
Files for upload/download pass through a shared exchange directory:

| Path | Purpose |
|------|---------|
| `/var/lib/mcp-ftp/exchange/` | Place files here before uploading; downloads land here |

Both the `mcp-ftp` service user and your normal account (via group membership) have read/write access.

---

## Updating

To pull the latest version from GitHub and restart the service:

```bash
sudo bash ~/mcp-ftp/update.sh
```

The script stops the service, runs `git pull`, copies the new `ftp_server.py` to `/opt/mcp-ftp/`,
upgrades Python packages, fixes ownership, and starts the service again.

---

## Security check

As your normal (non-root) user:

```bash
cat /etc/mcp-ftp/ftp_config.ini
```

Expected result: `Permission denied`
If the file is readable: the permissions are wrong — re-run the setup script.

---

## One-liner for a new machine

Paste this into Claude Code:

```
Install the MCP FTP/SFTP server from https://github.com/ipod86/mcp-ftp:
clone the repo to ~/mcp-ftp, then run: sudo bash ~/mcp-ftp/manual_root_setup.sh
After that, register the connector: claude mcp add --transport sse ftp http://127.0.0.1:8765/sse
Do NOT fill in or read the credentials file — the user does that manually.
```

---

## License

MIT © 2026 ipod86
