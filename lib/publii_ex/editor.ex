defmodule PubliiEx.Editor do
  @moduledoc """
  Converts EditorJS JSON (Delta) to HTML.
  """

  def to_html(nil), do: ""
  def to_html(""), do: ""

  def to_html(delta) when is_map(delta) do
    blocks = Map.get(delta, "blocks", [])
    Enum.map_join(blocks, "\n", &render_block/1)
  end

  def to_html(delta_str) when is_binary(delta_str) do
    case Jason.decode(delta_str) do
      {:ok, delta} -> to_html(delta)
      _ -> delta_str
    end
  end

  defp render_block(%{"type" => "paragraph", "data" => %{"text" => text}}) do
    "<p>#{text}</p>"
  end

  defp render_block(%{"type" => "header", "data" => %{"text" => text, "level" => level}}) do
    "<h#{level}>#{text}</h#{level}>"
  end

  defp render_block(%{"type" => "list", "data" => %{"style" => style, "items" => items}}) do
    tag = if style == "ordered", do: "ol", else: "ul"
    list_items = Enum.map_join(items, fn item -> "<li>#{item}</li>" end)
    "<#{tag}>#{list_items}</#{tag}>"
  end

  defp render_block(%{
         "type" => "image",
         "data" => %{"file" => %{"url" => url}, "caption" => caption}
       }) do
    """
    <figure>
      <img src="#{url}" alt="#{caption}">
      #{if caption != "", do: "<figcaption>#{caption}</figcaption>", else: ""}
    </figure>
    """
  end

  defp render_block(%{
         "type" => "quote",
         "data" => %{"text" => text, "caption" => caption, "alignment" => _}
       }) do
    """
    <blockquote>
      <p>#{text}</p>
      #{if caption != "", do: "<cite>#{caption}</cite>", else: ""}
    </blockquote>
    """
  end

  defp render_block(%{"type" => "code", "data" => %{"code" => code}}) do
    "<pre><code>#{Phoenix.HTML.Engine.encode_entities(code)}</code></pre>"
  end

  defp render_block(%{"type" => "delimiter"}) do
    "<hr />"
  end

  defp render_block(%{"type" => "checklist", "data" => %{"items" => items}}) do
    list_items =
      Enum.map_join(items, fn item ->
        checked = if item["checked"], do: "checked", else: ""

        """
        <li>
          <input type="checkbox" #{checked} disabled>
          <span>#{item["text"]}</span>
        </li>
        """
      end)

    "<ul class=\"checklist\">#{list_items}</ul>"
  end

  defp render_block(%{"type" => "table", "data" => %{"content" => content}}) do
    rows =
      Enum.map_join(content, fn row ->
        cols = Enum.map_join(row, fn col -> "<td>#{col}</td>" end)
        "<tr>#{cols}</tr>"
      end)

    "<table>#{rows}</table>"
  end

  defp render_block(block) do
    # Fallback for unknown blocks
    Logger.warning("Unknown EditorJS block type: #{Map.get(block, "type")}")
    ""
  end
end
