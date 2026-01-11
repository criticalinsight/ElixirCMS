defmodule PubliiExWeb.PluginsLive do
  use PubliiExWeb, :live_view

  alias PubliiEx.{Plugins, Repo}
  alias PubliiEx.Plugins
  alias PubliiExWeb.Layouts

  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get_site!(site_id)

    if connected?(socket) do
      # Subscribe to updates if needed
    end

    socket =
      socket
      |> assign(:site, site)
      |> assign(:active_tab, :plugins)
      |> assign(:page_title, "Plugin Marketplace")
      |> refresh_plugins()

    {:ok, socket}
  end

  def handle_event("install", %{"id" => plugin_id}, socket) do
    site_id = socket.assigns.site.id

    case Plugins.install(site_id, plugin_id) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Plugin installed successfully.")
         |> refresh_plugins()}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to install plugin: #{inspect(reason)}")}
    end
  end

  def handle_event("uninstall", %{"id" => plugin_id}, socket) do
    site_id = socket.assigns.site.id

    case Plugins.uninstall(site_id, plugin_id) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Plugin uninstalled.")
         |> refresh_plugins()}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to uninstall: #{inspect(reason)}")}
    end
  end

  defp refresh_plugins(socket) do
    site_id = socket.assigns.site.id
    existing_plugins = Plugins.list_available_plugins()

    # Enrich with installed status
    plugins =
      Enum.map(existing_plugins, fn p ->
        %{
          id: p.id(),
          name: p.name(),
          description: p.description(),
          installed: Plugins.is_installed?(site_id, p.id())
        }
      end)

    assign(socket, :plugins, plugins)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <!-- Site Header -->
      <div class="bg-slate-800/50 border-b border-slate-700/50 px-6 py-4">
        <div class="flex items-center gap-4">
          <a href="/" class="text-slate-400 hover:text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
          </a>
          <div>
            <h1 class="text-xl font-bold text-white"><%= @site.name %></h1>
            <p class="text-sm text-slate-400"><%= @site.base_url || "No URL configured" %></p>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="border-b border-slate-700/50 bg-slate-800/30">
        <nav class="flex gap-1 px-6 overflow-x-auto">
          <.nav_tab href={~p"/sites/#{@site.id}"} active={@active_tab == :overview} label="Overview" />
          <.nav_tab href={~p"/sites/#{@site.id}/posts"} active={@active_tab == :posts} label="Posts" />
          <.nav_tab href={~p"/sites/#{@site.id}/pages"} active={@active_tab == :pages} label="Pages" />
          <.nav_tab href={~p"/sites/#{@site.id}/media"} active={@active_tab == :media} label="Media" />
          <.nav_tab href={~p"/sites/#{@site.id}/theme"} active={@active_tab == :theme} label="Theme" />
          <.nav_tab href={~p"/sites/#{@site.id}/plugins"} active={@active_tab == :plugins} label="Plugins" />
          <.nav_tab href={~p"/sites/#{@site.id}/settings"} active={@active_tab == :settings} label="Settings" />
        </nav>
      </div>

      <!-- Content Area -->
      <div class="p-6 md:p-10">
        <div class="mb-8">
          <h1 class="text-2xl font-bold text-white mb-2">Plugin Marketplace</h1>
          <p class="text-slate-400">Extend your site with one-click functionalities.</p>
        </div>

        <div class="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
          <%= for plugin <- @plugins do %>
            <div class="relative flex flex-col justify-between p-6 bg-slate-800/50 border border-slate-700/50 rounded-xl hover:border-slate-600 transition-colors">
              <div>
                <div class="flex items-center justify-between mb-2">
                  <div class="flex items-center gap-3">
                    <div class="p-2 bg-indigo-500/20 text-indigo-400 rounded-lg">
                      <Heroicons.puzzle_piece solid class="w-6 h-6" />
                    </div>
                    <h3 class="font-semibold text-lg text-white"><%= plugin.name %></h3>
                  </div>
                  <%= if plugin.installed do %>
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-500/20 text-green-400 border border-green-500/30">
                      Installed
                    </span>
                  <% end %>
                </div>

                <p class="text-sm text-slate-400 mt-2 mb-6 min-h-[40px]">
                  <%= plugin.description %>
                </p>
              </div>

              <div class="flex items-center justify-between pt-4 border-t border-slate-700/50">
                <%= if plugin.installed do %>
                  <button
                    phx-click="uninstall"
                    phx-value-id={plugin.id}
                    data-confirm="Are you sure you want to uninstall this plugin? Settings may be lost."
                    class="text-sm text-red-400 hover:text-red-300 font-medium transition-colors"
                  >
                    Uninstall
                  </button>
                  <button class="px-3 py-1.5 text-sm font-medium text-slate-300 bg-slate-700 rounded-lg hover:bg-slate-600 transition-colors">
                    Settings
                  </button>
                <% else %>
                  <button
                    phx-click="install"
                    phx-value-id={plugin.id}
                    class="w-full px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-500 shadow-lg shadow-indigo-500/20 transition-all hover:scale-[1.02]"
                  >
                    Install Plugin
                  </button>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp nav_tab(assigns) do
    ~H"""
    <a href={@href} class={"px-4 py-3 text-sm font-medium border-b-2 transition-colors #{if @active, do: "border-indigo-500 text-white", else: "border-transparent text-slate-400 hover:text-white"}"}>
      <%= @label %>
    </a>
    """
  end
end
