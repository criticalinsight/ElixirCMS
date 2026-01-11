defmodule PubliiExWeb.SettingsLive do
  use PubliiExWeb, :live_view
  alias PubliiEx.{Deployer, Generator, Repo}

  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col md:flex-row gap-0 overflow-hidden">
      <!-- Settings Panel -->
      <div class="w-full md:w-1/2 h-screen overflow-y-auto p-6 border-r bg-background">
        <div class="mb-5 flex items-center gap-2 text-sm text-slate-400">
          <a href={~p"/"} class="hover:text-white transition-colors">Sites</a>
          <span>/</span>
          <a href={~p"/sites/#{@site.id}"} class="hover:text-white transition-colors"><%= @site.name %></a>
          <span>/</span>
          <span class="text-white">Settings</span>
        </div>

        <div class="mb-8">
          <h1 class="text-3xl font-bold tracking-tight">Site Configuration</h1>
          <p class="text-muted-foreground mt-2">Manage settings for <%= @site.name %>.</p>
        </div>

        <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
          <div class="space-y-2">
            <label for="name" class="block text-sm font-medium leading-none">Site Name</label>
            <input type="text" name="site_config[name]" value={@form[:name].value} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background" />
          </div>

          <div class="space-y-2">
            <label for="base_url" class="block text-sm font-medium leading-none">Base URL</label>
            <input type="text" name="site_config[base_url]" value={@form[:base_url].value} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background" placeholder="https://example.com" />
          </div>

          <div class="space-y-2">
            <label for="theme" class="block text-sm font-medium leading-none">Theme</label>
            <select name="site_config[theme]" phx-change="change-theme" class="flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background">
              <%= for theme <- @available_themes do %>
                <option value={theme} selected={@form[:theme].value == theme}><%= String.capitalize(theme) %></option>
              <% end %>
            </select>
          </div>

          <%= if @theme_spec["config"] do %>
            <div class="space-y-4 pt-4 border-t">
              <h2 class="text-lg font-semibold">Theme Settings (<%= @theme_spec["name"] %>)</h2>
              <div class="grid grid-cols-1 gap-4">
                <%= for {key, value} <- @theme_spec["config"] do %>
                  <div class="space-y-2">
                    <label class="block text-sm font-medium leading-none"><%= key |> String.replace("_", " ") |> String.capitalize() %></label>
                    <%= if is_boolean(value) do %>
                      <select name={"site_config[theme_config][#{key}]"} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
                         <option value="true" selected={to_string(Map.get(@form[:theme_config].value || %{}, key, value)) == "true"}>Yes</option>
                         <option value="false" selected={to_string(Map.get(@form[:theme_config].value || %{}, key, value)) == "false"}>No</option>
                      </select>
                    <% else %>
                      <%= if String.contains?(String.downcase(key), "color") do %>
                        <div class="flex gap-2 items-center">
                          <input type="color" name={"site_config[theme_config][#{key}]"} value={Map.get(@form[:theme_config].value || %{}, key, value)} class="h-10 w-12 rounded cursor-pointer border border-input p-1" />
                          <input type="text" value={Map.get(@form[:theme_config].value || %{}, key, value)} class="flex-1 h-10 rounded-md border border-input bg-background px-3 py-2 text-sm font-mono text-xs" disabled />
                        </div>
                      <% else %>
                        <input type="text" name={"site_config[theme_config][#{key}]"} value={Map.get(@form[:theme_config].value || %{}, key, value)} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
                      <% end %>
                    <% end %>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>

          <div class="space-y-4 pt-4 border-t">
            <h2 class="text-lg font-semibold">Deployment & Hooks</h2>
            <div class="grid grid-cols-1 gap-4">
              <div class="space-y-2">
                <label class="block text-sm font-medium">Deployment Method</label>
                <select name="site_config[deploy_method]" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
                  <option value="cloudflare" selected={@form[:deploy_method].value == "cloudflare"}>Cloudflare Pages (Recommended)</option>
                  <option value="github" selected={@form[:deploy_method].value == "github"}>GitHub Pages (Legacy)</option>
                  <option value="hook" selected={@form[:deploy_method].value == "hook"}>Custom Shell Hook Only</option>
                </select>
              </div>

              <%= if @form[:deploy_method].value == "cloudflare" do %>
                <div class="space-y-2">
                  <label class="block text-sm font-medium">Cloudflare Account ID</label>
                  <input type="text" name="site_config[cloudflare_account_id]" value={@form[:cloudflare_account_id].value} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Found in Cloudflare Dashboard URL" />
                </div>
                <div class="space-y-2">
                  <label class="block text-sm font-medium">Cloudflare API Token</label>
                  <input type="password" name="site_config[cloudflare_api_token]" value={@form[:cloudflare_api_token].value} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="Must have Pages:Edit permissions" />
                </div>
                <div class="space-y-2">
                  <label class="block text-sm font-medium">Project Name</label>
                  <input type="text" name="site_config[cloudflare_project]" value={@form[:cloudflare_project].value} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="e.g. my-publii-site (defaults to site slug)" />
                </div>
              <% end %>

              <%= if @form[:deploy_method].value == "github" do %>
                <div class="space-y-2">
                  <label class="block text-sm font-medium">GitHub Repository</label>
                  <input type="text" name="site_config[github_repo]" value={@form[:github_repo].value} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm" placeholder="username/repo" />
                </div>
                <div class="space-y-2">
                  <label class="block text-sm font-medium">GitHub Token (ghp_...)</label>
                  <input type="password" name="site_config[github_token]" value={@form[:github_token].value} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
                </div>
              <% end %>

              <div class="space-y-2">
                <label class="block text-sm font-medium">Post-Build Shell Hook</label>
                <input type="text" name="site_config[post_build_hook]" value={@form[:settings].value["post_build_hook"]} class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm font-mono text-xs" placeholder="e.g. aws s3 sync . s3://my-bucket" />
                <p class="text-[10px] text-muted-foreground italic">Executed in the /output/sites/<%= @site.id %> directory after build.</p>
              </div>
            </div>
          </div>

          <div class="pt-6 flex flex-wrap gap-4 items-center">
            <button type="submit" class="inline-flex items-center justify-center rounded-md text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2">
              Save & Preview
            </button>
          </div>
        </.form>

        <div class="pt-8 border-t space-y-4">
           <h2 class="text-xl font-bold">Actions</h2>
           <div class="grid grid-cols-1 gap-3">
             <button type="button" phx-click="publish" class="flex-1 inline-flex items-center justify-center rounded-md text-sm font-medium bg-secondary text-secondary-foreground hover:bg-secondary/80 h-10 px-4 py-2">
               Rebuild Site
             </button>
             <button type="button" phx-click="deploy" class="flex-1 inline-flex items-center justify-center rounded-md text-sm font-medium bg-indigo-600 text-white hover:bg-indigo-700 h-10 px-4 py-2">
               Deploy to Cloudflare
             </button>
           </div>
        </div>
      </div>

      <!-- Preview Panel -->
      <div class="hidden md:flex flex-1 flex-col h-screen bg-muted/20">
        <div class="p-3 border-b flex items-center justify-between bg-background">
          <div class="flex items-center gap-2">
             <div class="size-2 rounded-full bg-green-500"></div>
             <span class="text-xs font-medium text-muted-foreground">Live Preview: index.html</span>
          </div>
          <div class="flex gap-2">
             <button onclick="document.getElementById('preview-frame').contentWindow.location.reload()" class="p-1 px-2 text-[10px] font-bold border rounded bg-background hover:bg-accent">REFRESH</button>
             <a href={"/sites/#{@site.id}/preview/index.html"} target="_blank" class="p-1 px-2 text-[10px] font-bold border rounded bg-background hover:bg-accent">OPEN NEW TAB</a>
          </div>
        </div>
        <iframe id="preview-frame" src={"/sites/#{@site.id}/preview/index.html"} class="flex-1 w-full border-none shadow-inner bg-white"></iframe>
      </div>
    </div>
    """
  end

  def mount(%{"site_id" => site_id}, _session, socket) do
    site = Repo.get_site!(site_id)
    available_themes = list_themes()
    theme_spec = load_theme_spec(site.theme || "maer")

    # Merge top-level fields and settings map for the form
    form_data =
      Map.from_struct(site)
      |> Map.merge(site.settings)
      |> Map.put(:theme_config, site.settings["theme_config"] || %{})

    socket =
      socket
      |> assign(site: site)
      |> assign(available_themes: available_themes, theme_spec: theme_spec)
      |> assign(form: to_form(form_data, as: "site_config"))

    {:ok, socket}
  end

  defp list_themes do
    Path.join(["priv", "themes"])
    |> File.ls!()
    |> Enum.filter(&File.dir?(Path.join(["priv", "themes", &1])))
  end

  defp load_theme_spec(theme) do
    json_path = Path.join(["priv", "themes", theme, "theme.json"])

    if File.exists?(json_path) do
      File.read!(json_path) |> Jason.decode!()
    else
      %{"name" => theme, "config" => %{}}
    end
  end

  def handle_event("validate", %{"site_config" => params}, socket) do
    # Just update the form data so conditional rendering works
    {:noreply, assign(socket, form: to_form(params, as: "site_config"))}
  end

  def handle_event("change-theme", %{"site_config" => %{"theme" => theme}}, socket) do
    theme_spec = load_theme_spec(theme)
    # We don't save yet, just update the spec to show new fields
    {:noreply, assign(socket, theme_spec: theme_spec)}
  end

  def handle_event("save", %{"site_config" => params}, socket) do
    site = socket.assigns.site

    # Update top-level fields
    site = %{
      site
      | name: params["name"],
        base_url: params["base_url"],
        theme: params["theme"],
        github_repo: params["github_repo"],
        github_token: params["github_token"],
        cloudflare_account_id: params["cloudflare_account_id"],
        cloudflare_api_token: params["cloudflare_api_token"],
        cloudflare_project: params["cloudflare_project"],
        deploy_method: params["deploy_method"]
    }

    # Update settings map
    updated_settings =
      Map.merge(site.settings, %{
        "theme_config" => params["theme_config"],
        "post_build_hook" => params["post_build_hook"]
      })

    site = %{site | settings: updated_settings}

    Repo.save_site(site)

    # Auto-build for preview
    Generator.build(site.id)

    {:noreply,
     socket
     |> put_flash(:info, "Configuration saved and preview updated.")
     |> assign(site: site)
     |> assign(
       form: to_form(Map.from_struct(site) |> Map.merge(updated_settings), as: "site_config")
     )
     |> push_event("refresh-preview", %{})}
  end

  def handle_event("publish", _params, socket) do
    {:ok, _output_dir} = Generator.build(socket.assigns.site.id)
    {:noreply, put_flash(socket, :info, "Site built successfully!")}
  end

  def handle_event("deploy", _params, socket) do
    # Get fresh site data
    site = Repo.get_site!(socket.assigns.site.id)

    # Check for credentials based on method
    has_cloudflare_creds =
      site.deploy_method == "cloudflare" && site.cloudflare_account_id &&
        site.cloudflare_api_token

    has_github_creds = site.deploy_method == "github" && site.github_repo && site.github_token

    if has_cloudflare_creds || has_github_creds || site.deploy_method == "hook" do
      # Auto-build before deploy
      Generator.build(site.id)

      case Deployer.deploy(site) do
        :ok ->
          {:noreply, put_flash(socket, :info, "Deployment successful!")}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Deployment failed: #{reason}")}
      end
    else
      msg =
        if site.deploy_method == "cloudflare",
          do: "Cloudflare Account ID and Token required.",
          else: "Deployment credentials required."

      {:noreply, put_flash(socket, :error, msg)}
    end
  end
end
