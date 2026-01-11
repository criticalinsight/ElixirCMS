# Deployment Guide

Publii-Ex is designed to deploy to static hosting providers. Currently, it has built-in support for **GitHub Pages**.

## GitHub Pages Setup
1. **GitHub Token:** Create a Personal Access Token (PAT) with `repo` scope.
2. **Repository:** Ensure you have a repository created (e.g., `username/my-site`).
3. **Settings:** In the Publii-Ex dashboard:
   - Enter your Repository path (`username/repo`).
   - Paste your Token.
   - Set the **Base URL** (e.g., `https://username.github.io/repo/`).

## Deployment Process
When you click **"Deploy to GitHub"**:
1. Publii-Ex triggers a full site build.
2. It initializes a temporary Git repository in the `output/` folder.
3. It force-pushes the content to the `gh-pages` branch of your specified repository.

## Manual Deployment
Since the output is just standard HTML/CSS, you can manually deploy by:
1. Building the site: Click "Build Site".
2. Uploading the contents of the `/output` folder to any host (Netlify, Vercel, S3, etc.).
