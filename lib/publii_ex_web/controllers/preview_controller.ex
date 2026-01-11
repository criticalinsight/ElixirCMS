defmodule PubliiExWeb.PreviewController do
  use PubliiExWeb, :controller
  alias PubliiEx.{Generator, Repo}

  def show(conn, %{"site_id" => site_id} = params) do
    site = Repo.get_site(site_id)
    config = parse_config(params["config"])
    html = Generator.render_site_to_memory(site, config)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  def styles(conn, %{"site_id" => site_id} = params) do
    site = Repo.get_site(site_id)
    config = parse_config(params["config"])
    css = Generator.render_theme_styles(site, config)

    conn
    |> put_resp_content_type("text/css")
    |> send_resp(200, css)
  end

  defp parse_config(nil), do: nil

  defp parse_config(json) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, decoded} -> decoded
      _ -> nil
    end
  end
end
