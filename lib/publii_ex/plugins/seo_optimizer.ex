defmodule PubliiEx.Plugins.SeoOptimizer do
  @moduledoc """
  Demonstrates :after_render hook by injecting optimized meta tags.
  """
  def id, do: :seo_optimizer
  def name, do: "SEO Optimizer (Pro)"
  def description, do: "Automatically injects OpenGraph tags and performance hints into HTML."

  def install(_site_id), do: :ok
  def uninstall(_site_id), do: :ok

  def hooks do
    %{
      # Demonstrates the new recursive pipeline hook
      after_render: fn html, _context ->
        # Inject an OG:Title if it's not there, etc.
        html
        |> String.replace("<head>", "<head>\n  <!-- SEO Optimizer Pro Active -->")
      end
    }
  end
end
