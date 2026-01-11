defmodule PubliiEx.Plugins.Giscus do
  use PubliiEx.Plugin

  def id, do: :giscus
  def name, do: "Giscus Bridge"
  def description, do: "Zero-maintenance comment system using GitHub Discussions."

  def hooks do
    %{
      body: &inject_comments/1
    }
  end

  def inject_comments(context) do
    settings = context[:settings] || %{}
    repo = settings["repo"]
    repo_id = settings["repo_id"]
    category = settings["category"]
    category_id = settings["category_id"]

    if repo && repo_id do
      """
      <!-- Giscus Comments -->
      <script src="https://giscus.app/client.js"
        data-repo="#{repo}"
        data-repo-id="#{repo_id}"
        data-category="#{category}"
        data-category-id="#{category_id}"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="preferred_color_scheme"
        data-lang="en"
        crossorigin="anonymous"
        async>
      </script>
      """
    else
      ""
    end
  end

  def render_settings(assigns) do
    ~H"""
    <div class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">GitHub Repository (username/repo)</label>
        <input type="text" name="settings[repo]" value={@settings["repo"]} class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="myname/myrepo" />
      </div>

      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">Repository ID</label>
        <input type="text" name="settings[repo_id]" value={@settings["repo_id"]} class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700" />
      </div>

      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">Category</label>
        <input type="text" name="settings[category]" value={@settings["category"]} class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="Announcements" />
      </div>

      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">Category ID</label>
        <input type="text" name="settings[category_id]" value={@settings["category_id"]} class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700" />
      </div>

      <p class="text-xs text-zinc-500">
        You can find these values by configuring Giscus at <a href="https://giscus.app" target="_blank" class="text-indigo-600 hover:underline">giscus.app</a>.
      </p>
    </div>
    """
  end
end
