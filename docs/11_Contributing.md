# Contributing to Publii-Ex

We welcome contributions to make Publii-Ex the best desktop CMS for the Elixir community.

## Development Workflow
1. **Fork** the repository.
2. Create a **Feature Branch**.
3. Run tests to ensure no regressions:
   ```bash
   mix test
   ```
4. Follow the **Code Style**:
   - Use `mix format` before committing.
   - Prefer LiveView for all CMS interactions.
   - Keep the "Localhost Monolith" philosophy in mind (minimal external dependencies).

## Bug Reports
If you find a bug, please open an issue with:
1. Steps to reproduce.
2. Expected vs. Actual behavior.
3. Your OS and Elixir version.

## Roadmap
- Multi-language support (i18n).
- Plugin system for custom Generator steps.
- Native desktop window wrapper using Webview.
