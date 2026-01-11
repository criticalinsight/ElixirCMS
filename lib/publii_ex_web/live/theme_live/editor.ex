defmodule PubliiExWeb.ThemeLive.Editor do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo
  alias PubliiEx.Themes

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      themes = Themes.list_themes()
      current_theme = site.theme || "maer"

      # Load existing config or default to empty
      theme_config = site.settings["theme_config"] || %{}
      json_content = Jason.encode!(theme_config, pretty: true)

      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)
       |> assign(:page_title, "Theme Marketplace")
       |> assign(:themes, themes)
       |> assign(:current_theme, current_theme)
       |> assign(:json_content, json_content)
       |> assign(:error_message, nil)}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_event("activate", %{"theme" => theme_id}, socket) do
    site = socket.assigns.site

    # Load defaults for new theme
    defaults = Themes.get_theme_defaults(theme_id)

    new_settings = Map.put(site.settings || %{}, "theme_config", defaults)
    updated_site = %{site | theme: theme_id, settings: new_settings}
    Repo.save_site(updated_site)

    {:noreply,
     socket
     |> assign(:site, updated_site)
     |> assign(:current_theme, theme_id)
     |> assign(:json_content, Jason.encode!(defaults, pretty: true))
     |> put_flash(:info, "#{String.capitalize(theme_id)} theme activated!")}
  end

  @impl true
  def handle_event("update_json", %{"value" => value}, socket) do
    {:noreply, assign(socket, json_content: value, error_message: nil)}
  end

  @impl true
  def handle_event("save_config", _req_params, socket) do
    json_text = socket.assigns.json_content

    case Jason.decode(json_text) do
      {:ok, decoded_config} ->
        site = socket.assigns.site
        new_settings = Map.put(site.settings || %{}, "theme_config", decoded_config)

        updated_site = %{site | settings: new_settings}
        Repo.save_site(updated_site)

        {:noreply,
         socket
         |> assign(:site, updated_site)
         |> put_flash(:info, "Theme configuration saved successfully")}

      {:error, _} ->
        {:noreply, assign(socket, error_message: "Invalid JSON configuration")}
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
            <p class="text-sm text-slate-400">Theme Marketplace</p>
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
          <a href={~p"/sites/#{@site_id}/plugins"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Plugins</a>
          <a href={~p"/sites/#{@site_id}/settings"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Settings</a>
        </nav>
      </div>

      <div class="p-6 md:p-10 max-w-7xl mx-auto space-y-10">

        <!-- Marketplace Grid -->
        <div>
          <h2 class="text-2xl font-bold text-white mb-6">Available Themes</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <%= for theme <- @themes do %>
              <div class={"group relative bg-slate-800 border-2 rounded-xl overflow-hidden transition-all duration-300 #{if theme["id"] == @current_theme, do: "border-indigo-500 ring-2 ring-indigo-500/20", else: "border-slate-700 hover:border-slate-500"}"}>

                <!-- Preview Area -->
                <div class={"h-40 bg-gradient-to-br from-slate-700 to-slate-900 flex items-center justify-center #{gradient_for(theme["id"])}"}>
                    <span class="text-2xl font-bold text-white/20 uppercase tracking-widest"><%= theme["name"] %></span>
                </div>

                <div class="p-6">
                    <div class="flex items-start justify-between mb-4">
                        <div>
                            <h3 class="text-xl font-bold text-white"><%= theme["name"] %></h3>
                            <p class="text-xs text-slate-400">by <%= theme["author"] || "Unknown" %></p>
                        </div>
                        <%= if theme["id"] == @current_theme do %>
                            <span class="px-2 py-1 bg-green-500/10 text-green-400 text-xs font-bold rounded uppercase tracking-wider border border-green-500/20">Active</span>
                        <% end %>
                    </div>

                    <p class="text-sm text-slate-400 mb-6 h-10 line-clamp-2">
                        <%= theme["description"] %>
                    </p>

                    <%= if theme["id"] == @current_theme do %>
                        <button disabled class="w-full py-2 bg-slate-700 text-slate-400 font-medium rounded-lg cursor-not-allowed">
                            Currently Active
                        </button>
                    <% else %>
                        <div class="grid grid-cols-2 gap-2">
                             <%= if theme["preview_url"] do %>
                                 <a href={theme["preview_url"]} target="_blank" class="flex items-center justify-center py-2 bg-slate-700 text-white font-medium rounded-lg hover:bg-slate-600 transition-colors">
                                     Preview
                                 </a>
                             <% else %>
                                 <div class="py-2 text-center text-slate-500 text-sm font-medium">No Preview</div>
                             <% end %>
                             <button phx-click="activate" phx-value-theme={theme["id"]} class="py-2 bg-white text-black font-bold rounded-lg hover:bg-slate-200 transition-colors">
                                 Activate
                             </button>
                        </div>
                    <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <!-- Configuration Editor -->
        <div class="pt-10 border-t border-slate-700/50">
            <div class="flex items-center justify-between mb-6">
                <div>
                   <h2 class="text-xl font-bold text-white">Theme Configuration</h2>
                   <p class="text-sm text-slate-400">Advanced JSON settings for <strong><%= String.capitalize(@current_theme) %></strong></p>
                </div>
                <button phx-click="save_config" class="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg font-medium transition-colors">
                    Save Config
                </button>
            </div>

             <div class="bg-slate-900 rounded-xl border border-slate-700 p-1">
                <textarea
                    phx-change="update_json"
                    name="value"
                    spellcheck="false"
                    class="w-full h-64 bg-slate-900 text-green-400 font-mono text-sm p-4 rounded-lg focus:outline-none resize-none"
                  ><%= @json_content %></textarea>
             </div>
             <%= if @error_message do %>
                <div class="mt-2 text-red-400 text-sm"><%= @error_message %></div>
             <% end %>
        </div>

      </div>
    </div>
    """
  end

  defp gradient_for("nebula"), do: "from-indigo-900 to-purple-900"
  defp gradient_for("kinetic"), do: "from-yellow-400 to-orange-500"
  defp gradient_for("zenith"), do: "from-stone-200 to-stone-300"
  defp gradient_for("postos"), do: "from-gray-100 to-white text-black"
  defp gradient_for("monastery"), do: "from-zinc-100 to-zinc-200 text-black border-zinc-300"
  defp gradient_for("sushism"), do: "from-red-600 to-black text-white"
  defp gradient_for("humane"), do: "from-orange-50 to-amber-50 text-stone-800 border-amber-100"
  defp gradient_for("ordinary"), do: "bg-white border-black text-black"
  defp gradient_for("museum"), do: "from-orange-200 to-rose-200 text-black border-black"
  defp gradient_for("lime"), do: "bg-slate-900 border-lime-400 text-lime-400"
  defp gradient_for(_), do: "from-slate-700 to-slate-800"
end
