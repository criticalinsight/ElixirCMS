defmodule PubliiExWeb.MediaLive do
  use PubliiExWeb, :live_view
  require Logger

  alias PubliiEx.Repo

  @impl true
  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get_site(site_id)

    if site do
      site_uploads_dir = get_site_uploads_dir(site_id)
      if !File.exists?(site_uploads_dir), do: File.mkdir_p!(site_uploads_dir)

      {:ok,
       socket
       |> assign(:site_id, site_id)
       |> assign(:site, site)
       |> assign(:page_title, "Media Library")
       |> assign(:current_path, "")
       |> assign(:files, list_files(site_id, ""))
       |> assign(:folders, list_folders(site_id, ""))
       |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif .webp .svg), max_entries: 20)}
    else
      {:ok, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    site_id = socket.assigns.site_id
    current_path = socket.assigns.current_path
    site_uploads_dir = get_site_uploads_dir(site_id, current_path)

    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      dest = Path.join(site_uploads_dir, entry.client_name)
      File.cp!(path, dest)
      {:ok, ~p"/uploads/sites/#{site_id}/#{current_path}/#{entry.client_name}"}
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Files uploaded successfully")
     |> assign(:files, list_files(site_id, current_path))}
  end

  @impl true
  def handle_event("create_folder", %{"name" => name}, socket) do
    site_id = socket.assigns.site_id
    current_path = socket.assigns.current_path
    new_folder_path = Path.join(get_site_uploads_dir(site_id, current_path), name)

    if !File.exists?(new_folder_path) do
      File.mkdir_p!(new_folder_path)

      {:noreply,
       socket
       |> put_flash(:info, "Folder created")
       |> assign(:folders, list_folders(site_id, current_path))}
    else
      {:noreply, put_flash(socket, :error, "Folder already exists")}
    end
  end

  @impl true
  def handle_event("navigate", %{"path" => path}, socket) do
    site_id = socket.assigns.site_id

    {:noreply,
     socket
     |> assign(:current_path, path)
     |> assign(:files, list_files(site_id, path))
     |> assign(:folders, list_folders(site_id, path))}
  end

  @impl true
  def handle_event("delete", %{"name" => name, "type" => type}, socket) do
    site_id = socket.assigns.site_id
    current_path = socket.assigns.current_path
    path = Path.join(get_site_uploads_dir(site_id, current_path), name)

    case type do
      "file" -> if File.exists?(path), do: File.rm!(path)
      "folder" -> if File.exists?(path), do: File.rm_rf!(path)
    end

    {:noreply,
     socket
     |> put_flash(:info, "#{String.capitalize(type)} deleted")
     |> assign(:files, list_files(site_id, current_path))
     |> assign(:folders, list_folders(site_id, current_path))}
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
            <p class="text-sm text-slate-400">Media Library</p>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="border-b border-slate-700/50 bg-slate-800/30">
        <nav class="flex gap-1 px-6 overflow-x-auto">
          <a href={~p"/sites/#{@site_id}"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Overview</a>
          <a href={~p"/sites/#{@site_id}/posts"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Posts</a>
          <a href={~p"/sites/#{@site_id}/pages"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Pages</a>
          <a href={~p"/sites/#{@site_id}/media"} class="px-4 py-3 text-sm font-medium border-b-2 border-indigo-500 text-white transition-colors">Media</a>
          <a href={~p"/sites/#{@site_id}/settings"} class="px-4 py-3 text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-white transition-colors">Settings</a>
        </nav>
      </div>

      <div class="p-6 md:p-10">
        <div class="max-w-6xl mx-auto">
          <div class="flex items-center justify-between mb-8">
            <div>
              <h2 class="text-2xl font-bold text-white">Media Library</h2>
              <!-- Breadcrumbs -->
              <nav class="flex items-center gap-2 mt-2 text-sm text-slate-400">
                <button phx-click="navigate" phx-value-path="" class="hover:text-white transition-colors">Root</button>
                <%= for {part, index} <- Enum.with_index(String.split(@current_path, "/", trim: true)) do %>
                  <span class="text-slate-600">/</span>
                  <button phx-click="navigate" phx-value-path={Enum.slice(String.split(@current_path, "/", trim: true), 0..index) |> Path.join()} class="hover:text-white transition-colors">
                    <%= part %>
                  </button>
                <% end %>
              </nav>
            </div>
            <button onclick="document.getElementById('new-folder-modal').showModal()" class="px-4 py-2 bg-slate-700 hover:bg-slate-600 text-white rounded-lg text-sm font-medium transition-colors flex items-center gap-2">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m-9 1V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z" /></svg>
              New Folder
            </button>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <!-- Sidebar: Upload & Actions -->
            <div class="md:col-span-1 space-y-6">
              <div class="border border-slate-700/50 rounded-xl p-6 bg-slate-800/50 backdrop-blur-sm">
                <h3 class="text-sm font-bold text-slate-300 uppercase tracking-wider mb-4">Quick Upload</h3>
                <form id="upload-form" phx-submit="save" phx-change="validate">
                  <div class="space-y-4" phx-drop-target={@uploads.image.ref}>
                    <div class="flex flex-col items-center justify-center border-2 border-dashed border-slate-700 rounded-xl p-6 bg-slate-900/50 hover:bg-slate-800/50 transition-all group">
                      <.live_file_input upload={@uploads.image} class="hidden" id="file-input" />
                      <label for="file-input" class="cursor-pointer text-center">
                        <div class="w-10 h-10 bg-slate-800 rounded-lg flex items-center justify-center mb-3 mx-auto group-hover:scale-110 transition-transform">
                          <svg class="w-6 h-6 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" /></svg>
                        </div>
                        <span class="text-indigo-400 font-medium hover:text-indigo-300 block">Click to upload</span>
                        <span class="text-slate-500 text-xs mt-1">or drag and drop</span>
                      </label>
                    </div>

                    <%= for entry <- @uploads.image.entries do %>
                      <article class="text-xs bg-slate-900/80 p-3 rounded-lg border border-slate-700 space-y-2">
                        <div class="flex justify-between font-medium text-slate-300 truncate">
                          <span><%= entry.client_name %></span>
                          <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} class="text-red-400 hover:text-red-300">&times;</button>
                        </div>
                        <progress value={entry.progress} max="100" class="w-full h-1.5 rounded-full overflow-hidden bg-slate-800 [&::-webkit-progress-value]:bg-indigo-500 [&::-moz-progress-bar]:bg-indigo-500 transition-all"></progress>
                        <%= for err <- upload_errors(@uploads.image, entry) do %>
                          <p class="text-red-500 font-bold"><%= error_to_string(err) %></p>
                        <% end %>
                      </article>
                    <% end %>

                    <button type="submit" class="w-full inline-flex items-center justify-center rounded-lg text-sm font-bold bg-indigo-600 text-white hover:bg-indigo-500 h-11 px-4 py-2 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg shadow-indigo-500/10" disabled={Enum.empty?(@uploads.image.entries)}>
                      Upload to Current
                    </button>
                  </div>
                </form>
              </div>
            </div>

            <!-- Content Area: Folders & Files -->
            <div class="md:col-span-3 space-y-8">
              <!-- Folders Grid -->
              <%= if @folders != [] do %>
                <div>
                  <h3 class="text-sm font-bold text-slate-500 uppercase tracking-wider mb-4">Folders</h3>
                  <div class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-5 gap-4">
                    <%= for folder <- @folders do %>
                      <div class="group relative bg-slate-800/40 border border-slate-700/50 rounded-xl p-4 hover:bg-slate-700/50 transition-all cursor-pointer" phx-click="navigate" phx-value-path={Path.join(@current_path, folder)}>
                        <div class="flex flex-col items-center gap-3">
                          <svg class="w-10 h-10 text-amber-400/80 group-hover:scale-110 transition-transform" fill="currentColor" viewBox="0 0 24 24"><path d="M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"/></svg>
                          <span class="text-sm font-medium text-slate-300 truncate w-full text-center"><%= folder %></span>
                        </div>
                        <button phx-click="delete" phx-value-name={folder} phx-value-type="folder" data-confirm="Delete folder and all contents?" class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 p-1 text-slate-500 hover:text-red-400 transition-all">
                          &times;
                        </button>
                      </div>
                    <% end %>
                  </div>
                </div>
              <% end %>

              <!-- Files Grid -->
              <div>
                <h3 class="text-sm font-bold text-slate-500 uppercase tracking-wider mb-4">Files</h3>
                <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
                  <%= for file <- @files do %>
                    <div class="group relative aspect-square rounded-xl overflow-hidden bg-slate-900 border border-slate-700/50 flex items-center justify-center hover:border-indigo-500/50 transition-all">
                      <%= if is_image(file) do %>
                        <img src={~p"/uploads/sites/#{@site_id}/#{@current_path}/#{file}"} class="object-cover w-full h-full transition-transform group-hover:scale-105" loading="lazy" />
                      <% else %>
                        <div class="flex flex-col items-center gap-2">
                          <svg class="w-12 h-12 text-slate-700" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" /></svg>
                          <span class="text-slate-500 uppercase text-[10px] font-bold"><%= Path.extname(file) %></span>
                        </div>
                      <% end %>

                      <!-- Hover Overlay -->
                      <div class="absolute inset-0 bg-slate-900/90 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col items-center justify-center p-4 gap-3">
                        <p class="text-[10px] font-medium text-white truncate w-full text-center"><%= file %></p>
                        <div class="flex gap-2">
                           <button phx-click="delete" phx-value-name={file} phx-value-type="file" data-confirm="Are you sure?" class="px-3 py-1.5 rounded-lg bg-red-500/10 text-red-400 hover:bg-red-500/20 text-xs font-bold border border-red-500/20 transition-all">Delete</button>
                           <button class="px-3 py-1.5 rounded-lg bg-indigo-500/10 text-indigo-400 hover:bg-indigo-500/20 text-xs font-bold border border-indigo-500/20 transition-all">Edit</button>
                        </div>
                      </div>
                    </div>
                  <% end %>
                  <%= if @files == [] && @folders == [] do %>
                    <div class="col-span-full py-20 text-center">
                      <div class="w-16 h-16 bg-slate-800/50 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg class="w-8 h-8 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                      </div>
                      <p class="text-slate-500 italic">Empty folder. Shift your world here.</p>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- New Folder Modal -->
      <.modal id="new-folder-modal">
        <h3 class="text-lg font-bold text-white mb-4">Create New Folder</h3>
        <form phx-submit={JS.push("create_folder") |> hide_modal("new-folder-modal")}>
          <input type="text" name="name" placeholder="Folder name..." class="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500 mb-6" required autofocus />
          <div class="flex justify-end gap-3">
            <button type="button" phx-click={hide_modal("new-folder-modal")} class="px-4 py-2 text-slate-400 hover:text-white transition-colors">Cancel</button>
            <button type="submit" class="px-6 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg font-bold transition-all">Create</button>
          </div>
        </form>
      </.modal>
    </div>
    """
  end

  defp is_image(file_name) do
    String.downcase(Path.extname(file_name)) in [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"]
  end

  defp get_site_uploads_dir(site_id, sub_path \\ "") do
    Path.join(["priv", "static", "uploads", "sites", "#{site_id}", sub_path])
  end

  defp list_files(site_id, sub_path) do
    dir = get_site_uploads_dir(site_id, sub_path)

    if File.exists?(dir) do
      File.ls!(dir)
      |> Enum.filter(fn name -> !File.dir?(Path.join(dir, name)) end)
      |> Enum.sort()
    else
      []
    end
  end

  defp list_folders(site_id, sub_path) do
    dir = get_site_uploads_dir(site_id, sub_path)

    if File.exists?(dir) do
      File.ls!(dir)
      |> Enum.filter(fn name -> File.dir?(Path.join(dir, name)) end)
      |> Enum.sort()
    else
      []
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "Invalid file type"
  defp error_to_string(:too_many_files), do: "Too many files"
  defp error_to_string(err), do: inspect(err)
end
