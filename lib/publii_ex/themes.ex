defmodule PubliiEx.Themes do
  @moduledoc """
  Context for managing themes, discovering them on disk, and safely loading metadata.
  """

  require Logger

  @themes_dir Path.join(:code.priv_dir(:publii_ex), "themes")

  @doc """
  Lists all available themes that differ from the legacy Jekyll themes structure
  (i.e. must have index.html.eex).
  Returns a list of maps with ID, name, description, preview_url, etc.
  """
  def list_themes do
    if File.exists?(@themes_dir) do
      File.ls!(@themes_dir)
      |> Enum.filter(&is_valid_theme_dir?/1)
      |> Enum.map(&load_theme_metadata/1)
      |> Enum.sort_by(& &1["name"])
    else
      []
    end
  end

  @doc """
  Gets validation logic for theme directory.
  """
  def is_valid_theme_dir?(dir_name) do
    path = Path.join(@themes_dir, dir_name)
    File.dir?(path) and File.exists?(Path.join(path, "index.html.eex"))
  end

  @doc """
  Loads metadata for a specific theme by ID (folder name).
  Returns a default map if loading fails.
  """
  def load_theme_metadata(theme_id) do
    json_path = Path.join([@themes_dir, theme_id, "theme.json"])

    meta =
      with true <- File.exists?(json_path),
           {:ok, content} <- File.read(json_path),
           {:ok, json} <- Jason.decode(content) do
        json
      else
        {:error, %Jason.DecodeError{} = e} ->
          Logger.error("Failed to decode theme.json for #{theme_id}: #{Exception.message(e)}")
          fallback_meta(theme_id, "Corrupted metadata file")

        params ->
          # Case for file not found or other errors
          # Logger.warning("Could not load theme.json for #{theme_id}: #{inspect(params)}")
          fallback_meta(theme_id)
      end

    Map.put(meta, "id", theme_id)
  end

  @doc """
  Loads the default configuration for a theme safely.
  Returns empty map on error.
  """
  def get_theme_defaults(theme_id) do
    json_path = Path.join([@themes_dir, theme_id, "theme.json"])

    with true <- File.exists?(json_path),
         {:ok, content} <- File.read(json_path),
         {:ok, json} <- Jason.decode(content) do
      Map.get(json, "config", %{})
    else
      _ -> %{}
    end
  end

  defp fallback_meta(id, description \\ "No description available.") do
    %{
      "name" => String.capitalize(id),
      "description" => description,
      "author" => "Unknown"
    }
  end
end
