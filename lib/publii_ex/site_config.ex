defmodule PubliiEx.SiteConfig do
  @derive Jason.Encoder
  defstruct [
    :theme,
    :base_url,
    :seo_defaults,
    :github_repo,
    :github_token,
    :theme_config,
    :navigation,
    :deploy_method,
    :post_build_hook
  ]

  @type t :: %__MODULE__{
          theme: String.t(),
          base_url: String.t(),
          seo_defaults: map(),
          github_repo: String.t(),
          github_token: String.t(),
          theme_config: map(),
          navigation: list()
        }
end
