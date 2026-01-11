# Search Integration: Pagefind

Publii-Ex uses **Pagefind**, a powerful static search library that runs entirely in the browser without a backend server.

## How it Works
1. **During Build:** After the HTML files are generated, the `Generator` module executes the `pagefind` binary.
2. **Indexing:** Pagefind crawls the `/output` directory and builds a compressed search index.
3. **Deployment:** The index (located in `_pagefind/`) is uploaded along with your site.

## Theme Integration
To use search in a custom theme, you need:
- **CSS:** `<link href="/_pagefind/pagefind-ui.css" rel="stylesheet">`
- **JS:** `<script src="/_pagefind/pagefind-ui.js"></script>`
- **Initialization:**
  ```javascript
  new PagefindUI({ element: "#search", showSubResults: true });
  ```

## Performance
Pagefind is incredibly efficient. A site with hundreds of pages will typically have an index of only a few hundred kilobytes, and search results are nearly instantaneous.
