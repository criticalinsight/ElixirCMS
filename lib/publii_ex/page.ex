defmodule PubliiEx.Page do
  @derive {Jason.Encoder, only: [:id, :title, :slug, :content_md, :status, :published_at]}
  defstruct [:id, :title, :slug, :content_md, :status, :published_at]

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          slug: String.t(),
          content_md: String.t(),
          status: :draft | :published,
          published_at: DateTime.t() | nil
        }
end
