defmodule PubliiExWeb.SiteLive.Overview do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo

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
        <!-- Stats Grid -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <.stat_card label="Posts" value={@stats.posts} icon="document" />
          <.stat_card label="Pages" value={@stats.pages} icon="collection" />
          <.stat_card label="Media" value={@stats.media} icon="photograph" />
          <.stat_card label="Theme" value={@site.theme} icon="template" />
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <a href={~p"/sites/#{@site.id}/posts/new"} class="group flex items-center gap-4 p-5 bg-slate-800/50 border border-slate-700/50 rounded-xl hover:border-indigo-500/50 transition-all">
            <div class="w-12 h-12 rounded-full bg-indigo-500/20 flex items-center justify-center text-indigo-400 group-hover:scale-110 transition-transform">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
            </div>
            <div>
              <h3 class="font-semibold text-white">New Post</h3>
              <p class="text-sm text-slate-400">Create a new blog post</p>
            </div>
          </a>

          <button phx-click="build" class="group flex items-center gap-4 p-5 bg-slate-800/50 border border-slate-700/50 rounded-xl hover:border-green-500/50 transition-all text-left w-full">
            <div class="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center text-green-400 group-hover:scale-110 transition-transform">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" /></svg>
            </div>
            <div>
              <h3 class="font-semibold text-white">Rebuild Site</h3>
              <p class="text-sm text-slate-400">Regenerate all pages</p>
            </div>
          </button>

          <button phx-click="deploy" class="group flex items-center gap-4 p-5 bg-slate-800/50 border border-slate-700/50 rounded-xl hover:border-purple-500/50 transition-all text-left w-full">
            <div class="w-12 h-12 rounded-full bg-purple-500/20 flex items-center justify-center text-purple-400 group-hover:scale-110 transition-transform">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" /></svg>
            </div>
            <div>
              <h3 class="font-semibold text-white">Deploy</h3>
              <p class="text-sm text-slate-400">Push to GitHub Pages</p>
            </div>
          </button>
        </div>

        <!-- Recent Activity -->
        <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6">
          <h2 class="text-lg font-semibold text-white mb-4">Recent Posts</h2>
          <%= if @recent_posts == [] do %>
            <p class="text-slate-400 text-sm">No posts yet. Create your first post to get started.</p>
          <% else %>
            <ul class="divide-y divide-slate-700/50">
              <%= for post <- @recent_posts do %>
                <li class="py-3 flex items-center justify-between">
                  <div>
                    <p class="font-medium text-white"><%= post.title %></p>
                    <p class="text-xs text-slate-400"><%= Calendar.strftime(post.published_at || DateTime.utc_now(), "%B %d, %Y") %></p>
                  </div>
                  <a href={~p"/sites/#{@site.id}/posts/#{post.id}/edit"} class="text-sm text-indigo-400 hover:text-indigo-300">Edit</a>
                </li>
              <% end %>
            </ul>
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

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-4">
      <p class="text-2xl font-bold text-white"><%= @value %></p>
      <p class="text-sm text-slate-400"><%= @label %></p>
    </div>
    """
  end

  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      posts = Repo.list_posts_for_site(site_id)
      pages = Repo.list_pages_for_site(site_id)
      recent_posts = posts |> Enum.take(5)

      stats = %{
        posts: length(posts),
        pages: length(pages),
        media: count_media_files(site_id)
      }

      {:ok,
       assign(socket,
         site: site,
         active_tab: :overview,
         stats: stats,
         recent_posts: recent_posts
       )}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def handle_event("build", _params, socket) do
    site_id = socket.assigns.site.id

    case PubliiEx.Generator.build(site_id) do
      {:ok, _path} ->
        {:noreply, put_flash(socket, :info, "Site rebuilt successfully!")}

      _ ->
        {:noreply, put_flash(socket, :error, "Build failed. Check logs.")}
    end
  end

  def handle_event("deploy", _params, socket) do
    site = socket.assigns.site

    if site.github_repo && site.github_token do
      # TODO: Implement site-specific deployment
      {:noreply, put_flash(socket, :info, "Deployment started...")}
    else
      {:noreply, put_flash(socket, :error, "Configure GitHub settings first.")}
    end
  end

  defp count_media_files(site_id) do
    uploads_dir = Path.join(["priv", "static", "uploads", "sites", "#{site_id}"])

    if File.exists?(uploads_dir) do
      File.ls!(uploads_dir)
      |> Enum.filter(fn f ->
        ext = Path.extname(f) |> String.downcase()
        ext in [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg", ".mp4", ".webm"]
      end)
      |> length()
    else
      0
    end
  end
end
