defmodule PubliiExWeb.PostsLive.Index do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo

  @impl true
  def mount(%{"site_id" => site_id} = _params, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      posts = list_posts_for_site(site_id)

      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)
       |> assign(:post_count, length(posts))
       |> stream(:posts, posts)}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  # Fallback for legacy non-site-scoped route
  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Posts - #{socket.assigns.site.name}")
    |> assign(:post, nil)
  end

  defp apply_action(socket, _action, _params), do: socket

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
            <p class="text-sm text-slate-400">Posts</p>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="border-b border-slate-700/50 bg-slate-800/30">
        <nav class="flex gap-1 px-6 overflow-x-auto">
          <a href={~p"/sites/#{@site_id}"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Overview</a>
          <a href={~p"/sites/#{@site_id}/posts"} class="px-4 py-3 text-sm font-medium border-b-2 border-indigo-500 text-white transition-colors">Posts</a>
          <a href={~p"/sites/#{@site_id}/pages"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Pages</a>
          <a href={~p"/sites/#{@site_id}/media"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Media</a>
          <a href={~p"/sites/#{@site_id}/settings"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Settings</a>
        </nav>
      </div>

      <!-- Content Area -->
      <div class="p-6 md:p-10">
        <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6">
          <div class="flex items-center justify-between mb-6">
            <div>
              <h2 class="text-2xl font-bold text-white">All Posts</h2>
              <p class="text-slate-400 text-sm mt-1"><%= @post_count %> posts</p>
            </div>
            <.link navigate={~p"/sites/#{@site_id}/posts/new"} class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
              New Post
            </.link>
          </div>

          <div class="mb-4">
            <form phx-change="search" phx-submit="search">
              <div class="relative">
                <svg class="absolute left-3 top-3 w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
                <input type="text" name="query" placeholder="Search posts..." class="w-full pl-10 pr-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" autocomplete="off" />
              </div>
            </form>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full">
              <thead>
                <tr class="text-left text-sm text-slate-400 border-b border-slate-700/50">
                  <th class="pb-3 font-medium">Title</th>
                  <th class="pb-3 font-medium">Status</th>
                  <th class="pb-3 font-medium">Published</th>
                  <th class="pb-3 font-medium text-right">Actions</th>
                </tr>
              </thead>
              <tbody id="posts" phx-update="stream">
                <tr :for={{id, post} <- @streams.posts} id={id} class="border-b border-slate-700/30 hover:bg-slate-700/20 transition-colors">
                  <td class="py-4 font-medium text-white"><%= post.title %></td>
                  <td class="py-4">
                    <span class={"px-2 py-1 text-xs font-medium rounded-full #{status_class(post.status)}"}>
                      <%= post.status %>
                    </span>
                  </td>
                  <td class="py-4 text-slate-400 text-sm"><%= format_date(post.published_at) %></td>
                  <td class="py-4 text-right">
                    <.link navigate={~p"/sites/#{@site_id}/posts/#{post.id}/edit"} class="text-indigo-400 hover:text-indigo-300 font-medium text-sm">Edit</.link>
                  </td>
                </tr>
              </tbody>
            </table>
            <div :if={@post_count == 0} class="py-12 text-center text-slate-400">
              No posts found. Create your first post!
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    posts = list_posts_for_site(socket.assigns.site_id, query)
    {:noreply, socket |> assign(:post_count, length(posts)) |> stream(:posts, posts, reset: true)}
  end

  defp list_posts_for_site(site_id, query \\ "") do
    Repo.list_posts_for_site(site_id)
    |> Enum.filter(fn post ->
      query == "" ||
        String.contains?(String.downcase(post.title || ""), String.downcase(query)) ||
        String.contains?(String.downcase(post.slug || ""), String.downcase(query))
    end)
    |> Enum.sort_by(
      fn post -> post.published_at || ~U[1970-01-01 00:00:00Z] end,
      {:desc, DateTime}
    )
  end

  defp status_class(:published), do: "bg-green-500/20 text-green-400"
  defp status_class(:draft), do: "bg-amber-500/20 text-amber-400"
  defp status_class(_), do: "bg-slate-500/20 text-slate-400"

  defp format_date(nil), do: "-"
  defp format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")
end
