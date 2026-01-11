defmodule PubliiEx.Post do
  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :slug,
             :content_md,
             :content_delta,
             :status,
             :published_at,
             :tags,
             :featured_image,
             :excerpt,
             :seo_title,
             :seo_description
           ]}
  defstruct [
    :id,
    :title,
    :slug,
    :content_md,
    :content_delta,
    :status,
    :published_at,
    :featured_image,
    :excerpt,
    :seo_title,
    :seo_description,
    tags: []
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          slug: String.t(),
          content_md: String.t(),
          content_delta: map() | nil,
          status: :draft | :published,
          published_at: DateTime.t() | nil,
          tags: [String.t()],
          featured_image: String.t() | nil,
          excerpt: String.t() | nil,
          seo_title: String.t() | nil,
          seo_description: String.t() | nil
        }
end
