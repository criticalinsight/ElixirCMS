# ElixirCMS

**The Localhost-First Static Site CMS.**

ElixirCMS is a powerful desktop-class CMS built with Elixir and Phoenix. It brings the power of static site generation to your local machine with a modern, multisite dashboard.

## ✨ Features

*   **Visual Block Editor**: Modern, drag-and-drop editing experience using **Editor.js**. Supports Headers, Lists, Images, Quotes, and more with instant JSON-to-HTML rendering.
*   **Multisite Management**: Create and manage unlimited independent sites from a single dashboard.
*   **Static Site Generation**: Blazing fast builds using EEx templates with prioritized content rendering.
*   **Search Integration**: Automatically generates `search.json` and integrates **Pagefind** for instant static search.
*   **Magic Writer AI**: Integrated Google Gemini AI for auto-generating SEO titles and meta descriptions.
*   **Ecosystem & Plugins**: A robust hook-based plugin system for content transformation and custom UI injection.
*   **Native Desktop (Tauri)**: Run ElixirCMS as a native desktop application on Windows, macOS, and Linux.
*   **Media Library**: Site-scoped drag-and-drop media management.

## 🎨 Available Themes

ElixirCMS comes with a suite of premium, highly-polished themes. You can preview them live on our [GitHub Pages site](https://criticalinsight.github.io/ElixirCMS/).

| Theme | Aesthetic | Preview |
| :--- | :--- | :--- |
| **Lime** | Corporate, Tech, Electric Lime | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/lime/) |
| **Museum** | Eclectic, Peach & Black, Playful | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/museum/) |
| **Ordinary** | Brutalist, Stark B&W, Raw | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/ordinary/) |
| **Humane** | Warm Serif, Contemplative | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/humane/) |
| **Sushism** | Avant-Garde, Red/Black, Vertical | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/sushism/) |
| **PostOS** | Editorial, Grid, System Fonts | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/postos/) |
| **Monastery** | Professional, Knowledge Hub | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/monastery/) |
| **Zenith** | Ultra-minimal, Typography Focus | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/zenith/) |
| **Nebula** | Dark Mode, Glassmorphism | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/nebula/) |
| **Kinetic** | High Energy, Brutalist | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/kinetic/) |
| **Maer** | Abstract, Experimental | [Live Demo](https://criticalinsight.github.io/ElixirCMS/themes/maer/) |


## 🚀 Getting Started

### Prerequisites
*   **Elixir**: 1.15+
*   **Rust**: required for Tauri desktop build.
*   **Node.js**: required for asset processing and Editor.js plugins.

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

3.  Start the server (Web Mode):
    ```bash
    mix phx.server
    ```

4.  Start the Desktop App (Dev Mode):
    ```bash
    npm run tauri dev
    ```

Visit [`localhost:4000`](http://localhost:4000) to access the dashboard in web mode.

## 📦 Deployment

### Cloudflare Pages (Recommended)
1.  Go to **Settings** for your site.
2.  Select **Cloudflare Pages**.
3.  Enter your **Account ID**, **API Token** (with Pages:Edit permissions), and **Project Name**.
4.  Click **Deploy to Cloudflare** from the site overview.

### Plugin Architecture
You can extend the build pipeline by implementing hooks in `lib/publii_ex/plugins.ex`. Standard hooks include:
- `pre_build/1`: Run before site generation.
- `post_build/1`: Run after site generation.
- `transform_content/1`: Modify post/page content before rendering.
