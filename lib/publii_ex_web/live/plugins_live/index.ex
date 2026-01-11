defmodule PubliiExWeb.PluginsLive.Index do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)
       |> assign(:page_title, "Plugins & Hooks")
       |> assign(:form, to_form(site.settings["hooks"] || %{}, as: "hooks"))}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-900 text-white">
      <!-- Header -->
      <div class="bg-slate-800 border-b border-slate-700 px-6 py-4">
        <div class="flex items-center justify-between">
           <div class="flex items-center gap-4">
            <a href={~p"/sites/#{@site_id}/dashboard"} class="text-slate-400 hover:text-white transition-colors">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
              </svg>
            </a>
            <div>
              <h1 class="text-xl font-bold text-white">Plugins & Hooks</h1>
              <p class="text-sm text-slate-400">Extend your site's build process</p>
            </div>
          </div>
        </div>
      </div>

      <div class="p-8 max-w-4xl mx-auto space-y-8">
        <!-- Shell Hooks Section -->
        <div class="bg-slate-800 rounded-xl border border-slate-700 p-6">
          <div class="flex items-start justify-between mb-6">
            <div>
              <h2 class="text-lg font-bold text-white flex items-center gap-2">
                <svg class="w-5 h-5 text-yellow-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                </svg>
                Build Hooks (Shell)
              </h2>
              <p class="text-sm text-slate-400 mt-1">
                Execute shell commands before or after the site build process.
                <span class="text-yellow-500 block mt-1">⚠️ Warning: Commands run with system privileges. Only use commands you trust.</span>
              </p>
            </div>
          </div>

          <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
            <div class="space-y-4">
              <div class="space-y-2">
                <label class="block text-sm font-medium text-slate-300">Pre-Build Command</label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span class="text-slate-500 text-xs font-mono">$</span>
                  </div>
                  <input type="text" name="hooks[pre_build]" value={@form[:pre_build].value} class="w-full pl-8 pr-4 py-2 bg-slate-900 border border-slate-600 rounded-lg text-white font-mono text-sm placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="e.g. echo 'Starting build' > status.txt" />
                </div>
                <p class="text-xs text-slate-500">Runs before content generation starts.</p>
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-medium text-slate-300">Post-Build Command</label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                     <span class="text-slate-500 text-xs font-mono">$</span>
                  </div>
                  <input type="text" name="hooks[post_build]" value={@form[:post_build].value} class="w-full pl-8 pr-4 py-2 bg-slate-900 border border-slate-600 rounded-lg text-white font-mono text-sm placeholder-slate-600 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="e.g. cp -r extra_assets/* output/" />
                </div>
                <p class="text-xs text-slate-500">Runs after static files are generated, before deployment.</p>
              </div>
            </div>

            <div class="pt-4 flex justify-end">
              <button type="submit" class="px-6 py-2 bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-lg transition-colors">
                Save Hooks
              </button>
            </div>
          </.form>
        </div>

        <!-- Future Plugin Slots -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 opacity-50 pointer-events-none grayscale">
          <div class="bg-slate-800 rounded-xl border border-slate-700 p-6 flex flex-col items-center text-center">
             <div class="w-12 h-12 bg-slate-700 rounded-full flex items-center justify-center mb-4">
               <svg class="w-6 h-6 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
               </svg>
             </div>
             <h3 class="font-bold text-white mb-2">Image Optimizer</h3>
             <p class="text-sm text-slate-400">Automatically compress images (Coming Soon)</p>
          </div>
          <div class="bg-slate-800 rounded-xl border border-slate-700 p-6 flex flex-col items-center text-center">
             <div class="w-12 h-12 bg-slate-700 rounded-full flex items-center justify-center mb-4">
               <svg class="w-6 h-6 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                 <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
               </svg>
             </div>
             <h3 class="font-bold text-white mb-2">Automatic SEO</h3>
             <p class="text-sm text-slate-400">Enhanced sitemaps & schema (Coming Soon)</p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"hooks" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "hooks"))}
  end

  @impl true
  def handle_event("save", %{"hooks" => params}, socket) do
    site = socket.assigns.site

    # Update site settings with new hooks
    updated_settings = Map.put(site.settings, "hooks", params)
    updated_site = %{site | settings: updated_settings}

    Repo.save_site(updated_site)

    {:noreply,
     socket
     |> put_flash(:info, "Hooks configuration saved.")
     |> assign(:site, updated_site)
     |> assign(form: to_form(params, as: "hooks"))}
  end
end
