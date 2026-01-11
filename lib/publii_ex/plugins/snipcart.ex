defmodule PubliiEx.Plugins.Snipcart do
  use PubliiEx.Plugin

  def id, do: :snipcart
  def name, do: "Snipcart Storefront"
  def description, do: "Turn your static site into an e-commerce store."

  def hooks do
    %{
      head: &inject_head/1,
      body: &inject_body/1
    }
  end

  def inject_head(context) do
    settings = context[:settings] || %{}

    if settings["api_key"] do
      """
      <link rel="preconnect" href="https://app.snipcart.com" />
      <link rel="preconnect" href="https://cdn.snipcart.com" />
      <link rel="stylesheet" href="https://cdn.snipcart.com/themes/v3.0.31/default/snipcart.css" />
      """
    else
      ""
    end
  end

  def inject_body(context) do
    settings = context[:settings] || %{}
    api_key = settings["api_key"]

    if api_key do
      """
      <script async src="https://cdn.snipcart.com/themes/v3.0.31/default/snipcart.js"></script>
      <div hidden id="snipcart" data-api-key="#{api_key}"></div>
      """
    else
      ""
    end
  end

  def render_settings(assigns) do
    ~H"""
    <div class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-zinc-700 dark:text-zinc-300">Public API Key</label>
        <input type="text" name="settings[api_key]" value={@settings["api_key"]} class="mt-1 block w-full rounded-md border-zinc-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="Your Snipcart Public API Key" />
      </div>

      <p class="text-xs text-zinc-500">
        Get your API Key from the <a href="https://app.snipcart.com/dashboard/account/credentials" target="_blank" class="text-indigo-600 hover:underline">Snipcart Dashboard</a>.
      </p>
    </div>
    """
  end
end
