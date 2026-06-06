#!/usr/bin/env python3
"""MCP server providing FTP access for Claude Code."""

import configparser
import ftplib
import os
from pathlib import Path

from mcp.server.fastmcp import FastMCP

CONFIG_PATH = Path(__file__).parent / "ftp_config.ini"

mcp = FastMCP("ftp")


def _load_config() -> configparser.ConfigParser:
    cfg = configparser.ConfigParser()
    if not CONFIG_PATH.exists():
        raise FileNotFoundError(
            "ftp_config.ini not found — copy ftp_config.ini.example and fill in your credentials."
        )
    cfg.read(CONFIG_PATH)
    return cfg


def _sanitize(error: Exception, server_name: str, host: str) -> str:
    """Return an error message that never contains credentials."""
    msg = str(error)
    return f"Error connecting to '{server_name}' ({host}): {msg}"


def _connect(server_name: str) -> ftplib.FTP:
    cfg = _load_config()
    if server_name not in cfg:
        available = cfg.sections()
        raise ValueError(f"Server '{server_name}' not found. Available: {available}")
    s = cfg[server_name]
    host = s["host"]
    port = int(s.get("port", 21))
    try:
        ftp = ftplib.FTP()
        ftp.connect(host, port, timeout=10)
    except Exception as e:
        raise ConnectionError(f"Cannot reach '{server_name}' ({host}:{port}): {e}") from None
    try:
        ftp.login(s["username"], s["password"])
    except ftplib.error_perm:
        ftp.close()
        raise PermissionError(
            f"Login to '{server_name}' ({host}:{port}) failed — check username/password in ftp_config.ini"
        ) from None
    return ftp


@mcp.tool()
def list_servers() -> list[str]:
    """List all configured FTP server names from ftp_config.ini."""
    cfg = _load_config()
    return cfg.sections()


@mcp.tool()
def list_directory(server_name: str, path: str = "/") -> list[str]:
    """List files and folders in a directory on the FTP server.

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        path: Remote directory path (default: /)
    """
    ftp = _connect(server_name)
    try:
        lines: list[str] = []
        ftp.retrlines(f"LIST {path}", lines.append)
        return lines
    finally:
        ftp.quit()


@mcp.tool()
def upload_file(server_name: str, local_path: str, remote_path: str) -> str:
    """Upload a local file to the FTP server.

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        local_path: Absolute path to the local file
        remote_path: Destination path on the FTP server
    """
    if not os.path.isfile(local_path):
        raise FileNotFoundError(f"Local file not found: {local_path}")
    ftp = _connect(server_name)
    try:
        with open(local_path, "rb") as f:
            ftp.storbinary(f"STOR {remote_path}", f)
        return f"Uploaded {local_path} → {remote_path}"
    finally:
        ftp.quit()


@mcp.tool()
def download_file(server_name: str, remote_path: str, local_path: str) -> str:
    """Download a file from the FTP server to a local path.

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        remote_path: Path of the file on the FTP server
        local_path: Absolute local destination path
    """
    ftp = _connect(server_name)
    try:
        os.makedirs(os.path.dirname(os.path.abspath(local_path)), exist_ok=True)
        with open(local_path, "wb") as f:
            ftp.retrbinary(f"RETR {remote_path}", f.write)
        return f"Downloaded {remote_path} → {local_path}"
    finally:
        ftp.quit()


@mcp.tool()
def delete_file(server_name: str, remote_path: str) -> str:
    """Delete a file on the FTP server.

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        remote_path: Path of the file to delete on the FTP server
    """
    ftp = _connect(server_name)
    try:
        ftp.delete(remote_path)
        return f"Deleted {remote_path}"
    finally:
        ftp.quit()


@mcp.tool()
def rename_file(server_name: str, from_path: str, to_path: str) -> str:
    """Rename or move a file on the FTP server.

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        from_path: Current path of the file on the FTP server
        to_path: New path / name on the FTP server
    """
    ftp = _connect(server_name)
    try:
        ftp.rename(from_path, to_path)
        return f"Renamed {from_path} → {to_path}"
    finally:
        ftp.quit()


@mcp.tool()
def make_directory(server_name: str, remote_path: str) -> str:
    """Create a directory on the FTP server.

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        remote_path: Path of the directory to create
    """
    ftp = _connect(server_name)
    try:
        ftp.mkd(remote_path)
        return f"Created directory {remote_path}"
    finally:
        ftp.quit()


@mcp.tool()
def get_permissions(server_name: str, remote_path: str) -> str:
    """Show the permissions (chmod) of a file or directory on the FTP server.

    Returns the raw LIST line which includes the permission string (e.g. drwxr-xr-x).

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        remote_path: Path of the file or directory
    """
    ftp = _connect(server_name)
    try:
        lines: list[str] = []
        parent = remote_path.rsplit("/", 1)[0] or "/"
        name = remote_path.rsplit("/", 1)[-1]
        ftp.retrlines(f"LIST {parent}", lines.append)
        for line in lines:
            if line.split()[-1] == name:
                return line
        return "\n".join(lines) if lines else "Not found"
    finally:
        ftp.quit()


@mcp.tool()
def set_permissions(server_name: str, remote_path: str, mode: str) -> str:
    """Set the permissions (chmod) of a file or directory on the FTP server.

    Args:
        server_name: Name of the server as defined in ftp_config.ini
        remote_path: Path of the file or directory
        mode: Permission mode as octal string, e.g. '755' or '644'
    """
    ftp = _connect(server_name)
    try:
        ftp.sendcmd(f"SITE CHMOD {mode} {remote_path}")
        return f"Set permissions {mode} on {remote_path}"
    finally:
        ftp.quit()


if __name__ == "__main__":
    mcp.run()
