# ElixirCMS (formerly Publii-Ex) Roadmap

This roadmap outlines the evolution of ElixirCMS from a "Localhost Monolith" to a world-class, desktop-first static site CMS.

## Phase 1: Core Robustness ✅
- [x] **Theme Marketplace Logic**: Load themes safely from `priv/themes`.
- [x] **Multisite Support Scoping**: Ensure posts/pages are correctly site-scoped in CubDB.
- [x] **Error Handling**: Graceful recovery from malformed theme files or missing assets.

## Phase 2: Visual Revolution ⚡
- [x] **Visual Block Editor**: Implement a block-based editor (Editor.js) that saves to JSON.
- [ ] **Advanced Media Manager**: Drag-and-drop uploads, image editing, and folder organization.
- [ ] **Live Theme Customizer**: Sidebar to change colors, fonts, and layouts with instant preview.

## Phase 3: Ecosystem & Power 🧩
- [x] **Plugin Architecture**: Hook system for extending the build process and UI.
- [x] **Search Integration**: Auto-generate `search.json` and Pagefind indexing.
- [ ] **One-Click Migrators**: Import from WordPress (WXR) and Ghost (JSON).

## Phase 4: Native Desktop (Desktop-First) 🖥️
- [x] **Tauri Integration**: Create a native app shell for Windows/macOS/Linux.
- [x] **Sidecar Bundling**: Bundle the Elixir release inside the Tauri app.
- [ ] **System Tray & Notifications**: Publish progress in the system tray.

## Phase 5: Enterprise & Global �
- [ ] **Multi-language Support**: i18n for admin UI and generated sites.
- [ ] **Scheduled Publishing**: Local worker to auto-build/deploy at a specific time.
- [ ] **Access Control**: Simple password protection for the local admin UI.

---

*Last Updated: 2026-01-11*
