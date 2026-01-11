defmodule PubliiEx.Generator do
  alias PubliiEx.Plugins
  alias PubliiEx.Repo
  alias PubliiEx.Slug

  require Logger

  @output_dir "output"

  def build(site_id, explicit_posts \\ nil) do
    Logger.info("Starting site build for #{site_id}...")

    site = Repo.get_site(site_id)
    unless site, do: raise("Site not found: #{site_id}")

    output_dir = Path.join(@output_dir, "sites/#{site_id}")

    # 1. Clean/Create output dir
    File.rm_rf!(output_dir)
    File.mkdir_p!(output_dir)

    # 2. Fetch data (Site-Scoping)
    config = site.settings["theme_config"] || %{}
    posts = explicit_posts || list_published_posts(site_id)
    pages = list_published_pages(site_id)

    theme_name = site.theme || "maer"
    theme_path = Path.join(["priv", "themes", theme_name])
    theme_config = load_theme_config(theme_path, config)

    # Standard assigns for all templates
    base_assigns = %{
      site: %{
        title: site.name,
        url: site.base_url || "http://localhost:4000/sites/#{site_id}/",
        config: config,
        settings: site.settings
      },
      theme: theme_config
    }

    # 3. Render Home
    render_theme_file(
      site_id,
      "index",
      Path.join(output_dir, "index.html"),
      theme_path,
      Map.merge(base_assigns, %{posts: posts, page_title: "Home", relative_path: ""})
    )

    # 4. Render Posts
    Logger.info("Rendering #{length(posts)} posts...")

    for post <- posts do
      post_dir = Path.join(output_dir, post.slug)
      File.mkdir_p!(post_dir)

      # TRANSFORM: Run plugin content pipeline
      transformed = Plugins.transform_content(site_id, post.content, %{type: :post, id: post.id})
      post_with_transform = %{post | content: transformed}

      render_theme_file(
        site_id,
        "post",
        Path.join(post_dir, "index.html"),
        theme_path,
        Map.merge(base_assigns, %{
          post: post_with_transform,
          page_title: post.title,
          relative_path: "../"
        })
      )
    end

    # 4b. Render Pages
    for page <- pages do
      page_dir = Path.join(output_dir, page.slug)
      File.mkdir_p!(page_dir)

      render_theme_file(
        site_id,
        "page",
        Path.join(page_dir, "index.html"),
        theme_path,
        Map.merge(base_assigns, %{page: page, page_title: page.title, relative_path: "../"})
      )
    end

    # 5. Render Tags
    tags_map = group_posts_by_tag(posts)
    tags_dir = Path.join(output_dir, "tags")
    File.mkdir_p!(tags_dir)

    for {tag, tag_posts} <- tags_map do
      tag_slug = Slug.slugify(tag)
      tag_page_dir = Path.join(tags_dir, tag_slug)
      File.mkdir_p!(tag_page_dir)

      render_theme_file(
        site_id,
        "tag",
        Path.join(tag_page_dir, "index.html"),
        theme_path,
        Map.merge(base_assigns, %{
          posts: tag_posts,
          tag: tag,
          page_title: "Posts tagged with #{tag}",
          relative_path: "../../"
        })
      )
    end

    # 6. Generate RSS & Sitemap
    generate_rss(site, posts, output_dir)
    generate_sitemap(site, posts, output_dir)
    generate_search_index(site, posts, output_dir)

    # 7. Asset Copying
    theme_assets = Path.join(theme_path, "assets")

    if File.exists?(theme_assets) do
      File.cp_r!(theme_assets, Path.join(output_dir, "assets"))
    end

    # Site specific uploads
    uploads_src = Path.join(["priv", "static", "uploads", "sites", "#{site_id}"])

    if File.exists?(uploads_src) do
      File.mkdir_p!(Path.join(output_dir, "uploads"))
      File.cp_r!(uploads_src, Path.join(output_dir, "uploads"))
    end

    # 8. Pagefind Indexing
    run_pagefind(output_dir)

    Logger.info("Site build complete. Output in /#{output_dir}")
    {:ok, output_dir}
  end

  defp load_theme_config(theme_path, user_config) do
    json_path = Path.join(theme_path, "theme.json")

    defaults =
      if File.exists?(json_path) do
        File.read!(json_path) |> Jason.decode!()
      else
        %{"name" => Path.basename(theme_path), "config" => %{}}
      end

    # Merge user_config (from site settings) into defaults["config"]
    updated_inner_config = Map.merge(defaults["config"] || %{}, user_config || %{})
    Map.put(defaults, "config", updated_inner_config)
  end

  defp run_pagefind(output_dir) do
    Logger.info("Running Pagefind indexer...")

    bin_path =
      if :os.type() == {:win32, :nt} do
        Path.join([Application.app_dir(:publii_ex), "priv", "bin", "pagefind.exe"])
      else
        "pagefind"
      end

    if File.exists?(bin_path) do
      # Run in a separate task or await
      case System.cmd(bin_path, ["--site", output_dir]) do
        {output, 0} ->
          Logger.info("Pagefind indexed successfully: #{output}")

        {error, code} ->
          Logger.error("Pagefind failed (code #{code}): #{error}")
      end
    else
      Logger.warning("Pagefind binary not found at #{bin_path}. Skipping indexing.")
    end
  end

  defp list_published_posts(site_id) do
    Repo.list_posts_for_site(site_id)
    |> Enum.filter(&(&1.status == :published))
    |> Enum.map(&ensure_content/1)
    |> Enum.sort_by(
      fn post -> post.published_at || ~U[1970-01-01 00:00:00Z] end,
      {:desc, DateTime}
    )
  end

  defp list_published_pages(site_id) do
    Repo.list_pages_for_site(site_id)
    |> Enum.filter(&(&1.status == :published))
    |> Enum.map(&ensure_content/1)
    |> Enum.sort_by(& &1.title)
  end

  defp ensure_content(item) do
    content =
      if item.content_delta && Map.get(item.content_delta, "blocks") &&
           length(Map.get(item.content_delta, "blocks")) > 0 do
        PubliiEx.Editor.to_html(item.content_delta)
      else
        MDEx.to_html(item.content_md || "")
      end

    %{item | content: content}
  end

  defp group_posts_by_tag(posts) do
    Enum.reduce(posts, %{}, fn post, acc ->
      Enum.reduce(post.tags || [], acc, fn tag, tag_acc ->
        Map.update(tag_acc, tag, [post], &[post | &1])
      end)
    end)
  end

  defp generate_rss(site, posts, output_dir) do
    base_url = site.base_url || "http://localhost:4000/sites/#{site.id}/"
    base_url = if String.ends_with?(base_url, "/"), do: base_url, else: base_url <> "/"

    items =
      for post <- Enum.take(posts, 20) do
        """
        <item>
          <title>#{post.title}</title>
          <link>#{base_url}#{post.slug}/index.html</link>
          <pubDate>#{Calendar.strftime(post.published_at, "%a, %d %b %Y %H:%M:%S GMT")}</pubDate>
          <description>#{post.excerpt || ""}</description>
          <guid>#{base_url}#{post.slug}/index.html</guid>
        </item>
        """
      end

    rss = """
    <?xml version="1.0" encoding="UTF-8" ?>
    <rss version="2.0">
    <channel>
      <title>#{site.name}</title>
      <link>#{base_url}</link>
      <description>Latest posts from #{site.name}</description>
      #{Enum.join(items, "\n")}
    </channel>
    </rss>
    """

    File.write!(Path.join(output_dir, "feed.xml"), rss)
  end

  defp generate_sitemap(site, posts, output_dir) do
    base_url = site.base_url || "http://localhost:4000/sites/#{site.id}/"
    base_url = if String.ends_with?(base_url, "/"), do: base_url, else: base_url <> "/"

    urls =
      for post <- posts do
        """
        <url>
          <loc>#{base_url}#{post.slug}/index.html</loc>
          <lastmod>#{Calendar.strftime(post.published_at, "%Y-%m-%d")}</lastmod>
        </url>
        """
      end

    sitemap = """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url>
        <loc>#{base_url}index.html</loc>
        <priority>1.0</priority>
      </url>
      #{Enum.join(urls, "\n")}
    </urlset>
    """

    File.write!(Path.join(output_dir, "sitemap.xml"), sitemap)
  end

  defp generate_search_index(site, posts, output_dir) do
    base_url = site.base_url || "/"
    base_url = if String.ends_with?(base_url, "/"), do: base_url, else: base_url <> "/"

    search_data =
      Enum.map(posts, fn post ->
        %{
          title: post.title,
          url: "#{base_url}#{post.slug}/index.html",
          excerpt: post.excerpt || "",
          date: Calendar.strftime(post.published_at, "%Y-%m-%d"),
          tags: post.tags || []
        }
      end)

    File.write!(Path.join(output_dir, "search.json"), Jason.encode!(search_data))
  end

  defp render_theme_file(site_id, template_base, dest_path, theme_path, assigns) do
    # 1. Normalize assigns for cross-engine compatibility
    normalized_assigns = PubliiEx.Theme.Adapter.normalize(assigns)

    # 2. Inject partial helper
    partial_helper = fn name, partial_assigns ->
      p_path = find_template(theme_path, name)
      # Merge partial assigns with base normalized assigns
      merged = Map.merge(normalized_assigns, PubliiEx.Theme.Adapter.normalize(partial_assigns))
      render_engine(p_path, merged, theme_path)
    end

    # For EEx, we add it to assigns. For Liquid, we rely on Solid's includes or custom tags.
    final_assigns = Map.put(normalized_assigns, "render_partial", partial_helper)

    # 3. Find template and layout
    template_path = find_template(theme_path, template_base)
    layout_path = find_layout(theme_path)

    # 4. Render inner content
    inner_content = render_engine(template_path, final_assigns, theme_path)

    # 5. Wrap in layout
    layout_assigns = Map.put(final_assigns, "inner_content", inner_content)
    final_content = render_engine(layout_path, layout_assigns, theme_path)

    # 6. Inject Plugin Hooks (Head and Body)
    head_injection = PubliiEx.Plugins.run_hooks(site_id, :head, final_assigns)
    body_injection = PubliiEx.Plugins.run_hooks(site_id, :body, final_assigns)

    final_content =
      final_content
      |> String.replace("</head>", "#{head_injection}\n</head>")
      |> String.replace("</body>", "#{body_injection}\n</body>")

    File.write!(dest_path, final_content)
  end

  defp find_layout(theme_path) do
    candidates = [
      Path.join(theme_path, "layout.html.eex"),
      Path.join(theme_path, "layout.liquid"),
      Path.join(theme_path, "layout.html"),
      Path.join(theme_path, "default.hbs"),
      Path.join(theme_path, "default.handlebars"),
      Path.join([theme_path, "_layouts", "default.liquid"]),
      Path.join([theme_path, "_layouts", "default.html"]),
      Path.join([theme_path, "_layouts", "layout.liquid"]),
      Path.join([theme_path, "_layouts", "layout.html"]),
      Path.join([theme_path, "partials", "layout.hbs"])
    ]

    found = Enum.find(candidates, &File.exists?/1)

    if found do
      found
    else
      # If no layout, return a dummy path or fallback
      # For now, we'll try to find ANY file in _layouts or root
      case File.ls(Path.join(theme_path, "_layouts")) do
        {:ok, [first | _]} ->
          Path.join([theme_path, "_layouts", first])

        _ ->
          # Try root .hbs or .liquid
          root_files = File.ls!(theme_path)

          Enum.find(root_files, fn f -> f in ["default.hbs", "layout.liquid", "index.hbs"] end)
          |> case do
            nil -> Path.join(theme_path, "layout.liquid")
            f -> Path.join(theme_path, f)
          end
      end
    end
  end

  defp find_template(theme_path, base_name) do
    # Try common extensions
    extensions = [".liquid", ".html", ".hbs", ".handlebars", ".html.eex"]

    candidates = Enum.map(extensions, &Path.join(theme_path, base_name <> &1))

    found = Enum.find(candidates, &File.exists?/1)

    if found do
      found
    else
      # Maybe it's in a subdirectory?
      subdirs = ["_layouts", "partials", "_includes"]

      Enum.find_value(subdirs, fn dir ->
        dir_path = Path.join(theme_path, dir)

        if File.dir?(dir_path) do
          Enum.find_value(extensions, fn ext ->
            p = Path.join(dir_path, base_name <> ext)
            if File.exists?(p), do: p
          end)
        end
      end) || raise "Template not found: #{base_name} in #{theme_path}"
    end
  end

  defp render_engine(path, assigns, theme_path) do
    Logger.debug("Rendering file: #{path}")
    ext = Path.extname(path)

    case ext do
      ext when ext in [".hbs", ".handlebars"] ->
        # Handlebars/Mustache support via HandlebarsAdapter
        content = File.read!(path)

        # Pre-load partials from theme directory
        partial_dirs = [
          Path.join(theme_path, "partials"),
          Path.join(theme_path, "_includes")
        ]

        partials =
          Enum.reduce(partial_dirs, %{}, fn dir, acc ->
            if File.dir?(dir) do
              File.ls!(dir)
              |> Enum.filter(&String.ends_with?(&1, [".hbs", ".handlebars", ".html"]))
              |> Enum.reduce(acc, fn file, inner_acc ->
                name = Path.basename(file, Path.extname(file))
                Map.put(inner_acc, name, File.read!(Path.join(dir, file)))
              end)
            else
              acc
            end
          end)

        PubliiEx.Theme.HandlebarsAdapter.render(content, assigns, partials)

      ".eex" ->
        # EEx prefers atom keys for assigns.
        atom_assigns =
          Map.new(assigns, fn
            {k, v} when is_binary(k) -> {String.to_atom(k), v}
            {k, v} -> {k, v}
          end)
          |> Map.to_list()

        # Add raw/1 helper for Phoenix-style templates
        raw_fn = fn content -> content end

        Logger.debug("EEx assigns keys: #{inspect(Keyword.keys(atom_assigns))}")

        EEx.eval_file(path, assigns: atom_assigns, raw: raw_fn)

      _ ->
        File.read!(path)
    end
  end
end
