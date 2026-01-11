defmodule PubliiEx.Plugins.PrivacyPulse do
  use PubliiEx.Plugin

  def id, do: :privacy_pulse
  def name, do: "PrivacyPulse"
  def description, do: "Privacy-friendly analytics integration (Plausible/Umami)."

  def hooks do
    %{
      head: &inject_analytics/1
    }
  end

  def inject_analytics(context) do
    settings = context[:settings] || %{}
    provider = settings["provider"]
    domain = settings["domain"]
    src = settings["src"]

    case provider do
      "plausible" ->
        if domain do
          """
          <script defer data-domain="#{domain}" src="#{src || "https://plausible.io/js/script.js"}"></script>
          """
        else
          ""
        end

      "umami" ->
        if src && domain do
          """
          <script async src="#{src}" data-website-id="#{domain}"></script>
          """
        else
          ""
        end

      _ ->
        ""
    end
  end

  def render_settings(assigns) do
    ~H"""
    <div class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">Provider</label>
        <select name="settings[provider]" class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700">
          <option value="plausible" selected={@settings["provider"] == "plausible"}>Plausible Analytics</option>
          <option value="umami" selected={@settings["provider"] == "umami"}>Umami</option>
        </select>
      </div>

      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">Domain / Website ID</label>
        <input type="text" name="settings[domain]" value={@settings["domain"]} class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="example.com (Plausible) or UUID (Umami)" />
      </div>

      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">Script Source (Optional)</label>
        <input type="text" name="settings[src]" value={@settings["src"]} class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="https://plausible.io/js/script.js" />
        <p class="text-xs text-zinc-500 mt-1">Leave empty to use default Plausible hosted script.</p>
      </div>
    </div>
    """
  end
end
