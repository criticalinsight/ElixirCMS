# ElixirCMS

**The Localhost-First Static Site CMS.**

ElixirCMS is a powerful desktop-class CMS built with Elixir and Phoenix. It brings the power of static site generation to your local machine with a modern, multisite dashboard.

## ✨ Features

*   **Multisite Management**: Create and manage unlimited independent sites from a single dashboard.
*   **Static Site Generation**: Blazing fast builds using EEx templates.
*   **Cloudflare Pages Deployment**: One-click deployment to the edge using `wrangler`.
*   **Magic Writer AI**: Integrated Google Gemini AI for auto-generating SEO titles and meta descriptions.
*   **Theming Engine**: Switch themes instantly. Includes the built-in "Maer" (Haiku) theme.
*   **Media Library**: Site-scoped drag-and-drop media management.
*   **Plugin Hooks**: Extend your build pipeline with `pre_build` and `post_build` shell hooks.

## 🚀 Getting Started

### Prerequisites
*   **Elixir**: 1.15+
*   **Node.js**: required for Cloudflare deployment (`npx`) and asset processing.

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-repo/publii_ex.git
    cd publii_ex
    ```

2.  Install dependencies:
    ```bash
    mix setup
    ```

3.  Start the server:
    ```bash
    mix phx.server
    ```

Visit [`localhost:4000`](http://localhost:4000) to access the dashboard.

## 📦 Deployment

### Cloudflare Pages (Recommended)
1.  Go to **Settings** for your site.
2.  Select **Cloudflare Pages**.
3.  Enter your **Account ID**, **API Token** (with Pages:Edit permissions), and **Project Name**.
4.  Click **Deploy to Cloudflare** from the site overview.

### Custom Hooks
You can define custom shell commands to run before or after the build process in the **Plugins** tab.
