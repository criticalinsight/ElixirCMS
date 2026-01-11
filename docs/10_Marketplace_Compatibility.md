# Marketplace Compatibility & Roadmap

Publii-Ex's new theming engine is designed to be structurally compatible with the "Golden Standard" for static site and CMS themes.

## Current Compatibility (Architectural)
While Publii-Ex uses **EEx (Embedded Elixir)**, its structural mapping allows for easy porting from:

1. **Ghost (Handlebars):**
   - **Compatibility:** High. Ghost's `post.hbs`, `page.hbs`, and `index.hbs` map 1:1 to our `.html.eex` files.
   - **Status:** Standardized variables like `@site` and `@post` are heavily inspired by Ghost.

2. **Jekyll (Liquid):**
   - **Compatibility:** Medium-High. 구조 (Structure) is very similar.
   - **Status:** Our `Generator` can be easily extended to support a Liquid-to-EEx transpilation or simple manual porting.

3. **Hugo (Go Templates):**
   - **Compatibility:** Medium. Hugo uses complex "Shortcodes" and Go-specific functions.
   - **Status:** Our standard variables handle the structural requirements of Hugo themes.

## Target Marketplace Compatibility
Below are the marketplaces we can target for "Out of the Box" compatibility in the next phase:

### 1. Ghost Content API Marketplace
- **Why:** High-quality, premium designs.
- **Work Required:** Implement a `gscan` compatibility checker (shimming Ghost's JSON spec to ours).

### 2. Jekyll (Theme-gem)
- **Why:** The standard for GitHub Pages.
- **Work Required:** Add a Liquid template engine option to the `Generator` (via an Elixir Liquid wrapper).

### 3. Publii Marketplace (Original Inspiration)
- **Why:** Our project shares the name and philosophy.
- **Work Required:** Mapping Publii's Handlebars/Vue logic to EEx.

### 4. ThemeForest (Static Site Category)
- **Why:** Largest commercial market.
- **Work Required:** Developing a "Universal Theme Converter" CLI tool within Publii-Ex.

## Future Tech Roadmap
- **Partial Support:** `render_partial("header")` helper for nested marketplace themes.
- **Asset Processing:** Automated Minification/PurgeCSS for 100/100 PageSpeed scores.
- **Theme Previews:** Live previewing zip-uploaded themes before activation.
