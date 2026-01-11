defmodule PubliiExWeb.DashboardLive do
  use PubliiExWeb, :live_view
  alias PubliiEx.{Repo, Site}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-6 md:p-10">
      <!-- Header -->
      <div class="flex flex-col md:flex-row items-start md:items-center justify-between mb-10">
        <div>
          <h1 class="text-4xl font-bold text-white tracking-tight">My Sites</h1>
          <p class="text-slate-400 mt-2">Manage your websites from one place.</p>
        </div>
        <button
          phx-click="create_site"
          class="mt-4 md:mt-0 inline-flex items-center gap-2 px-5 py-3 rounded-lg bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold shadow-lg hover:shadow-xl transition-all hover:scale-105"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
          </svg>
          Create New Site
        </button>
      </div>

      <!-- Site Grid -->
      <%= if @sites == [] do %>
        <div class="flex flex-col items-center justify-center py-20 text-center">
          <div class="w-24 h-24 rounded-full bg-slate-700/50 flex items-center justify-center mb-6">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
            </svg>
          </div>
          <h2 class="text-2xl font-semibold text-white mb-2">No sites yet</h2>
          <p class="text-slate-400 max-w-md">Create your first site to get started with PubliiEx.</p>
        </div>
      <% else %>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <%= for site <- @sites do %>
            <.site_card site={site} />
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp site_card(assigns) do
    ~H"""
    <div class="group relative bg-slate-800/60 backdrop-blur border border-slate-700/50 rounded-2xl overflow-hidden hover:border-indigo-500/50 transition-all duration-300 hover:shadow-2xl hover:shadow-indigo-500/10">
      <!-- Thumbnail Preview -->
      <div class="h-40 bg-gradient-to-br from-slate-700 to-slate-800 flex items-center justify-center">
        <span class="text-6xl font-bold text-slate-600/50"><%= String.first(@site.name) %></span>
      </div>

      <!-- Content -->
      <div class="p-5">
        <div class="flex items-start justify-between">
          <div>
            <h3 class="text-xl font-semibold text-white group-hover:text-indigo-300 transition-colors">
              <%= @site.name %>
            </h3>
            <p class="text-sm text-slate-400 mt-1"><%= @site.base_url || "No URL set" %></p>
          </div>
          <span class={"px-2 py-1 text-xs font-medium rounded-full #{if @site.last_built, do: "bg-green-500/20 text-green-400", else: "bg-amber-500/20 text-amber-400"}"}>
            <%= if @site.last_built, do: "Published", else: "Draft" %>
          </span>
        </div>

        <div class="flex items-center gap-2 mt-4 text-xs text-slate-500">
          <span class="flex items-center gap-1">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"></path></svg>
            <%= @site.theme %>
          </span>
          <%= if @site.github_repo do %>
            <span class="flex items-center gap-1 text-green-400">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"></path></svg>
              Linked
            </span>
          <% end %>
        </div>

        <!-- Actions -->
        <div class="flex gap-2 mt-5 pt-4 border-t border-slate-700/50">
          <a href={~p"/sites/#{@site.id}"} class="flex-1 text-center py-2 px-3 text-sm font-medium bg-slate-700/50 hover:bg-slate-700 text-white rounded-lg transition-colors">
            Manage
          </a>

          <%= if url = Site.deployment_url(@site) do %>
             <a href={url} target="_blank" class="py-2 px-3 text-sm font-medium bg-green-500/20 hover:bg-green-500/30 text-green-400 border border-green-500/30 rounded-lg transition-colors flex items-center justify-center" title="View Live Site">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
             </a>
          <% end %>

          <a href={~p"/sites/#{@site.id}/settings"} class="py-2 px-3 text-sm font-medium bg-slate-700/50 hover:bg-slate-700 text-white rounded-lg transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
          </a>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    sites = Repo.list_sites()
    {:ok, assign(socket, sites: sites)}
  end

  def handle_event("create_site", _params, socket) do
    site = Site.new(%{name: "My New Site"})
    Repo.save_site(site)

    {:noreply,
     socket
     |> assign(sites: Repo.list_sites())
     |> push_navigate(to: ~p"/sites/#{site.id}")}
  end
end
