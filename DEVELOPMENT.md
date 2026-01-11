# Development Guide

## Architecture Overview

ElixirCMS follows a **Localhost Monolith** pattern. It runs as a local web server (Phoenix) that you interact with via your browser or a native desktop shell (Tauri).

### Frontend Dashboard
- **Phoenix LiveView**: Handles all interactive UI logic without JavaScript heavy lifting.
- **Visual Editor**: Integrated **Editor.js** via LiveView Hooks.
  - **Hook**: `EditorJSHook` in `assets/js/app.js`.
  - **Storage**: Block data is stored as JSON in the `:content_delta` field of Posts/Pages.
  - **Rendering**: Converted to HTML on-the-fly during site generation by `PubliiEx.Editor`.

### Native Desktop (Tauri)
- **Tauri Shell**: A Rust-based application that wraps the Phoenix UI.
- **Sidecar**: In production mode, Tauri spawns the Elixir release as a background "sidecar" process.
- **Bridge**: Tauri's `devUrl` points to the Phoenix dev server (port 4001) for real-time frontend/backend development.

### Core Components

*   **CubDB (Persistence)**:
    *   Embedded, pure-Elixir Key-Value store.
    *   **Data Model**:
        *   `sites:{id}` -> `PubliiEx.Site`
        *   `sites:{id}:posts:{post_id}` -> `PubliiEx.Post`
        *   `sites:{id}:pages:{page_id}` -> `PubliiEx.Page`

*   **Generator (Static Site Generator)**:
    *   Located in `lib/publii_ex/generator.ex`.
    *   Compiles content using EEx templates in `priv/themes/{theme_name}`.
    *   **Content Pipeline**: Prioritizes block-editor delta over raw Markdown.
    *   **Search**: Generates `search.json` and runs **Pagefind** indexing.

*   **Plugin Architecture**:
    *   Hook system in `lib/publii_ex/plugins.ex`.
    *   Allows transforming content, injecting scripts into `<head>`, or adding sidebar widgets.

## Setting Up Development Environment

1.  **Install Elixir & Erlang**: Version 1.15+ recommended.
2.  **Install Rust**: Required for building the Tauri desktop app.
3.  **Install Node.js**: Required for asset processing and Editor.js plugins.
4.  **Setup Project**:
    ```bash
    mix setup
    ```

## Development Workflow

### Web Mode
For standard browser-based development:
```bash
mix phx.server
```

### Desktop Mode
To test the native app shell:
```bash
# 1. Start Phoenix
mix phx.server

# 2. In another terminal, start Tauri
npm run tauri dev
```

## Running Tests

```bash
mix test
```

## Building for Release

### 1. Elixir Release (Sidecar)
```bash
$env:MIX_ENV="prod"; mix release
```

### 2. Tauri App (Installer)
```bash
npm run tauri build
```
