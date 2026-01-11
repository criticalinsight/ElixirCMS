defmodule PubliiExWeb.ThemeLive.Editor do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      themes = list_available_themes()
      current_theme = site.theme || "maer"

      # Load existing config or default to empty
      theme_config = site.settings["theme_config"] || %{}
      json_content = Jason.encode!(theme_config, pretty: true)

      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)
       |> assign(:page_title, "Theme Settings")
       |> assign(:themes, themes)
       |> assign(:current_theme, current_theme)
       |> assign(:json_content, json_content)
       |> assign(:error_message, nil)}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_event("change_theme", %{"theme" => theme}, socket) do
    {:noreply, assign(socket, current_theme: theme)}
  end

  @impl true
  def handle_event("update_json", %{"value" => value}, socket) do
    {:noreply, assign(socket, json_content: value, error_message: nil)}
  end

  @impl true
  def handle_event("save", _req_params, socket) do
    # When submitting form, values might be in "theme" or just params depending on name
    # But for a simple separate handling:

    new_theme = socket.assigns.current_theme
    json_text = socket.assigns.json_content

    case Jason.decode(json_text) do
      {:ok, decoded_config} ->
        site = socket.assigns.site
        new_settings = Map.put(site.settings || %{}, "theme_config", decoded_config)

        updated_site = %{site | theme: new_theme, settings: new_settings}
        Repo.save_site(updated_site)

        {:noreply,
         socket
         |> assign(:site, updated_site)
         |> put_flash(:info, "Theme settings saved successfully")}

      {:error, _} ->
        {:noreply, assign(socket, error_message: "Invalid JSON configuration")}
    end
  end

  defp list_available_themes do
    themes_dir = Path.join(["priv", "themes"])

    if File.exists?(themes_dir) do
      File.ls!(themes_dir)
      |> Enum.filter(&File.dir?(Path.join(themes_dir, &1)))
      |> Enum.sort()
    else
      []
    end
  end

  @impl true
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
            <p class="text-sm text-slate-400">Theme Editor</p>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="border-b border-slate-700/50 bg-slate-800/30">
        <nav class="flex gap-1 px-6 overflow-x-auto">
          <a href={~p"/sites/#{@site_id}"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Overview</a>
          <a href={~p"/sites/#{@site_id}/posts"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Posts</a>
          <a href={~p"/sites/#{@site_id}/pages"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Pages</a>
          <a href={~p"/sites/#{@site_id}/media"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Media</a>
          <a href={~p"/sites/#{@site_id}/theme"} class="px-4 py-3 text-sm font-medium border-b-2 border-indigo-500 text-white transition-colors">Theme</a>
          <a href={~p"/sites/#{@site_id}/settings"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Settings</a>
        </nav>
      </div>

      <div class="p-6 md:p-10">
        <div class="max-w-4xl mx-auto">
          <div class="flex items-center justify-between mb-8">
            <div>
              <h2 class="text-2xl font-bold text-white">Theme Configuration</h2>
              <p class="text-slate-400 mt-1">Select a theme and configure its settings.</p>
            </div>
            <button phx-click="save" class="inline-flex items-center gap-2 px-6 py-2 rounded-lg bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition-colors shadow-lg hover:shadow-indigo-500/20">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>
              Save Changes
            </button>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Left Column: Theme Selection -->
            <div class="md:col-span-1 space-y-6">
              <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6">
                <label class="block text-sm font-medium text-slate-300 mb-3">Active Theme</label>
                <div class="relative">
                  <select phx-change="change_theme" name="theme" class="w-full appearance-none bg-slate-900 border border-slate-700 text-white rounded-lg px-4 py-2 pr-8 focus:outline-none focus:ring-2 focus:ring-indigo-500">
                    <%= for theme <- @themes do %>
                      <option value={theme} selected={theme == @current_theme}><%= String.capitalize(theme) %></option>
                    <% end %>
                  </select>
                  <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4 text-slate-400">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
                  </div>
                </div>

                <div class="mt-6">
                  <div class="aspect-video rounded-lg bg-slate-900 flex items-center justify-center border border-slate-700 text-slate-500 text-sm">
                    Preview not available
                  </div>
                  <p class="text-xs text-slate-500 mt-2 text-center">Theme Preview</p>
                </div>
              </div>
            </div>

            <!-- Right Column: JSON Configuration -->
            <div class="md:col-span-2">
              <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6 h-full flex flex-col">
                <label class="block text-sm font-medium text-slate-300 mb-3 flex items-center justify-between">
                  <span>Configuration (JSON)</span>
                  <span class="text-xs text-slate-500 font-normal">Edit theme parameters</span>
                </label>

                <div class="relative flex-1 min-h-[400px]">
                  <textarea
                    phx-change="update_json"
                    name="value"
                    spellcheck="false"
                    class="absolute inset-0 w-full h-full bg-slate-900 border border-slate-700 rounded-lg p-4 font-mono text-sm text-green-400 focus:outline-none focus:ring-2 focus:ring-indigo-500 resize-none leading-relaxed"
                  ><%= @json_content %></textarea>
                </div>

                <%= if @error_message do %>
                  <div class="mt-4 p-3 bg-red-500/10 border border-red-500/20 rounded-lg flex items-center gap-2 text-sm text-red-400">
                    <svg class="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                    <%= @error_message %>
                  </div>
                <% end %>

                <p class="text-xs text-slate-500 mt-4">
                  Define variables here like <code>&lbrace; "show_sidebar": true, "primary_color": "#ff0000" &rbrace;</code>.
                  These are passed to your templates as <code>site.settings.theme_config</code>.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
