defmodule PubliiExWeb.PostsLive.Edit do
  use PubliiExWeb, :live_view
  alias PubliiEx.Repo
  alias PubliiEx.Post

  @impl true
  def mount(%{"site_id" => site_id} = _params, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)
       |> assign(:files, list_files())}
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
    post = Repo.get_post_for_site(site_id, id) || %Post{}

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
    |> assign(:form, to_form(Map.from_struct(post), as: "post"))
  end

  defp apply_action(socket, :new, _params) do
    id = generate_id()
    post = %Post{id: id, status: :draft, published_at: DateTime.utc_now()}

    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, post)
    |> assign(:form, to_form(Map.from_struct(post), as: "post"))
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <!-- Site Header -->
      <div class="bg-slate-800/50 border-b border-slate-700/50 px-6 py-4">
        <div class="flex items-center gap-4">
          <a href={~p"/sites/#{@site_id}/posts"} class="text-slate-400 hover:text-white transition-colors">
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
        <div class="max-w-5xl mx-auto">
          <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
            <div class="lg:col-span-3">
              <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6">
                <.form for={@form} phx-submit="save" class="space-y-6">
                  <input type="hidden" name="post[id]" value={@form[:id].value} />

                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="space-y-2">
                      <label class="block text-sm font-medium text-slate-300">Title</label>
                      <input type="text" name="post[title]" value={@form[:title].value} required class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Post Title" />
                    </div>
                    <div class="space-y-2">
                      <label class="block text-sm font-medium text-slate-300">Slug</label>
                      <input type="text" name="post[slug]" value={@form[:slug].value} required class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="post-slug" />
                    </div>
                  </div>

                  <div class="space-y-2">
                    <label class="block text-sm font-medium text-slate-300">Excerpt</label>
                    <textarea name="post[excerpt]" rows="2" class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Brief summary..."><%= @form[:excerpt].value %></textarea>
                  </div>

                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="space-y-2">
                      <label class="block text-sm font-medium text-slate-300">Featured Image URL</label>
                      <div class="flex gap-2">
                        <input type="text" id="featured-image-input" name="post[featured_image]" value={@form[:featured_image].value} class="flex-1 px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="/uploads/image.jpg" />
                        <%= if @form[:featured_image].value do %>
                          <div class="w-10 h-10 border border-slate-600 rounded overflow-hidden flex-shrink-0">
                            <img src={@form[:featured_image].value} class="w-full h-full object-cover" />
                          </div>
                        <% end %>
                      </div>
                    </div>
                    <div class="space-y-2">
                      <label class="block text-sm font-medium text-slate-300">Tags</label>
                      <input type="text" name="post[tags]" value={Enum.join(@form[:tags].value || [], ", ")} class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="tag1, tag2" />
                    </div>
                  </div>

                  <div class="space-y-4 pt-4 border-t border-slate-700/50">
                    <div class="flex items-center justify-between">
                       <h3 class="text-sm font-semibold text-slate-300">SEQ & Metadata</h3>
                       <button type="button" phx-click="generate_seo" class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-white bg-gradient-to-r from-purple-500 to-indigo-600 rounded-md hover:from-purple-600 hover:to-indigo-700 transition-all shadow-md">
                         <svg class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                         </svg>
                         Magic Writer
                       </button>
                    </div>

                    <div class="space-y-2">
                       <label class="block text-sm font-medium text-slate-400">SEO Title (Meta Title)</label>
                       <input type="text" name="post[seo_title]" value={@form[:seo_title].value} class="w-full px-4 py-2 bg-slate-700/30 border border-slate-600/30 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Optimized title for search engines..." />
                    </div>

                    <div class="space-y-2">
                       <label class="block text-sm font-medium text-slate-400">Meta Description</label>
                       <textarea name="post[seo_description]" rows="2" class="w-full px-4 py-2 bg-slate-700/30 border border-slate-600/30 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500" placeholder="Brief summary for search results..."><%= @form[:seo_description].value %></textarea>
                    </div>
                  </div>

                  <div class="grid grid-cols-2 gap-4">
                    <div class="space-y-2">
                      <label class="block text-sm font-medium text-slate-300">Status</label>
                      <select name="post[status]" class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-indigo-500">
                        <option value="draft" selected={@form[:status].value in ["draft", :draft]}>Draft</option>
                        <option value="published" selected={@form[:status].value in ["published", :published]}>Published</option>
                      </select>
                    </div>
                    <div class="space-y-2">
                      <label class="block text-sm font-medium text-slate-300">Published At</label>
                      <input type="datetime-local" name="post[published_at]" value={format_datetime_local(@form[:published_at].value)} class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-indigo-500" />
                    </div>
                  </div>

                  <div class="space-y-2" phx-update="ignore" id="editor-wrapper">
                    <label class="block text-sm font-medium text-slate-300">Content (Markdown)</label>
                    <textarea id="post-content-editor" phx-hook="EasyMDE" name="post[content_md]" rows="15" class="w-full px-4 py-2 bg-slate-700/50 border border-slate-600/50 rounded-lg text-white placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500"><%= @form[:content_md].value %></textarea>
                  </div>

                  <div class="pt-4 flex gap-4">
                    <button type="submit" class="px-6 py-2 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition-colors">
                      Save Post
                    </button>
                    <.link navigate={~p"/sites/#{@site_id}/posts"} class="px-6 py-2 bg-slate-700 text-white font-medium rounded-lg hover:bg-slate-600 transition-colors">
                      Cancel
                    </.link>
                  </div>
                </.form>
              </div>
            </div>

            <div class="lg:col-span-1">
              <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-4">
                <h3 class="text-sm font-semibold uppercase tracking-wider text-slate-400 mb-4">Media Assets</h3>
                <div class="grid grid-cols-2 gap-2 max-h-[600px] overflow-y-auto">
                  <%= for file <- @files do %>
                    <div class="group aspect-square border border-slate-600/50 rounded overflow-hidden relative bg-slate-700/50">
                      <img src={~p"/uploads/#{file}"} class="w-full h-full object-cover group-hover:scale-110 transition-transform" />
                      <div class="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col items-center justify-center gap-1">
                        <button type="button" phx-click="insert-image" phx-value-name={file} class="text-[9px] font-bold bg-white text-black px-2 py-1 rounded hover:bg-indigo-600 hover:text-white">INSERT</button>
                        <button type="button" phx-click="set-featured" phx-value-name={file} class="text-[9px] font-bold bg-white text-black px-2 py-1 rounded hover:bg-green-600 hover:text-white">FEATURED</button>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("generate_seo", %{"post" => params}, socket) do
    content = params["content_md"] || ""

    if String.length(content) < 50 do
      {:noreply,
       put_flash(
         socket,
         :error,
         "Please write more content before asking Magic Writer to analyze it."
       )}
    else
      # Async call (in a real app, maybe use Task.async to avoid blocking)
      seo_data = PubliiEx.AI.generate_seo(content)

      updated_params =
        (params || %{})
        |> Map.put("seo_title", seo_data.title)
        |> Map.put("seo_description", seo_data.description)

      updated_data =
        socket.assigns.form.data
        |> Map.put(:seo_title, seo_data.title)
        |> Map.put(:seo_description, seo_data.description)

      {:noreply,
       socket
       |> put_flash(:info, "✨ Magic Writer generated SEO metadata!")
       |> assign(form: to_form(updated_data, as: "post", params: updated_params))}
    end
  end

  @impl true
  def handle_event("save", %{"post" => params}, socket) do
    site_id = socket.assigns.site_id
    post = socket.assigns.post

    updated_post = %{
      post
      | title: params["title"],
        slug: params["slug"],
        content_md: params["content_md"],
        excerpt: params["excerpt"],
        featured_image: params["featured_image"],
        tags: parse_tags(params["tags"]),
        seo_title: params["seo_title"],
        seo_description: params["seo_description"],
        status: parse_status(params["status"]),
        published_at: parse_datetime(params["published_at"])
    }

    Repo.save_post_for_site(site_id, updated_post)

    {:noreply,
     socket
     |> put_flash(:info, "Post saved successfully")
     |> push_navigate(to: ~p"/sites/#{site_id}/posts")}
  end

  @impl true
  def handle_event("insert-image", %{"name" => name}, socket) do
    {:noreply, push_event(socket, "insert-image", %{path: ~p"/uploads/#{name}", name: name})}
  end

  @impl true
  def handle_event("set-featured", %{"name" => name}, socket) do
    path = ~p"/uploads/#{name}"
    form = socket.assigns.form
    updated_params = Map.put(form.params || %{}, "featured_image", path)
    updated_data = Map.put(form.data, :featured_image, path)
    {:noreply, assign(socket, form: to_form(updated_data, as: "post", params: updated_params))}
  end

  defp generate_id, do: Base.encode16(:crypto.strong_rand_bytes(16), case: :lower)

  defp list_files do
    uploads_dir = Path.join(["priv", "static", "uploads"])

    if File.exists?(uploads_dir) do
      File.ls!(uploads_dir)
      |> Enum.filter(&is_image/1)
      |> Enum.sort()
    else
      []
    end
  end

  defp is_image(filename) do
    ext = Path.extname(filename) |> String.downcase()
    ext in [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"]
  end

  defp parse_tags(nil), do: []

  defp parse_tags(str) do
    str |> String.split(",") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))
  end

  defp parse_status("published"), do: :published
  defp parse_status("draft"), do: :draft
  defp parse_status(:published), do: :published
  defp parse_status(:draft), do: :draft
  defp parse_status(_), do: :draft

  defp format_datetime_local(nil), do: ""
  defp format_datetime_local(%DateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%dT%H:%M")
  defp format_datetime_local(str) when is_binary(str), do: str

  defp parse_datetime(""), do: nil

  defp parse_datetime(str) do
    case DateTime.from_iso8601(str <> ":00Z") do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
