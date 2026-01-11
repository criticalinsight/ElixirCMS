# Desktop Packaging (Burrito)

Publii-Ex can be converted into a standalone Windows executable. The recommended build method is enabling **Windows Cross-Compilation** via WSL 2 to ensure stable Zig compilation.

## Requirements (WSL)
- **WSL 2 (Ubuntu)** environment.
- **Mise** (or equivalent) for Erlang, Elixir, and Zig.
- **p7zip-full**: Required for extracting the Windows ERTS installer (`sudo apt install p7zip-full`).

## Building for Windows
1. **WSL Setup**: Ensure dependencies are installed and the project is accessible.
2. **Filesystem Note**: If you encounter Zig cache locking errors on NTFS mounts (`/mnt/c`), copy the project to a native WSL directory (e.g., `~/publii_ex`) before building.
3. **Build Command**:
   ```bash
   export BURRITO_TARGET=windows
   export MIX_ENV=prod
   mix release publii_ex --overwrite
   ```

## Output & Launching
- The executable is generated at `burrito_out/publii_ex_windows.exe`.
- **Launcher**: Use the included `launch_portable.bat` script on Windows to start the portable application correctly (sets `PHX_SERVER=true`).
- **Port**: The application will be available at `http://localhost:4000`.

## Maintenance
Ensure `config/runtime.exs` handles missing `SECRET_KEY_BASE` gracefully if deploying as a portable app (defaults provided in current codebase).
