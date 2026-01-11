defmodule PubliiEx.Plugins.GhostHunter do
  use PubliiEx.Plugin

  def id, do: :ghost_hunter
  def name, do: "Ghost Hunter"
  def description, do: "One-click migration tool from Ghost CMS."

  def render_settings(assigns) do
    ~H"<div>Settings for Ghost Hunter</div>"
  end
end
