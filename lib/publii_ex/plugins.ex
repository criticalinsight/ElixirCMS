defmodule PubliiEx.Plugins do
  @moduledoc """
  Context context for managing plugins and their configuration per site.
  """
  alias PubliiEx.Repo

  # Registered Plugins
  @plugins [
    PubliiEx.Plugins.Giscus,
    PubliiEx.Plugins.Snipcart,
    PubliiEx.Plugins.SeoShield,
    PubliiEx.Plugins.PrivacyPulse,
    PubliiEx.Plugins.NewsletterSync,
    PubliiEx.Plugins.GhostHunter,
    PubliiEx.Plugins.PixelPerfect
  ]

  def list_available_plugins do
    @plugins
  end

  def get_plugin_by_id(id) when is_atom(id) do
    Enum.find(@plugins, fn p -> p.id() == id end)
  end

  def get_plugin_by_id(id) when is_binary(id) do
    id_atom = String.to_existing_atom(id)
    get_plugin_by_id(id_atom)
  rescue
    _ -> nil
  end

  # Store just the plugin ID and settings in the DB
  # Key format: site:{site_id}:plugin:{plugin_id} -> config_map

  def list_installed_plugins(site_id) do
    installed_ids = list_installed_plugin_ids(site_id)

    @plugins
    |> Enum.filter(fn p -> p.id() in installed_ids end)
  end

  defp list_installed_plugin_ids(site_id) do
    # We scan keys starting with site:{site_id}:plugin:
    prefix = "site:#{site_id}:plugin:"

    CubDB.select(PubliiEx.CubDB, min_key: prefix, max_key: prefix <> "\xFF")
    |> Enum.map(fn {key, _settings} ->
      # key is "site:{site_id}:plugin:{plugin_id}"
      case String.split(key, ":") do
        ["site", ^site_id, "plugin", plugin_id_str] -> String.to_existing_atom(plugin_id_str)
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  rescue
    _ -> []
  end

  def is_installed?(site_id, plugin_id) do
    case Repo.get(plugin_key(site_id, plugin_id)) do
      nil -> false
      _ -> true
    end
  end

  def get_settings(site_id, plugin_id) do
    Repo.get(plugin_key(site_id, plugin_id)) || %{}
  end

  def install(site_id, plugin_id) do
    plugin = get_plugin_by_id(plugin_id)

    if plugin do
      # Initialize with empty map or default if we had it
      Repo.put(plugin_key(site_id, plugin_id), %{})
      plugin.install(site_id)
    else
      {:error, :not_found}
    end
  end

  def uninstall(site_id, plugin_id) do
    plugin = get_plugin_by_id(plugin_id)

    if plugin do
      Repo.delete(plugin_key(site_id, plugin_id))
      plugin.uninstall(site_id)
      :ok
    else
      {:error, :not_found}
    end
  end

  def save_settings(site_id, plugin_id, settings) when is_map(settings) do
    Repo.put(plugin_key(site_id, plugin_id), settings)
  end

  defp plugin_key(site_id, plugin_id) do
    "site:#{site_id}:plugin:#{plugin_id}"
  end

  def run_hooks(site_id, hook_name, context) do
    list_installed_plugins(site_id)
    |> Enum.map(fn plugin ->
      hooks = plugin.hooks()

      if Map.has_key?(hooks, hook_name) do
        try do
          # Get settings to pass to hook
          settings = get_settings(site_id, plugin.id())
          enhanced_context = Map.put(context, :settings, settings)

          hooks[hook_name].(enhanced_context)
        rescue
          e ->
            # Log error but don't crash build
            require Logger
            Logger.error("Plugin hook failed: #{plugin.name()} - #{hook_name}: #{inspect(e)}")
            ""
        end
      else
        nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end
end
