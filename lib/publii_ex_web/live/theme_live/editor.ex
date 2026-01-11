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
    # Defaults for new theme
    defaults = Themes.get_theme_defaults(theme_id)

    {:noreply,
     socket
     |> assign(:current_theme, theme_id)
     |> assign(:json_content, Jason.encode!(defaults, pretty: true))
     |> push_event("refresh-preview", %{})
     |> put_flash(:info, "#{String.capitalize(theme_id)} theme selected for preview")}
  end

  @impl true
  def handle_event("update_json", %{"value" => value}, socket) do
    socket = assign(socket, json_content: value, error_message: nil)

    # Attempt to parse and push targeted refresh if valid
    case Jason.decode(value) do
      {:ok, _decoded} ->
        {:noreply, push_event(socket, "refresh-styles", %{config: value})}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("save_config", _req_params, socket) do
    json_text = socket.assigns.json_content

    case Jason.decode(json_text) do
      {:ok, decoded_config} ->
        site = socket.assigns.site
        theme_id = socket.assigns.current_theme

        # Save both theme choice and config
        new_settings = Map.put(site.settings || %{}, "theme_config", decoded_config)
        updated_site = %{site | theme: theme_id, settings: new_settings}
        Repo.save_site(updated_site)

        {:noreply,
         socket
         |> assign(:site, updated_site)
         |> put_flash(:info, "Theme configuration and active theme saved successfully")}

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

        <!-- View Mode: Customizer -->
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">

          <!-- Sidebar: Visual Controls -->
          <div class="lg:col-span-4 space-y-6">
            <div class="bg-slate-800 border border-slate-700 rounded-2xl overflow-hidden shadow-xl sticky top-6">
              <div class="p-6 border-b border-slate-700 flex items-center justify-between bg-slate-800/50">
                <h2 class="text-sm font-bold text-white uppercase tracking-widest">Customizer</h2>
                <button phx-click="save_config" class="px-4 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-xs font-bold transition-all shadow-lg shadow-indigo-500/20">
                  Save Changes
                </button>
              </div>

              <div class="p-6 max-h-[calc(100vh-200px)] overflow-y-auto custom-scrollbar">
                <!-- Theme Selection -->
                <div class="mb-8">
                  <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block mb-2">Active Theme</label>
                  <form phx-change="activate">
                    <select name="theme" class="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-indigo-500">
                      <%= for theme <- @themes do %>
                        <option value={theme["id"]} selected={theme["id"] == @current_theme}><%= theme["name"] %></option>
                      <% end %>
                    </select>
                  </form>
                </div>

                <!-- Manual JSON Editor (Fallback) -->
                <div class="space-y-4">
                  <div class="flex items-center justify-between">
                    <label class="text-[10px] font-bold text-slate-500 uppercase tracking-widest block">Configuration</label>
                    <button class="text-[10px] font-bold text-indigo-400 hover:text-indigo-300 transition-colors uppercase">Visual Editor Soon</button>
                  </div>
                  <div class="bg-slate-950 rounded-xl border border-slate-700/50 p-2">
                    <textarea
                      phx-change="update_json"
                      name="value"
                      spellcheck="false"
                      class="w-full h-96 bg-transparent text-emerald-400 font-mono text-[11px] p-2 focus:outline-none resize-none"
                    ><%= @json_content %></textarea>
                  </div>
                  <%= if @error_message do %>
                    <div class="mt-2 text-red-400 text-[11px] bg-red-400/10 p-2 rounded border border-red-400/20"><%= @error_message %></div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>

          <!-- Preview Area: Iframe -->
          <div class="lg:col-span-8 flex flex-col gap-4">
            <div class="flex items-center justify-between px-2">
               <div class="flex items-center gap-4 text-xs font-medium text-slate-500">
                  <span class="flex items-center gap-1.5">
                    <div class="w-2 h-2 rounded-full bg-emerald-500 shadow-sm shadow-emerald-500/50"></div>
                    Live Preview
                  </span>
                  <span class="text-slate-700">|</span>
                  <span class="uppercase tracking-widest text-[10px]">Desktop View</span>
               </div>
               <div class="flex gap-1">
                 <div class="w-2.5 h-2.5 rounded-full bg-slate-700"></div>
                 <div class="w-2.5 h-2.5 rounded-full bg-slate-700"></div>
                 <div class="w-2.5 h-2.5 rounded-full bg-slate-700"></div>
               </div>
            </div>

            <div class="flex-1 bg-white rounded-2xl overflow-hidden shadow-2xl border border-slate-700/50 min-h-[700px] relative group">
                <iframe
                  id="theme-preview-frame"
                  phx-hook="Iframe"
                  src={~p"/sites/#{@site_id}/preview?config=#{@json_content}"}
                  class="w-full h-full border-none"
                ></iframe>

                <!-- Loading Overlay (optional, if we add triggers) -->
                <div id="preview-loader" class="absolute inset-0 bg-slate-900/10 backdrop-blur-[2px] pointer-events-none opacity-0 transition-opacity duration-300"></div>
            </div>
          </div>
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
