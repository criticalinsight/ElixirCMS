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
       |> assign(:files, list_files(site_id))
       |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif .webp .svg), max_entries: 5)}
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
    site_uploads_dir = get_site_uploads_dir(site_id)

    consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      dest = Path.join(site_uploads_dir, entry.client_name)
      File.cp!(path, dest)
      {:ok, ~p"/uploads/sites/#{site_id}/#{entry.client_name}"}
    end)

    {:noreply,
     socket
     |> put_flash(:info, "Files uploaded successfully")
     |> assign(:files, list_files(site_id))}
  end

  @impl true
  def handle_event("delete", %{"name" => name}, socket) do
    site_id = socket.assigns.site_id
    file_path = Path.join(get_site_uploads_dir(site_id), name)
    if File.exists?(file_path), do: File.rm!(file_path)

    {:noreply,
     socket
     |> put_flash(:info, "File deleted")
     |> assign(:files, list_files(site_id))}
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
              <p class="text-slate-400 mt-1">Upload and manage images for this site.</p>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
            <!-- Upload Section -->
            <div class="md:col-span-1 border border-slate-700/50 rounded-lg p-6 bg-slate-800/50">
              <h3 class="text-lg font-semibold text-white mb-4">Upload</h3>
              <form id="upload-form" phx-submit="save" phx-change="validate">
                <div class="space-y-4" phx-drop-target={@uploads.image.ref}>
                  <div class="flex flex-col items-center justify-center border-2 border-dashed border-slate-600 rounded-lg p-6 bg-slate-900/50 hover:bg-slate-800/50 transition-colors">
                    <.live_file_input upload={@uploads.image} class="hidden" id="file-input" />
                    <label for="file-input" class="cursor-pointer text-center">
                      <span class="text-indigo-400 font-medium hover:text-indigo-300">Click to upload</span>
                      <span class="block text-slate-500 text-sm mt-1">or drag and drop</span>
                    </label>
                  </div>

                  <%= for entry <- @uploads.image.entries do %>
                    <article class="text-xs bg-slate-900 p-2 rounded border border-slate-700 flex flex-col gap-1">
                      <div class="flex justify-between font-medium text-slate-300 truncate">
                        <span><%= entry.client_name %></span>
                        <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} class="text-red-400 hover:text-red-300">&times;</button>
                      </div>
                      <progress value={entry.progress} max="100" class="w-full h-1 rounded overflow-hidden bg-slate-700 [&::-webkit-progress-value]:bg-indigo-500 [&::-moz-progress-bar]:bg-indigo-500"></progress>
                      <%= for err <- upload_errors(@uploads.image, entry) do %>
                        <p class="text-red-400"><%= error_to_string(err) %></p>
                      <% end %>
                    </article>
                  <% end %>

                  <button type="submit" class="w-full inline-flex items-center justify-center rounded-md text-sm font-medium bg-indigo-600 text-white hover:bg-indigo-700 h-10 px-4 py-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors" disabled={Enum.empty?(@uploads.image.entries)}>
                    Upload File(s)
                  </button>
                </div>
              </form>
            </div>

            <!-- Files List -->
            <div class="md:col-span-3 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
              <%= for file <- @files do %>
                <div class="group relative aspect-square border border-slate-700/50 rounded-lg overflow-hidden bg-slate-900 flex items-center justify-center">
                  <%= if is_image(file) do %>
                    <img src={~p"/uploads/sites/#{@site_id}/#{file}"} class="object-cover w-full h-full transition-transform group-hover:scale-105" loading="lazy" />
                  <% else %>
                    <span class="text-slate-500 uppercase text-xs font-bold"><%= Path.extname(file) %></span>
                  <% end %>

                  <div class="absolute inset-0 bg-black/80 opacity-0 group-hover:opacity-100 transition-opacity flex flex-col items-center justify-center p-2 gap-2">
                    <p class="text-[10px] text-white truncate w-full text-center px-2"><%= file %></p>
                    <div class="flex gap-2">
                       <button phx-click="delete" phx-value-name={file} data-confirm="Are you sure?" class="px-2 py-1 rounded-md bg-red-500/20 text-red-400 hover:bg-red-500/30 text-xs font-medium transition-colors">Delete</button>
                    </div>
                  </div>
                </div>
              <% end %>
              <%= if @files == [] do %>
                <div class="col-span-full py-12 text-center text-slate-500 italic">
                  No files yet. Upload some media to get started.
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_site_uploads_dir(site_id) do
    Path.join(["priv", "static", "uploads", "sites", "#{site_id}"])
  end

  defp list_files(site_id) do
    dir = get_site_uploads_dir(site_id)

    if File.exists?(dir) do
      File.ls!(dir)
      |> Enum.sort()
    else
      []
    end
  end

  defp is_image(filename) do
    ext = Path.extname(filename) |> String.downcase()
    ext in [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"]
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "Invalid file type"
  defp error_to_string(:too_many_files), do: "Too many files"
  defp error_to_string(err), do: inspect(err)
end
