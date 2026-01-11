# Static Pages vs. Posts

Publii-Ex distinguishes between chronological blog posts and evergreen static pages.

## Posts (Blog)
- **Nature:** High frequency, date-ordered.
- **URL Structure:** `example.com/slug/index.html` (organized chronologically in the Index).
- **Features:** Supports Featured Images, Excerpts, and Tags.

## Static Pages
- **Nature:** Permanent content like "About", "Privacy Policy", or "Contact".
- **URL Structure:** `example.com/slug/index.html` (rendered at the root level).
- **Navigation:** Pages must be manually linked in your theme's navigation (usually in `layout.html.eex`).

## Management
You can toggle the status between **Draft** and **Published** for both types. Only Published items will be included in the final static site generation. Static Pages can be managed via the "Pages" link in the CMS header.
