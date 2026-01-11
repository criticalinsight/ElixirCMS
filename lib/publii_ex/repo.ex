defmodule PubliiEx.Repo do
  @moduledoc """
  A wrapper around CubDB for Publii-Ex data persistence.
  """

  @db_name PubliiEx.CubDB

  def get(key) do
    CubDB.get(@db_name, key)
  end

  def put(key, value) do
    CubDB.put(@db_name, key, value)
  end

  def delete(key) do
    CubDB.delete(@db_name, key)
  end

  def all_posts_stream do
    CubDB.select(@db_name, min_key: "post:", max_key: "post:\xFF")
  end

  def get_post(id), do: get("post:#{id}")

  def save_post(%PubliiEx.Post{id: id} = post) do
    put("post:#{id}", post)
  end

  def delete_post(id), do: delete("post:#{id}")

  def all_pages_stream do
    CubDB.select(@db_name, min_key: "page:", max_key: "page:\xFF")
  end

  def get_page(id), do: get("page:#{id}")

  def save_page(%PubliiEx.Page{id: id} = page) do
    put("page:#{id}", page)
  end

  def delete_page(id), do: delete("page:#{id}")

  def get_config, do: get("site_config")

  def save_config(%PubliiEx.SiteConfig{} = config) do
    put("site_config", config)
  end

  def clear_all_posts do
    all_posts_stream()
    |> Enum.each(fn {key, _} -> delete(key) end)
  end

  def clear_all_pages do
    all_pages_stream()
    |> Enum.each(fn {key, _} -> delete(key) end)
  end

  def clear_all do
    clear_all_posts()
    clear_all_pages()
  end

  # === Site Functions (Multisite) ===
  # Use "sites:" prefix (with 's') to avoid overlap with "site:{id}:post:" keys
  def list_sites do
    CubDB.select(@db_name, min_key: "sites:", max_key: "sites:\xFF")
    |> Enum.map(fn {_key, site} -> site end)
    |> Enum.filter(fn item -> is_struct(item, PubliiEx.Site) end)
  end

  def get_site(id), do: get("sites:#{id}")

  def get_site!(id) do
    case get("sites:#{id}") do
      nil -> raise "Site not found: #{id}"
      site -> site
    end
  end

  def save_site(%PubliiEx.Site{id: id} = site) do
    put("sites:#{id}", site)
  end

  def delete_site(id), do: delete("sites:#{id}")

  # Site-scoped posts
  def list_posts_for_site(site_id) do
    CubDB.select(@db_name, min_key: "site:#{site_id}:post:", max_key: "site:#{site_id}:post:\xFF")
    |> Enum.map(fn {_key, post} -> post end)
  end

  def save_post_for_site(site_id, %PubliiEx.Post{id: post_id} = post) do
    put("site:#{site_id}:post:#{post_id}", post)
  end

  def get_post_for_site(site_id, post_id), do: get("site:#{site_id}:post:#{post_id}")

  def delete_post_for_site(site_id, post_id), do: delete("site:#{site_id}:post:#{post_id}")

  # Site-scoped pages
  def list_pages_for_site(site_id) do
    CubDB.select(@db_name, min_key: "site:#{site_id}:page:", max_key: "site:#{site_id}:page:\xFF")
    |> Enum.map(fn {_key, page} -> page end)
  end

  def save_page_for_site(site_id, %PubliiEx.Page{id: page_id} = page) do
    put("site:#{site_id}:page:#{page_id}", page)
  end

  def get_page_for_site(site_id, page_id), do: get("site:#{site_id}:page:#{page_id}")

  def delete_page_for_site(site_id, page_id), do: delete("site:#{site_id}:page:#{page_id}")
end
