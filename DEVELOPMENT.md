# Development Guide

## Architecture Overview

Publii-Ex follows a **Localhost Monolith** pattern. It runs as a local web server (Phoenix) that you interact with via your browser, but it operates on your local file system.

### Core Components

*   **CubDB (Persistence)**:
    *   We use [CubDB](https://github.com/lucaong/cubdb) for an embedded, pure-Elixir Key-Value store.
    *   **Data Model**:
        *   `sites:{id}` -> `PubliiEx.Site` struct
        *   `sites:{id}:posts:{post_id}` -> `PubliiEx.Post` struct
        *   `sites:{id}:pages:{page_id}` -> `PubliiEx.Page` struct

*   **Generator (Static Site Generator)**:
    *   Located in `lib/publii_ex/generator.ex`.
    *   Compiles content using EEx templates found in `priv/themes/{theme_name}`.
    *   Outputs static HTML to `output/sites/{id}`.

*   **Deployer (Orchestration)**:
    *   Located in `lib/publii_ex/deployer.ex`.
    *   Handles "Sync" operations.
    *   Wraps CLI tools like `git` and `npx wrangler` to push the `output` directory to remote hosts.

### Directory Structure

*   `lib/publii_ex` - Core business logic (Contexts, Structs).
*   `lib/publii_ex_web` - Phoenix LiveView UI.
*   `priv/themes` - Theme templates.
*   `priv/static/uploads` - User uploaded media.
*   `output` - Generated static sites (gitignored).

## Setting Up Development Environment

1.  **Install Elixir & Erlang**: Ensure you have a working Elixir environment.
2.  **Install Node.js**: Required for tailwind/esbuild assets and the `npx` wrapper.
3.  **Setup Project**:
    ```bash
    mix deps.get
    mix assets.setup
    ```

## Running Tests

```bash
mix test
```

## Building for Release (Windows)

We use the standard Mix Release to create a self-contained folder.

```bash
mix release
```

The release artifacts will be generated in `_build/dev/rel/publii_ex`.
*   **Run**: `bin/publii_ex.bat start`
*   **Distribute**: Zip the entire `publii_ex` folder.
