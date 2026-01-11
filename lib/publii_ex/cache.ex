defmodule PubliiEx.Cache do
  @moduledoc """
  Handles caching of pre-parsed templates and metadata to speed up site generation.
  Uses CubDB (via Repo) for persistence.
  """
  alias PubliiEx.Repo

  @doc "Get a cached template AST for a theme and template name."
  def get_template(theme_name, template_base) do
    Repo.get("cache:template:#{theme_name}:#{template_base}")
  end

  @doc "Store a pre-parsed template AST."
  def put_template(theme_name, template_base, ast) do
    Repo.put("cache:template:#{theme_name}:#{template_base}", ast)
  end

  @doc "Get cached metadata/posts for a site."
  def get_meta(site_id, key) do
    Repo.get("cache:meta:#{site_id}:#{key}")
  end

  @doc "Store metadata/posts for a site."
  def put_meta(site_id, key, value) do
    Repo.put("cache:meta:#{site_id}:#{key}", value)
  end

  @doc "Invalidate cache for a specific site or theme."
  def invalidate_theme_cache(theme_name) do
    # This is a bit brute force with CubDB but works for local dev
    PubliiEx.CubDB
    |> CubDB.select(
      min_key: "cache:template:#{theme_name}:",
      max_key: "cache:template:#{theme_name}:\xFF"
    )
    |> Enum.each(fn {key, _} -> Repo.delete(key) end)
  end

  def invalidate_site_cache(site_id) do
    PubliiEx.CubDB
    |> CubDB.select(min_key: "cache:meta:#{site_id}:", max_key: "cache:meta:#{site_id}:\xFF")
    |> Enum.each(fn {key, _} -> Repo.delete(key) end)
  end

  @doc "Warm up the cache for a site by pre-rendering its content."
  def warm_up(site_id) do
    # Simply listing posts and running ensure_content will populate the cache
    PubliiEx.Generator.list_published_posts(site_id)
    PubliiEx.Generator.list_published_pages(site_id)
    :ok
  end
end
