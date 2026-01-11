defmodule PubliiEx.Slug do
  def slugify(nil), do: ""

  def slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/[\s-]+/, "-")
    |> String.trim("-")
  end

  # Alias for clarity
  def from_title(title), do: slugify(title)
end
