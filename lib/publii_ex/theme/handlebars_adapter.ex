defmodule PubliiEx.Theme.HandlebarsAdapter do
  @moduledoc """
  Adapts Publii-Ex data structures for Handlebars (via bbmustache).
  """

  alias PubliiEx.Theme.Adapter

  def prepare_assigns(assigns) do
    # bbmustache expects binary keys and standard map structures.
    # Adapter.normalize/1 already provides string-keyed maps suitable for this.
    Adapter.normalize(assigns)
  end

  def render(template, assigns, partials \\ %{}) do
    data = prepare_assigns(assigns)

    # bbmustache options (Erlang proplist expected)
    options = [
      {:key_type, :binary},
      {:partials, Map.to_list(partials)}
    ]

    try do
      :bbmustache.render(template, data, options)
    rescue
      e ->
        IO.warn("Handlebars Render Error: #{inspect(e)}")
        "<!-- Handlebars Error: #{inspect(e)} -->"
    end
  end
end
