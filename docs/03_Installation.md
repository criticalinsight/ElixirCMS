# Installation & Setup

## Development Environment
To contribute to Publii-Ex or run it from source, you need:
- **Elixir:** 1.15 or higher.
- **Erlang/OTP:** 26 or higher.
- **Node.js:** (For asset compilation).
- **Git:** Required for deployment features.
- **Zig (0.13.0):** Required if building standalone executables with Burrito.

## Initial Setup
1. Clone the repository.
2. Fetch dependencies:
   ```bash
   mix deps.get
   ```
3. Initialize the database:
   *(No migration needed, CubDB initializes on startup)*.
4. Build assets:
   ```bash
   mix assets.setup
   mix assets.build
   ```
5. Start the server:
   ```bash
   mix phx.server
   ```

## Windows Specifics
If running on Windows, ensure your Terminal has execution permissions. The Pagefind binary used for search is automatically downloaded to `priv/bin/pagefind.exe` during the first build process.
