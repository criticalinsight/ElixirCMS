defmodule PubliiEx.AI do
  @moduledoc """
  Interface for Google Gemini API to generate "Platinum Market Insider" content.
  """
  require Logger

  def generate_seo(content) do
    key = Application.get_env(:publii_ex, :gemini_api_key)

    if is_nil(key) or key == "" do
      Logger.warning("Gemini API key not found. Returning mock SEO data.")
      mock_seo(content)
    else
      call_gemini_seo(content, key)
    end
  end

  defp call_gemini_seo(content, key) do
    prompt = """
    Analyze the following blog post content and generate an SEO-optimized title (max 60 chars) and meta description (max 160 chars).
    Return ONLY a JSON object with keys "title" and "description". Do not include markdown formatting like ```json.

    Content:
    #{String.slice(content, 0, 2000)}
    """

    api_url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

    body = %{
      contents: [
        %{
          parts: [%{text: prompt}]
        }
      ]
    }

    try do
      response = Req.post!("#{api_url}?key=#{key}", json: body)

      case response.body do
        %{"candidates" => [%{"content" => %{"parts" => [%{"text" => text} | _]}} | _]} ->
          parse_seo_json(text)

        error ->
          Logger.error("Gemini API Error: #{inspect(error)}")
          mock_seo(content)
      end
    rescue
      e ->
        Logger.error("Gemini Request Failed: #{inspect(e)}")
        mock_seo(content)
    end
  end

  defp parse_seo_json(text) do
    # Strip markdown code blocks if present (just in case model disobeys)
    clean_text =
      text
      |> String.replace(~r/^```json\s*/, "")
      |> String.replace(~r/\s*```$/, "")
      |> String.trim()

    case Jason.decode(clean_text) do
      {:ok, %{"title" => title, "description" => description}} ->
        %{title: title, description: description}

      _ ->
        Logger.warning("Failed to parse Gemini SEO response: #{text}")
        mock_seo("failed_parse")
    end
  end

  defp mock_seo(content) do
    %{
      title: "Optimized Title for #{String.slice(content, 0, 20)}...",
      description:
        "Auto-generated description based on the content. This is a placeholder because the AI key is missing or the request failed."
    }
  end
end
