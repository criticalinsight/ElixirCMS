defmodule PubliiEx.Plugins.NewsletterSync do
  use PubliiEx.Plugin

  def id, do: :newsletter_sync
  def name, do: "NewsletterSync"
  def description, do: "Sync published posts to ConvertKit or Buttondown."

  def render_settings(assigns) do
    ~H"<div>Settings for NewsletterSync</div>"
  end
end
