# Architecture: The Localhost Monolith

Publii-Ex follows the "Localhost Monolith" pattern, where a full-stack web application runs exclusively on the user's local machine to serve as a high-performance, private CMS.

## The Stack
- **Backend:** Elixir / Phoenix (No-DB approach using CubDB).
- **Frontend:** Phoenix LiveView + Tailwind CSS + Salad UI.
- **Persistence:** **CubDB**, a key-value store that saves data to local files, ensuring zero external database dependencies.
- **Generation:** A custom `Generator` module that renders EEx templates into a folder of static HTML files.

## Workflow
1. **Data Entry:** User interacts with LiveView forms to save Posts/Pages to CubDB.
2. **Media:** Images are uploaded to `priv/static/uploads`.
3. **Build:** The `Generator` reads from CubDB, evaluates theme templates, and outputs the site to `/output`.
4. **Publish:** The `Deployer` uses local Git binaries to push the `/output` folder to a remote host.

## Standalone Execution
Using **Burrito**, the entire Erlang runtime and application are bundled into a single binary. This allows Publii-Ex to run on Windows without requiring Elixir to be installed on the host system.
