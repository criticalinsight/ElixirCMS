defmodule Mix.Tasks.BuildThemePreviews do
  @moduledoc "Generates static HTML previews for all themes in priv/themes"
  use Mix.Task

  def run(_) do
    File.mkdir_p!("docs/themes")

    themes_dir = Path.join(:code.priv_dir(:publii_ex), "themes")

    # Rich Mock Data
    posts = [
      %{
        title: "The Art of Visual Silence",
        slug: "visual-silence",
        excerpt:
          "Minimalism isn't just about white space; it's about the deliberate absence of noise.",
        content: """
          <p class="lead">Minimalism is not about subtraction for the sake of subtraction. It is about subtraction for the sake of focus. When we remove the unnecessary, we are left with the essential.</p>

          <img src="https://images.unsplash.com/photo-1507643179173-61b0453c26d3?auto=format&fit=crop&w=1200&q=80" alt="Minimalist Architecture" style="width:100%; height:auto; border-radius: 8px; margin: 2rem 0;">

          <h2>The Core Principle</h2>
          <p>Design should breathe. Content should stand out. In a world of noise, silence is the loudest sound.</p>

          <blockquote>True elegance is found in the absence of excess. It is the art of saying more with less.</blockquote>

          <p>We often clutter our lives and our designs with things we think we need, but in reality, they only serve to distract us from what truly matters.</p>
        """,
        published_at: DateTime.utc_now()
      },
      %{
        title: "Future of Digital Museums",
        slug: "digital-museums",
        excerpt:
          "How virtual reality and augmented reality are reshaping the way we experience history and culture.",
        content: """
          <p>How virtual reality and augmented reality are reshaping the way we experience history and culture. The screen is no longer a barrier, but a window.</p>

          <div style="aspect-ratio: 16/9; margin: 2rem 0;">
            <iframe width="100%" height="100%" src="https://www.youtube.com/embed/dQw4w9WgXcQ?controls=0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen style="border-radius: 8px;"></iframe>
          </div>

          <h2>Immersion</h2>
          <p>Imagine walking through the Louvre from your living room. Imagine touching the textures of a Van Gogh. Technology is making this possible.</p>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin: 2rem 0;">
             <img src="https://images.unsplash.com/photo-1544531696-fa70bce9a9f4?auto=format&fit=crop&w=600&q=80" style="width:100%; height: auto; border-radius: 4px;">
             <img src="https://images.unsplash.com/photo-1563721348-18511ee90016?auto=format&fit=crop&w=600&q=80" style="width:100%; height: auto; border-radius: 4px;">
          </div>

          <p>But with new technology comes new challenges. How do we preserve the authenticity of the artifact in a digital realm?</p>
        """,
        published_at: DateTime.add(DateTime.utc_now(), -86400)
      },
      %{
        title: "Corporate Synergy Report 2025",
        slug: "corporate-synergy",
        excerpt:
          "Q4 earnings show a marked increase in cross-departmental efficiency and actionable deliverables.",
        content: """
          <p>Q4 earnings show a marked increase in cross-departmental efficiency and actionable deliverables. We are pivoting to a mobile-first strategy.</p>

          <div style="background: #f1f5f9; padding: 2rem; border-radius: 8px; margin: 2rem 0;">
            <h3 style="margin-top:0;">Key Performance Indicators</h3>
            <ul>
              <li><strong>Growth:</strong> +15% Year over Year</li>
              <li><strong>Retention:</strong> 98% (Industry Leading)</li>
              <li><strong>Synergy:</strong> Approaching Maximum Capacity</li>
            </ul>
          </div>

          <p>We must remain agile in this fast-paced market. Our competitors are evolving, and so must we.</p>
        """,
        published_at: DateTime.add(DateTime.utc_now(), -172_800)
      },
      %{
        title: "Neon Nights & Cyber Dreams",
        slug: "neon-nights",
        excerpt:
          "Exploring the aesthetic of cyberpunk in modern web design. Glitch effects, neon colors, and dark modes.",
        content: """
          <p>Exploring the aesthetic of cyberpunk in modern web design. Glitch effects, neon colors, and dark modes are taking over.</p>
          <img src="https://images.unsplash.com/photo-1555680202-c86f0e12f086?auto=format&fit=crop&w=1200&q=80" alt="Cyberpunk City" style="width:100%; height:auto; border-radius: 8px; margin: 2rem 0; filter: contrast(1.2) brightness(1.1);">

          <p>It's distinct. It's bold. It's the future.</p>
        """,
        published_at: DateTime.add(DateTime.utc_now(), -259_200)
      }
    ]

    # Iterate over themes
    File.ls!(themes_dir)
    |> Enum.filter(&File.dir?(Path.join(themes_dir, &1)))
    |> Enum.sort()
    |> Enum.each(fn theme_name ->
      theme_path = Path.join(themes_dir, theme_name)
      index_template_path = Path.join(theme_path, "index.html.eex")
      post_template_path = Path.join(theme_path, "post.html.eex")

      if File.exists?(index_template_path) and File.exists?(post_template_path) do
        Mix.shell().info("Building preview for: #{theme_name}")

        output_dir = "docs/themes/#{theme_name}"
        File.mkdir_p!(output_dir)

        # Copy Assets
        assets_src = Path.join(theme_path, "assets")
        assets_dest = Path.join(output_dir, "assets")

        if File.exists?(assets_src) do
          File.cp_r!(assets_src, assets_dest)
        end

        # Base URL for GitHub Pages
        # https://criticalinsight.github.io/ElixirCMS/themes/<theme_name>/
        site_url = "/ElixirCMS/themes/#{theme_name}/"

        site_data = %{
          title: "Preview: #{String.capitalize(theme_name)}",
          url: site_url
        }

        # compile templates - strip naked raw() calls
        index_template = File.read!(index_template_path) |> String.replace("raw(", "(")
        post_template = File.read!(post_template_path) |> String.replace("raw(", "(")

        # Render Index
        try do
          # FIX: Pass assigns map for @variable support
          bindings = [site: site_data, posts: posts, page_title: "Home"]
          # EEx.eval_string(str, [assigns: bindings]) allows @foo usage
          index_html = EEx.eval_string(index_template, assigns: bindings)
          File.write!(Path.join(output_dir, "index.html"), index_html)
        rescue
          e -> Mix.shell().error("Failed to render index for #{theme_name}: #{inspect(e)}")
        end

        # Render Posts
        Enum.each(posts, fn post ->
          post_dir = Path.join(output_dir, post.slug)
          File.mkdir_p!(post_dir)

          try do
            bindings = [site: site_data, post: post, page_title: post.title]
            post_html = EEx.eval_string(post_template, assigns: bindings)
            File.write!(Path.join(post_dir, "index.html"), post_html)
          rescue
            e ->
              Mix.shell().error(
                "Failed to render post for #{theme_name} / #{post.slug}: #{inspect(e)}"
              )
          end
        end)
      else
        Mix.shell().info("Skipping #{theme_name} (missing templates)")
      end
    end)

    Mix.shell().info("All theme previews generated in docs/themes/")
  end
end
