defmodule PubliiEx.Site do
  @moduledoc """
  Represents a single site in the multisite architecture.
  Each site has its own posts, pages, theme, and deployment settings.
  """

  @derive Jason.Encoder
  defstruct [
    :id,
    :name,
    :slug,
    :theme,
    :base_url,
    :github_repo,
    :github_token,
    :cloudflare_account_id,
    :cloudflare_api_token,
    :cloudflare_project,
    :deploy_method,
    :settings,
    :plugins,
    :last_built,
    :created_at
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          slug: String.t(),
          theme: String.t(),
          base_url: String.t() | nil,
          github_repo: String.t() | nil,
          github_token: String.t() | nil,
          cloudflare_account_id: String.t() | nil,
          cloudflare_api_token: String.t() | nil,
          cloudflare_project: String.t() | nil,
          deploy_method: String.t(),
          settings: map(),
          plugins: list(String.t()),
          last_built: DateTime.t() | nil,
          created_at: DateTime.t()
        }

  def new(attrs \\ %{}) do
    id = attrs[:id] || generate_id()
    now = DateTime.utc_now()

    %__MODULE__{
      id: id,
      name: attrs[:name] || "New Site",
      slug: attrs[:slug] || PubliiEx.Slug.slugify(attrs[:name] || "new-site"),
      theme: attrs[:theme] || "maer",
      base_url: attrs[:base_url],
      github_repo: attrs[:github_repo],
      github_token: attrs[:github_token],
      cloudflare_account_id: attrs[:cloudflare_account_id],
      cloudflare_api_token: attrs[:cloudflare_api_token],
      cloudflare_project: attrs[:cloudflare_project],
      deploy_method: attrs[:deploy_method] || "github",
      settings: attrs[:settings] || %{},
      plugins: attrs[:plugins] || [],
      last_built: nil,
      created_at: attrs[:created_at] || now
    }
  end

  defp generate_id do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64(padding: false)
  end

  def deployment_url(%__MODULE__{github_repo: repo}) when is_binary(repo) and repo != "" do
    case String.split(repo, "/") do
      [user, name] -> "https://#{user}.github.io/#{name}"
      _ -> nil
    end
  end

  def deployment_url(_), do: nil
end
