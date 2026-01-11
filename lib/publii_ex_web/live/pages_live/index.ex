defmodule PubliiExWeb.PagesLive.Index do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo

  @impl true
  def mount(%{"site_id" => site_id} = _params, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      pages = list_pages_for_site(site_id)

      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)
       |> assign(:pages, pages)}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/")}
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
            <p class="text-sm text-slate-400">Pages</p>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="border-b border-slate-700/50 bg-slate-800/30">
        <nav class="flex gap-1 px-6 overflow-x-auto">
          <a href={~p"/sites/#{@site_id}"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Overview</a>
          <a href={~p"/sites/#{@site_id}/posts"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Posts</a>
          <a href={~p"/sites/#{@site_id}/pages"} class="px-4 py-3 text-sm font-medium border-b-2 border-indigo-500 text-white transition-colors">Pages</a>
          <a href={~p"/sites/#{@site_id}/media"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Media</a>
          <a href={~p"/sites/#{@site_id}/settings"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Settings</a>
        </nav>
      </div>

      <!-- Content Area -->
      <div class="p-6 md:p-10">
        <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6">
          <div class="flex items-center justify-between mb-6">
            <div>
              <h2 class="text-2xl font-bold text-white">Static Pages</h2>
              <p class="text-slate-400 text-sm mt-1"><%= length(@pages) %> pages</p>
            </div>
            <.link navigate={~p"/sites/#{@site_id}/pages/new"} class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
              New Page
            </.link>
          </div>

          <div class="mb-4">
            <form phx-change="search" phx-submit="search">
              <div class="relative">
                <svg class="absolute left-3 top-3 w-4 h-4 text-slate-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
                <input type="text" name="query" placeholder="Search pages..." class="w-full pl-10 pr-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" autocomplete="off" />
              </div>
            </form>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full">
              <thead>
                <tr class="text-left text-sm text-slate-400 border-b border-slate-700/50">
                  <th class="pb-3 font-medium">Title</th>
                  <th class="pb-3 font-medium">Slug</th>
                  <th class="pb-3 font-medium">Status</th>
                  <th class="pb-3 font-medium text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                <%= for page <- @pages do %>
                  <tr class="border-b border-slate-700/30 hover:bg-slate-700/20 transition-colors">
                    <td class="py-4 font-medium text-white"><%= page.title %></td>
                    <td class="py-4 text-slate-400 text-sm">/<%= page.slug %></td>
                    <td class="py-4">
                      <span class={"px-2 py-1 text-xs font-medium rounded-full #{status_class(page.status)}"}>
                        <%= page.status %>
                      </span>
                    </td>
                    <td class="py-4 text-right flex justify-end gap-2">
                      <.link navigate={~p"/sites/#{@site_id}/pages/#{page.id}/edit"} class="text-indigo-400 hover:text-indigo-300 font-medium text-sm">Edit</.link>
                      <button phx-click="delete" phx-value-id={page.id} data-confirm="Are you sure?" class="text-red-400 hover:text-red-300 font-medium text-sm">Delete</button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
            <div :if={@pages == []} class="py-12 text-center text-slate-400">
              No pages found. Create your first static page!
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    pages = list_pages_for_site(socket.assigns.site_id, query)
    {:noreply, assign(socket, pages: pages)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Repo.delete_page_for_site(socket.assigns.site_id, id)
    pages = list_pages_for_site(socket.assigns.site_id)
    {:noreply, assign(socket, pages: pages)}
  end

  defp list_pages_for_site(site_id, query \\ "") do
    Repo.list_pages_for_site(site_id)
    |> Enum.filter(fn page ->
      query == "" ||
        String.contains?(String.downcase(page.title || ""), String.downcase(query)) ||
        String.contains?(String.downcase(page.slug || ""), String.downcase(query))
    end)
    |> Enum.sort_by(& &1.title)
  end

  defp status_class(:published), do: "bg-green-500/20 text-green-400"
  defp status_class(:draft), do: "bg-amber-500/20 text-amber-400"
  defp status_class(_), do: "bg-slate-500/20 text-slate-400"
end
