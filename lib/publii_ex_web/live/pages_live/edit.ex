defmodule PubliiExWeb.PagesLive.Edit do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo
  alias PubliiEx.Page

  @impl true
  def mount(%{"site_id" => site_id} = _params, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    site_id = socket.assigns.site_id
    page = Repo.get_page_for_site(site_id, id) || %Page{}

    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, page)
    |> assign(:form, to_form(Map.from_struct(page), as: "page"))
  end

  defp apply_action(socket, :new, _params) do
    id = generate_id()
    page = %Page{id: id, status: :draft}

    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, page)
    |> assign(:form, to_form(Map.from_struct(page), as: "page"))
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <!-- Site Header -->
      <div class="bg-slate-800/50 border-b border-slate-700/50 px-6 py-4">
        <div class="flex items-center gap-4">
          <a href={~p"/sites/#{@site_id}/pages"} class="text-slate-400 hover:text-white transition-colors">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
          </a>
          <div>
            <h1 class="text-xl font-bold text-white"><%= @page_title %></h1>
            <p class="text-sm text-slate-400"><%= @site.name %></p>
          </div>
        </div>
      </div>

      <!-- Content Area -->
      <div class="p-6 md:p-10">
        <div class="max-w-4xl mx-auto">
          <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6">
            <.form for={@form} phx-submit="save" class="space-y-6">
              <input type="hidden" name="page[id]" value={@form[:id].value} />

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="block text-sm font-medium text-slate-300">Title</label>
                  <input type="text" name="page[title]" value={@form[:title].value} required class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Page Title" />
                </div>
                <div class="space-y-2">
                  <label class="block text-sm font-medium text-slate-300">Slug</label>
                  <input type="text" name="page[slug]" value={@form[:slug].value} required class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="about" />
                </div>
              </div>

              <div class="space-y-2">
                <label class="block text-sm font-medium text-slate-300">Status</label>
                <select name="page[status]" class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-indigo-500">
                  <option value="draft" selected={@form[:status].value in ["draft", :draft]}>Draft</option>
                  <option value="published" selected={@form[:status].value in ["published", :published]}>Published</option>
                </select>
              </div>

              <div class="space-y-2" phx-update="ignore" id="editor-wrapper">
                <label class="block text-sm font-medium text-slate-300">Content (Markdown)</label>
                <textarea id="page-content-editor" phx-hook="EasyMDE" name="page[content_md]" rows="15" class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500"><%= @form[:content_md].value %></textarea>
              </div>

              <div class="pt-4 flex gap-4">
                <button type="submit" class="px-6 py-2 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition-colors">
                  Save Page
                </button>
                <.link navigate={~p"/sites/#{@site_id}/pages"} class="px-6 py-2 bg-slate-700 text-white font-medium rounded-lg hover:bg-slate-600 transition-colors">
                  Cancel
                </.link>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("save", %{"page" => params}, socket) do
    site_id = socket.assigns.site_id
    page = socket.assigns.page

    updated_page = %{
      page
      | title: params["title"],
        slug: params["slug"],
        content_md: params["content_md"],
        status: String.to_existing_atom(params["status"]),
        published_at: page.published_at || DateTime.utc_now()
    }

    Repo.save_page_for_site(site_id, updated_page)

    {:noreply,
     socket
     |> put_flash(:info, "Page saved successfully")
     |> push_navigate(to: ~p"/sites/#{site_id}/pages")}
  end

  defp generate_id, do: Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)
end
