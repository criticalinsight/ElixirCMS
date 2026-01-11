# Magic Writer AI

Publii-Ex integrates with Google's Gemini API to provide "Magic Writer" capabilities, specifically focused on automating SEO optimization for your posts.

## Overview

The Magic Writer feature analyzes your post content and automatically generates:
- **SEO Title**: A concise, engaging title optimized for search engines (max 60 chars).
- **Meta Description**: A compelling summary ensuring high click-through rates (max 160 chars).

## Content Analysis

When you trigger the Magic Writer (e.g., via the "Generate SEO" button in the post editor), the system:
1.  Extracts the text content of your post.
2.  Sends a prompt to the Google Gemini Pro 1.5 model.
3.  Receives a structured JSON response containing the optimized title and description.
4.  Populates the SEO fields in your post settings.

## Configuration

### Prerequisites
To use Magic Writer, you need a valid Google Gemini API key.

1.  **Get an API Key**: Visit the [Google AI Studio](https://aistudio.google.com/) to create a new API key.
2.  **Set Environment Variable**:
    Set the `GEMINI_API_KEY` environment variable on your system or in your deployment environment.

    ```bash
    export GEMINI_API_KEY="your_api_key_here"
    ```

    Or on Windows (PowerShell):
    ```powershell
    $env:GEMINI_API_KEY="your_api_key_here"
    ```

### Application Config
The application is configured to look for this environment variable in `config/runtime.exs`:

```elixir
config :publii_ex, :gemini_api_key, System.get_env("GEMINI_API_KEY")
```

## Usage

1.  Navigate to the **Post Editor**.
2.  Write your post content.
3.  Open the **SEO Settings** panel.
4.  Click the **Magic Generate** button.
5.  Review and accept the generated suggestions.

## Troubleshooting

### "Gemini API key not found"
If the key is missing or invalid, the system will fall back to **Mock Mode**. It will generate placeholder data ("Optimized Title for...") to demonstrate functionality without calling the API. Check your environment variables and restart the application.

### Request Failures
Check the logs (`logs/` or console output) for detailed error messages from the Gemini API. Common issues include quota limits or connectivity problems.
