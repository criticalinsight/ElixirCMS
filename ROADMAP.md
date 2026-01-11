# ElixirCMS (formerly Publii-Ex) Roadmap

This roadmap outlines the evolution of ElixirCMS from a "Localhost Monolith" to a world-class, desktop-first static site CMS.

## Phase 1: Core Robustness ✅
- [x] **Theme Marketplace Logic**: Load themes safely from `priv/themes`.
- [x] **Multisite Support Scoping**: Ensure posts/pages are correctly site-scoped in CubDB.
- [x] **Error Handling**: Graceful recovery from malformed theme files or missing assets.

## Phase 2: Visual Revolution ⚡
- [x] **Advanced Media Manager**: Drag-and-drop uploads, image management, and professional folder organization.
- [x] **Live Theme Customizer**: Real-time design studio with iframe sandboxing and **CSS Hot-Reloading**.

- [x] **Plugin Architecture**: Advanced hook system (`:before_build`, `:after_render`, etc.) for deep CMS extensions.
- [x] **Search Integration**: Auto-generate `search.json` and Pagefind indexing for zero-config search.
- [x] **High-Performance Infrastructure**: Persistent caching with **Cache Warm-up** for instant builds.
- [ ] **One-Click Migrators**: Import from WordPress (WXR), Ghost (JSON), and static HTML crawlers.

## Phase 4: Native Desktop (Desktop-First) 🖥️
- [x] **Tauri Integration**: Create a native app shell for Windows/macOS/Linux.
- [x] **Sidecar Bundling**: Bundle the Elixir release inside the Tauri app for zero-dependency installs.
- [ ] **System Tray & Notifications**: Background build progress, site health alerts, and update notifications.

## Phase 5: Enterprise & Global 🌍
- [ ] **Multi-language Support (i18n)**: localized admin UI and native support for multi-lingual site generation.
- [ ] **Scheduled Publishing**: Local worker to auto-build/deploy at specific times (even when the app is in the tray).
- [ ] **Access Control**: Simple password protection and role-based views for the local admin UI.

## Phase 6: AI Co-Pilot & Automation 🤖
- [ ] **Magic Writer V2**: Full article drafting based on outlines, auto-completion, and tone adjustment.
- [ ] **AI Asset Generation**: Integrated DALL-E/Imagen support for generating featured images from the editor.
- [ ] **Auto-SEO & Tagging**: AI-driven categorization and internal linking suggestions.

## Phase 7: Collaboration & Sync 🔄
- [ ] **Conflict-Free Sync (CRDT)**: Use CRDTs for resolving changes between multiple local instances.
- [ ] **P2P Collaboration**: Optional peer-to-peer syncing for small teams working without a centralized database.
- [ ] **Remote Data Source**: Connect ElixirCMS to a remote PostgreSQL/SQLite DB for hybrid workflows.

## Phase 8: The Global Marketplace 🏪
- [ ] **Verified Theme Store**: Cloud-synced marketplace with verified, one-click install themes.
- [ ] **Plugin Registry**: A community-driven registry for build hooks and UI extensions.
- [ ] **Premium Monetization**: Hooks for premium themes/plugins with built-in licensing checks.

---

*Last Updated: 2026-01-11*
