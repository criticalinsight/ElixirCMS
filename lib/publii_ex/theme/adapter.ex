defmodule PubliiEx.Theme.Adapter do
  @moduledoc """
  Normalizes Publii-Ex internal structs into generic maps for use in different template engines
  (EEx, Liquid, etc.), ensuring compatibility with marketplace theme expectations.
  """

  def normalize(data) when is_map(data) do
    data
    |> convert_structs()
    |> stringify_keys()
    |> add_helpers()
  end

  defp convert_structs(data) do
    cond do
      is_struct(data, PubliiEx.Post) ->
        html_content = render_markdown(data.content_md || "")

        data
        |> Map.from_struct()
        |> Map.put(:url, "#{data.slug}/index.html")
        # Ghost/Jekyll style relative link
        |> Map.put(:link, "../#{data.slug}/index.html")
        |> Map.put(:is_post, true)
        # Ghost Aliases
        |> Map.put(:html, html_content)
        |> Map.put(:feature_image, data.featured_image)
        # Jekyll Aliases
        |> Map.put(:content, html_content)
        |> Map.put(:excerpt, data.excerpt || String.slice(data.content_md || "", 0, 160))
        # Keep published_at as struct for EEx
        |> Map.put(:date, format_date(data.published_at))

      is_struct(data, PubliiEx.Page) ->
        data
        |> Map.from_struct()
        |> Map.put(:url, "#{data.slug}/index.html")
        |> Map.put(:is_page, true)

      is_struct(data, PubliiEx.SiteConfig) ->
        # Standardize SiteConfig for themes
        data
        |> Map.from_struct()
        |> Map.put(:navigation, data.navigation || [])
        |> Map.put(:config, data.theme_config || %{})
        # Ghost style @config alias (renamed to _config for Liquid parser compatibility)
        |> Map.put(:_config, data.theme_config || %{})
        |> convert_structs()

      is_map(data) ->
        # Handle cases where data is a struct but not one we explicitly handled above
        map = if is_struct(data), do: Map.from_struct(data), else: data
        Map.new(map, fn {k, v} -> {k, convert_structs(v)} end)

      is_list(data) ->
        Enum.map(data, &convert_structs/1)

      true ->
        data
    end
  end

  # Liquid/Solid often prefers string keys or specific access patterns
  defp stringify_keys(%DateTime{} = dt), do: dt
  defp stringify_keys(%Date{} = d), do: d

  defp stringify_keys(data) when is_map(data) do
    Map.new(data, fn
      {k, v} when is_atom(k) -> {to_string(k), stringify_keys(v)}
      {k, v} -> {k, stringify_keys(v)}
    end)
  end

  defp stringify_keys(data) when is_list(data), do: Enum.map(data, &stringify_keys/1)
  defp stringify_keys(data), do: data

  defp add_helpers(map) do
    # 1. Determine context flags
    is_home = map["page_title"] == "Home"
    is_post = Map.has_key?(map, "post")
    is_page = Map.has_key?(map, "page")

    # 2. Derive body class
    body_class =
      cond do
        is_home -> "home-template"
        is_post -> "post-template"
        is_page -> "page-template"
        true -> ""
      end

    # Support both site as a struct and site as a map containing a config struct
    site_nav = map["site"]["navigation"] || get_in(map, ["site", "config", "navigation"])
    site_config = map["site"]["_config"] || get_in(map, ["site", "config", "_config"]) || %{}

    map
    |> Map.put("is_home", is_home)
    |> Map.put("body_class", body_class)
    |> Map.put("navigation", site_nav || [])
    |> Map.put("_config", site_config)
    |> Map.put("theme", %{"config" => site_config})
    |> Map.put_new("pagination", %{"prev" => nil, "next" => nil, "page" => 1, "total" => 1})
  end

  defp format_date(nil), do: ""
  defp format_date(date), do: Calendar.strftime(date, "%B %d, %Y")

  # Handle MDEx.to_html returning {:ok, html} in newer versions
  defp render_markdown(nil), do: ""
  defp render_markdown(""), do: ""

  defp render_markdown(md) when is_binary(md) do
    case MDEx.to_html(md) do
      {:ok, html} -> html
      html when is_binary(html) -> html
      _ -> ""
    end
  end
end
