defmodule PubliiEx.Plugins.PixelPerfect do
  use PubliiEx.Plugin

  def id, do: :pixel_perfect
  def name, do: "PixelPerfect"
  def description, do: "Automatic image optimization (WebP/AVIF) and resizing."

  def render_settings(assigns) do
    ~H"<div>Settings for PixelPerfect</div>"
  end
end
