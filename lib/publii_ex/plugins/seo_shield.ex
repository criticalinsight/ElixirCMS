defmodule PubliiEx.Plugins.SeoShield do
  use PubliiEx.Plugin

  def id, do: :seo_shield
  def name, do: "SEO Shield"
  def description, do: "Advanced SEO schema generation and OpenGraph tags."

  def hooks do
    %{
      head: &inject_schema/1
    }
  end

  def inject_schema(context) do
    site = context[:site]
    post = context[:post]
    page = context[:page]

    schema =
      cond do
        post ->
          %{
            "@context" => "https://schema.org",
            "@type" => "BlogPosting",
            "headline" => post.title,
            "datePublished" => to_iso8601(post.published_at),
            "author" => %{
              "@type" => "Person",
              "name" => post.author || site.settings["author"] || "Admin"
            }
          }

        page ->
          %{
            "@context" => "https://schema.org",
            "@type" => "WebPage",
            "headline" => page.title,
            "url" => "#{site.url}#{page.slug}"
          }

        true ->
          %{
            "@context" => "https://schema.org",
            "@type" => "WebSite",
            "name" => site.title,
            "url" => site.url
          }
      end

    """
    <script type="application/ld+json">
    #{Jason.encode!(schema)}
    </script>
    """
  end

  defp to_iso8601(nil), do: ""
  defp to_iso8601(dt), do: DateTime.to_iso8601(dt)

  def render_settings(assigns) do
    ~H"""
    <div class="space-y-4">
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        SEO Shield automatically generates JSON-LD structured data for your posts and pages.
        No configuration is required at this time.
      </p>
    </div>
    """
  end
end
