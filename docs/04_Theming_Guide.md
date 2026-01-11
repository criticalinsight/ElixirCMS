# Theming Guide

Publii-Ex uses a filesystem-based theming engine. Themes are located in `priv/themes/`.

## Anatomy of a Theme
A theme folder (e.g., `default/`) must contain:
- `layout.html.eex`: The wrapper for all pages.
- `index.html.eex`: The home page template.
- `post.html.eex`: The template for individual blog posts.
- `page.html.eex`: The template for static pages.
- `tag.html.eex`: The template for tag archive pages.
- `assets/`: A folder for CSS, JS, and images used by the theme.

## Template Variables
Every template receives:
- `@site_config`: Global site settings (URL, theme name, etc).
- `@relative_path`: A string (e.g., `../`) to help resolve asset paths correctly regardless of URL depth.

### Post Template
- `@post`: The current Post struct.

### Page Template
- `@page`: The current Page struct.

### Index/Tag Templates
- `@posts`: A list of post structs to display.

## Customization
You can use the built-in **Theme Editor** in the CMS dashboard to modify these files in real-time. Changes are applied immediately upon the next site build.
