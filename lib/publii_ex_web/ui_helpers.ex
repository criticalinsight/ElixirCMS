defmodule PubliiExWeb.UIHelpers do
  @moduledoc """
  Helpers for UI components.
  """

  def classes(list) when is_list(list) do
    list
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 == false))
    |> Enum.join(" ")
    |> String.trim()
  end

  def button_variant(assigns) do
    # Simple mapping for now
    case assigns[:variant] do
      "destructive" -> "btn-error"
      "outline" -> "btn-outline"
      "ghost" -> "btn-ghost"
      "link" -> "btn-link"
      _ -> "btn-primary"
    end
  end

  def prepare_assign(assigns) do
    # Dummy implementation to satisfy compilation
    assigns
  end
end
